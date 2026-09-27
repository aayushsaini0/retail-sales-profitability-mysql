-- ============================================================
-- RETAIL SALES & PROFITABILITY ANALYSIS
-- ============================================================
-- Database: retail_analytics
-- Table: superstore
-- Tool: MySQL
--
-- Objective:
-- Analyze retail sales, profitability, customers, products,
-- discounts, regions and time-based performance to identify
-- key business insights and areas of concern.
-- ============================================================


-- ============================================================
-- 0. DATABASE & DATA SETUP
-- ============================================================

-- 0.1 Create Database

CREATE DATABASE retail_analytics;

USE retail_analytics;


-- 0.2 Import Dataset
--
-- The Sample Superstore CSV dataset was loaded into the
-- `superstore` table using MySQL Workbench's Table Data
-- Import Wizard.
--
-- The imported dataset was then prepared and analyzed
-- using MySQL.


-- 0.3 Data Preparation
--
-- The original `Order Date` column was imported as TEXT.
-- It was converted to the DATE data type during data
-- preparation so that time-series analysis could be performed.
--
-- Final verified date range:
-- 2014-01-04 to 2017-12-30


-- ============================================================
-- 1. DATA VALIDATION
-- ============================================================


-- 1.1 Total number of records
SELECT
    COUNT(*) AS Total_Records
FROM superstore;


-- 1.2 Total number of unique orders
SELECT
    COUNT(DISTINCT `Order ID`) AS Total_Orders
FROM superstore;


-- 1.3 Total number of unique customers
SELECT
    COUNT(DISTINCT `Customer ID`) AS Total_Customers
FROM superstore;


-- 1.4 Check for missing values in important columns
SELECT
    SUM(CASE WHEN `Order ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Order_ID,
    SUM(CASE WHEN `Customer ID` IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Missing_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Missing_Profit,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Missing_Quantity,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Date
FROM superstore;


-- 1.5 Check for duplicate Row IDs
SELECT
    `Row ID`,
    COUNT(*) AS Record_Count
FROM superstore
GROUP BY `Row ID`
HAVING COUNT(*) > 1;


-- 1.6 Check for negative sales values
SELECT
    COUNT(*) AS Negative_Sales_Records
FROM superstore
WHERE Sales < 0;


-- 1.7 Check for negative profit values
SELECT
    COUNT(*) AS Negative_Profit_Records
FROM superstore
WHERE Profit < 0;


-- 1.8 Check the date range
SELECT
    MIN(`Order Date`) AS Earliest_Order_Date,
    MAX(`Order Date`) AS Latest_Order_Date
FROM superstore;


-- ============================================================
-- NOTE ON DATA CLEANING
-- ============================================================
-- The original `Order Date` column was stored as TEXT.
-- It was converted to the DATE data type before performing
-- time-series analysis.
--
-- Final verified date range:
-- 2014-01-04 to 2017-12-30
--
-- The conversion process was performed separately during
-- data preparation and is not included as an executable
-- transformation here because the final table already contains
-- the corrected DATE column.
-- ============================================================



-- ============================================================
-- 2. OVERALL BUSINESS KPIs
-- Purpose: Establish the overall sales, profitability,
--          order, customer, and unit-level baseline.
-- ============================================================


SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Units,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Overall_Profit_Margin
FROM superstore;



-- ============================================================
-- 3. CATEGORY ANALYSIS
-- Purpose: Compare sales, profit, units, and profit margin
--          across product categories.
-- ============================================================


SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Units,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY Category
ORDER BY Total_Profit DESC;



-- ============================================================
-- 4. REGIONAL ANALYSIS
-- Purpose: Compare sales, profit, profit margin, and
--          average discount across regions.
-- ============================================================


SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY Region
ORDER BY Total_Profit DESC;



-- ============================================================
-- 5. SUB-CATEGORY ANALYSIS
-- ============================================================


-- 5.1 Sub-Category Performance
-- Identify the most and least profitable sub-categories.

SELECT
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Units,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY `Sub-Category`
ORDER BY Total_Profit DESC;


-- 5.2 Loss-Making Sub-Categories
-- Identify sub-categories generating negative total profit.

SELECT
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- 5.3 Tables Performance by Region
-- Investigate regional profitability of the Tables sub-category.

SELECT
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Percent
FROM superstore
WHERE `Sub-Category` = 'Tables'
GROUP BY Region
ORDER BY Total_Profit ASC;



-- ============================================================
-- 6. DISCOUNT ANALYSIS
-- ============================================================


-- 6.1 Discount Band Analysis
-- Classify records into discount bands and compare
-- their sales and profitability.

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS Discount_Band,
    COUNT(*) AS Total_Records,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY Discount_Band
ORDER BY Total_Profit DESC;


-- 6.2 Tables Discount Band Analysis
-- Examine how discount bands relate to profitability
-- specifically within the loss-making Tables sub-category.

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS Discount_Band,
    COUNT(*) AS Total_Records,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Percent
FROM superstore
WHERE `Sub-Category` = 'Tables'
GROUP BY Discount_Band
ORDER BY Total_Profit DESC;


-- 6.3 Tables Performance by Exact Discount Level
-- Examine profitability at each observed discount level.

SELECT
    ROUND(Discount * 100, 0) AS Discount_Percent,
    COUNT(*) AS Record_Count,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
WHERE `Sub-Category` = 'Tables'
GROUP BY Discount
ORDER BY Discount;



-- ============================================================
-- 7. CUSTOMER ANALYSIS
-- ============================================================


-- 7.1 Average Order Value (AOV)
-- Calculate average sales value per unique order.

SELECT
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Sales) / COUNT(DISTINCT `Order ID`),
        2
    ) AS Average_Order_Value
FROM superstore;


-- 7.2 Top Customers by Sales
-- Identify customers generating the highest sales.

SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(
        SUM(Sales) / COUNT(DISTINCT `Order ID`),
        2
    ) AS Average_Order_Value
FROM superstore
GROUP BY
    `Customer ID`,
    `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;


-- 7.3 Top Customers by Profit
-- Identify customers generating the highest total profit.

SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        (SUM(Profit) / SUM(Sales)) * 100,
        2
    ) AS Profit_Margin
FROM superstore
GROUP BY
    `Customer ID`,
    `Customer Name`
ORDER BY Total_Profit DESC
LIMIT 10;


-- 7.4 Loss-Making Customers
-- Identify customers generating negative total profit.

SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        (SUM(Profit) / SUM(Sales)) * 100,
        2
    ) AS Profit_Margin
FROM superstore
GROUP BY
    `Customer ID`,
    `Customer Name`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC
LIMIT 10;


-- 7.5 Customer Sales Concentration
-- Purpose: Measure the share of total sales generated by the
--          top approximately 20% of customers.

WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM superstore
    GROUP BY `Customer ID`, `Customer Name`
),

ranked_customers AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        Total_Sales,
        ROW_NUMBER() OVER (ORDER BY Total_Sales DESC) AS Customer_Rank,
        COUNT(*) OVER () AS Total_Customers
    FROM customer_sales
),

top_customers AS (
    SELECT
        SUM(Total_Sales) AS Top_20_Sales
    FROM ranked_customers
    WHERE Customer_Rank <= CEIL(Total_Customers * 0.20)
),

total_sales AS (
    SELECT
        SUM(Total_Sales) AS Total_Sales
    FROM customer_sales
)

SELECT
    ROUND(Top_20_Sales, 2) AS Top_20_Sales,
    ROUND((Top_20_Sales / Total_Sales) * 100, 2) AS Sales_Contribution_Percent
FROM top_customers
CROSS JOIN total_sales;



-- ============================================================
-- 8. PRODUCT ANALYSIS
-- ============================================================


-- 8.1 Top 10 Products by Sales

SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        (SUM(Profit) / SUM(Sales)) * 100,
        2
    ) AS Profit_Margin
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;


-- 8.2 Top 10 Products by Profit

SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        (SUM(Profit) / SUM(Sales)) * 100,
        2
    ) AS Profit_Margin
FROM superstore
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;


-- 8.3 High-Sales but Loss-Making Products
-- Analyst-defined threshold: Sales > 10,000
-- and total profit below zero.

SELECT
    `Product Name`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY `Product Name`
HAVING
    SUM(Sales) > 10000
    AND SUM(Profit) < 0
ORDER BY Total_Profit ASC;



-- ============================================================
-- 9. TIME-SERIES ANALYSIS
-- ============================================================


-- 9.1 Monthly Sales and Profitability
-- Analyze sales, profit and margin over time.

SELECT
    YEAR(`Order Date`) AS Order_Year,
    MONTH(`Order Date`) AS Order_Month,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin
FROM superstore
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY Order_Year, Order_Month;


-- 9.2 Highest Sales Month

SELECT
    YEAR(`Order Date`) AS Order_Year,
    MONTH(`Order Date`) AS Order_Month,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM superstore
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY Total_Sales DESC
LIMIT 1;


-- 9.3 Highest Profit Month

SELECT
    YEAR(`Order Date`) AS Order_Year,
    MONTH(`Order Date`) AS Order_Month,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY Total_Profit DESC
LIMIT 1;


-- 9.4 Lowest Profit Month

SELECT
    YEAR(`Order Date`) AS Order_Year,
    MONTH(`Order Date`) AS Order_Month,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore
GROUP BY
    YEAR(`Order Date`),
    MONTH(`Order Date`)
ORDER BY Total_Profit ASC
LIMIT 1;


-- ============================================================
-- END OF ANALYSIS
-- ============================================================