-- ============================================================
-- RETAIL SALES & PROFITABILITY ANALYSIS (MySQL 8.0)
-- ============================================================
-- Database : retail_analytics
-- Table    : superstore (typed, cleaned)
-- Dataset  : Sample Superstore (US retail orders, values in USD)
--
-- Objective:
-- Analyze sales, profitability, customers, products, discounts,
-- regions and time-based performance to find key business
-- insights and areas of concern.
--
-- Verified after load (use these to confirm your setup):
--   Rows: 9,994 | Total Sales: 2,297,200.86 | Total Profit: 286,397.02
--   Date range: 2014-01-03 to 2017-12-30
-- ============================================================


-- ============================================================
-- 0. DATABASE & DATA SETUP
-- ============================================================


-- 0.1 Create database
CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;


-- 0.2 Staging table
-- All columns are VARCHAR so the CSV loads without any row being
-- rejected. Data types are applied later, when inserting into the
-- final table (0.4 and 0.5).
DROP TABLE IF EXISTS superstore_raw;
CREATE TABLE superstore_raw (
  row_id VARCHAR(10), order_id VARCHAR(20), order_date_txt VARCHAR(20),
  ship_date_txt VARCHAR(20), ship_mode VARCHAR(20), customer_id VARCHAR(20),
  customer_name VARCHAR(60), segment VARCHAR(20), country VARCHAR(30),
  city VARCHAR(60), state VARCHAR(40), postal_code VARCHAR(10),
  region VARCHAR(10), product_id VARCHAR(30), category VARCHAR(20),
  sub_category VARCHAR(20), product_name VARCHAR(255), sales VARCHAR(20),
  quantity VARCHAR(10), discount VARCHAR(10), profit VARCHAR(20)
);


-- 0.3 Load the CSV into the staging table
-- Update the file path to your MySQL Uploads folder
-- (find it with: SHOW VARIABLES LIKE 'secure_file_priv';)
-- The file is Windows-1252 encoded, hence CHARACTER SET latin1.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sample - Superstore.csv'
INTO TABLE superstore_raw
CHARACTER SET latin1
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


-- 0.4 Final table with proper data types
DROP TABLE IF EXISTS superstore;
CREATE TABLE superstore (
  row_id INT PRIMARY KEY, order_id VARCHAR(20), order_date DATE, ship_date DATE,
  ship_mode VARCHAR(20), customer_id VARCHAR(20), customer_name VARCHAR(60),
  segment VARCHAR(20), country VARCHAR(30), city VARCHAR(60), state VARCHAR(40),
  postal_code VARCHAR(10), region VARCHAR(10), product_id VARCHAR(30),
  category VARCHAR(20), sub_category VARCHAR(20), product_name VARCHAR(255),
  sales DECIMAL(12,4), quantity INT, discount DECIMAL(4,2), profit DECIMAL(12,4)
);


-- 0.5 Insert with type conversion and cleaning
-- (dates converted to DATE; hidden non-breaking spaces removed
-- from product names)
INSERT INTO superstore
SELECT row_id, order_id,
       STR_TO_DATE(order_date_txt, '%m/%d/%Y'), STR_TO_DATE(ship_date_txt, '%m/%d/%Y'),
       ship_mode, customer_id, customer_name, segment, country, city, state,
       postal_code, region, product_id, category, sub_category,
       REPLACE(product_name, CONVERT(UNHEX('C2A0') USING utf8mb4), ' '),
       CAST(sales AS DECIMAL(12,4)), CAST(quantity AS SIGNED),
       CAST(discount AS DECIMAL(4,2)), CAST(profit AS DECIMAL(12,4))
FROM superstore_raw;


-- ============================================================
-- 1. DATA VALIDATION
-- ============================================================


-- 1.1 Row reconciliation: Row ID runs 1..9994 in the source file,
--     so missing_rows must be 0.
SELECT
    COUNT(*)                     AS rows_loaded,
    MAX(row_id)                  AS max_row_id,
    MAX(row_id) - COUNT(*)       AS missing_rows
FROM superstore;


-- 1.2 Raw vs clean row counts (nothing lost in conversion)
SELECT
    (SELECT COUNT(*) FROM superstore_raw) AS raw_rows,
    (SELECT COUNT(*) FROM superstore)     AS clean_rows;


-- 1.3 Unique orders and customers
SELECT
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_id)  AS total_products
FROM superstore;


-- 1.4 Missing values in key columns
SELECT
    SUM(order_id      IS NULL) AS missing_order_id,
    SUM(customer_id   IS NULL) AS missing_customer_id,
    SUM(sales         IS NULL) AS missing_sales,
    SUM(profit        IS NULL) AS missing_profit,
    SUM(quantity      IS NULL) AS missing_quantity,
    SUM(order_date    IS NULL) AS missing_order_date
FROM superstore;


-- 1.5 Duplicate Row IDs (should return no rows)
SELECT row_id, COUNT(*) AS record_count
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;


-- 1.6 Negative sales / negative profit / discount range
SELECT
    SUM(sales < 0)              AS negative_sales_records,
    SUM(profit < 0)             AS negative_profit_records,
    MIN(discount)               AS min_discount,
    MAX(discount)               AS max_discount
FROM superstore;


-- 1.7 Date range
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM superstore;


-- 1.8 Hidden non-breaking spaces left after cleaning (should be 0)
SELECT SUM(HEX(product_name) LIKE '%C2A0%') AS nbsp_remaining
FROM superstore;


-- 1.9 Product IDs mapped to more than one name.
--     Products are grouped by product_id AND product_name below
--     so different products are never merged.
SELECT product_id, COUNT(DISTINCT product_name) AS name_variants
FROM superstore
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1;


-- ============================================================
-- 2. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(*)                                        AS total_records,
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(SUM(profit), 2)                           AS total_profit,
    SUM(quantity)                                   AS total_units,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)        AS overall_profit_margin_pct
FROM superstore;


-- ============================================================
-- 3. CATEGORY ANALYSIS
-- ============================================================

SELECT
    category,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    SUM(quantity)                            AS total_units,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY total_profit DESC;


-- ============================================================
-- 4. REGIONAL ANALYSIS
-- ============================================================

-- 4.1 Region performance (with average discount)
SELECT
    region,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)            AS avg_discount_pct
FROM superstore
GROUP BY region
ORDER BY total_profit DESC;


-- 4.2 State drill-down for the Central region
--     (lowest-margin region: which states drag it down?)
SELECT
    state,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)            AS avg_discount_pct
FROM superstore
WHERE region = 'Central'
GROUP BY state
ORDER BY total_profit ASC;


-- 4.3 Loss-making states across all regions
SELECT
    region,
    state,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY region, state
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;


-- ============================================================
-- 5. SUB-CATEGORY ANALYSIS
-- ============================================================

-- 5.1 Sub-category performance
SELECT
    sub_category,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    SUM(quantity)                            AS total_units,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY sub_category
ORDER BY total_profit DESC;


-- 5.2 Loss-making sub-categories
SELECT
    sub_category,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;


-- 5.3 Tables performance by region
SELECT
    region,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)            AS avg_discount_pct
FROM superstore
WHERE sub_category = 'Tables'
GROUP BY region
ORDER BY total_profit ASC;


-- ============================================================
-- 6. DISCOUNT ANALYSIS
-- Bands: No Discount = 0% | Low = up to 20% |
--        Medium = 20-40% | High = above 40%
-- Margin is SUM(profit) / SUM(sales), not an average of
-- row-level margins.
-- ============================================================

-- 6.1 Discount band analysis (all products)
SELECT
    CASE
        WHEN discount = 0    THEN 'No Discount'
        WHEN discount <= 0.20 THEN 'Low Discount'
        WHEN discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_band,
    COUNT(*)                                 AS total_records,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY discount_band
ORDER BY MIN(discount);


-- 6.2 Discount bands within Tables
SELECT
    CASE
        WHEN discount = 0    THEN 'No Discount'
        WHEN discount <= 0.20 THEN 'Low Discount'
        WHEN discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_band,
    COUNT(*)                                 AS total_records,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 2)            AS avg_discount_pct
FROM superstore
WHERE sub_category = 'Tables'
GROUP BY discount_band
ORDER BY MIN(discount);


-- 6.3 Tables by exact discount level
SELECT
    ROUND(discount * 100, 0)                 AS discount_pct,
    COUNT(*)                                 AS record_count,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;


-- 6.4 Discount bands by category
--     Controls for product mix: does the discount-profit pattern
--     hold inside each category, or is it driven by which
--     products get discounted?
SELECT
    category,
    CASE
        WHEN discount = 0    THEN 'No Discount'
        WHEN discount <= 0.20 THEN 'Low Discount'
        WHEN discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_band,
    COUNT(*)                                 AS total_records,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY category, discount_band
ORDER BY category, MIN(discount);


-- ============================================================
-- 7. CUSTOMER ANALYSIS
-- ============================================================

-- 7.1 Average order value (per unique order)
SELECT
    COUNT(DISTINCT order_id)                          AS total_orders,
    ROUND(SUM(sales), 2)                              AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)   AS average_order_value
FROM superstore;


-- 7.2 Top 10 customers by sales
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id)                          AS total_orders,
    ROUND(SUM(sales), 2)                              AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)   AS average_order_value
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 10;


-- 7.3 Top 10 customers by profit
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id)                 AS total_orders,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_profit DESC
LIMIT 10;


-- 7.4 Loss-making customers
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id)                 AS total_orders,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY customer_id, customer_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 10;


-- 7.5 Top 10 customers by sales, with their profit alongside
--     (shows whether high-sales customers are actually profitable)
SELECT
    customer_id,
    customer_name,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC)   AS sales_rank
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY sales_rank
LIMIT 10;


-- 7.6 Customer sales concentration (top ~20% of customers)
WITH customer_sales AS (
    SELECT
        customer_id,
        customer_name,
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY customer_id, customer_name
),
ranked_customers AS (
    SELECT
        customer_id,
        customer_name,
        total_sales,
        ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS customer_rank,
        COUNT(*) OVER ()                              AS total_customers
    FROM customer_sales
),
top_customers AS (
    SELECT SUM(total_sales) AS top_20_sales
    FROM ranked_customers
    WHERE customer_rank <= CEIL(total_customers * 0.20)
),
overall AS (
    SELECT SUM(total_sales) AS total_sales
    FROM customer_sales
)
SELECT
    ROUND(top_20_sales, 2)                            AS top_20_sales,
    ROUND(top_20_sales / total_sales * 100, 2)        AS sales_contribution_pct
FROM top_customers
CROSS JOIN overall;


-- 7.7 Repeat-customer rate
--     (customers with more than one distinct order)
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS orders
    FROM superstore
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                          AS total_customers,
    SUM(orders > 1)                                   AS repeat_customers,
    ROUND(SUM(orders > 1) / COUNT(*) * 100, 2)        AS repeat_customer_rate_pct,
    ROUND(AVG(orders), 2)                             AS avg_orders_per_customer
FROM customer_orders;


-- ============================================================
-- 8. PRODUCT ANALYSIS
-- (grouped by product_id AND product_name)
-- ============================================================

-- 8.1 Top 10 products by sales
SELECT
    product_id,
    product_name,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY product_id, product_name
ORDER BY total_sales DESC
LIMIT 10;


-- 8.2 Top 10 products by profit
SELECT
    product_id,
    product_name,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY product_id, product_name
ORDER BY total_profit DESC
LIMIT 10;


-- 8.3 High-sales but loss-making products
--     Analyst-defined threshold: total sales > 10,000 and
--     total profit < 0.
SELECT
    product_id,
    product_name,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY product_id, product_name
HAVING SUM(sales) > 10000
   AND SUM(profit) < 0
ORDER BY total_profit ASC;


-- 8.4 Top 3 products by profit within each category
WITH product_perf AS (
    SELECT
        category,
        product_id,
        product_name,
        SUM(sales)  AS total_sales,
        SUM(profit) AS total_profit
    FROM superstore
    GROUP BY category, product_id, product_name
),
ranked AS (
    SELECT
        category,
        product_name,
        total_sales,
        total_profit,
        RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS profit_rank
    FROM product_perf
)
SELECT
    category,
    profit_rank,
    product_name,
    ROUND(total_sales, 2)  AS total_sales,
    ROUND(total_profit, 2) AS total_profit
FROM ranked
WHERE profit_rank <= 3
ORDER BY category, profit_rank;


-- ============================================================
-- 9. TIME-SERIES ANALYSIS
-- ============================================================

-- 9.1 Monthly sales and profitability
SELECT
    YEAR(order_date)                         AS order_year,
    MONTH(order_date)                        AS order_month,
    ROUND(SUM(sales), 2)                     AS total_sales,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;


-- 9.2 Highest sales month
SELECT
    YEAR(order_date)     AS order_year,
    MONTH(order_date)    AS order_month,
    ROUND(SUM(sales), 2) AS total_sales
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_sales DESC
LIMIT 1;


-- 9.3 Highest profit month
SELECT
    YEAR(order_date)      AS order_year,
    MONTH(order_date)     AS order_month,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_profit DESC
LIMIT 1;


-- 9.4 Lowest profit month
SELECT
    YEAR(order_date)      AS order_year,
    MONTH(order_date)     AS order_month,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_profit ASC
LIMIT 1;


-- 9.5 Yearly performance with year-over-year growth
WITH yearly AS (
    SELECT
        YEAR(order_date) AS order_year,
        SUM(sales)       AS total_sales,
        SUM(profit)      AS total_profit
    FROM superstore
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    ROUND(total_sales, 2)                               AS total_sales,
    ROUND(total_profit, 2)                              AS total_profit,
    ROUND(total_profit / total_sales * 100, 2)          AS profit_margin_pct,
    ROUND((total_sales - LAG(total_sales) OVER (ORDER BY order_year))
          / LAG(total_sales) OVER (ORDER BY order_year) * 100, 2) AS sales_yoy_pct,
    ROUND((total_profit - LAG(total_profit) OVER (ORDER BY order_year))
          / LAG(total_profit) OVER (ORDER BY order_year) * 100, 2) AS profit_yoy_pct
FROM yearly
ORDER BY order_year;


-- 9.6 Month-over-month sales growth and running total
WITH monthly AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS year_month_label,
        SUM(sales)                       AS monthly_sales
    FROM superstore
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    year_month_label,
    ROUND(monthly_sales, 2) AS monthly_sales,
    ROUND((monthly_sales - LAG(monthly_sales) OVER (ORDER BY year_month_label))
          / LAG(monthly_sales) OVER (ORDER BY year_month_label) * 100, 2) AS mom_growth_pct,
    ROUND(SUM(monthly_sales) OVER (ORDER BY year_month_label), 2)         AS running_total_sales
FROM monthly
ORDER BY year_month_label;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================
