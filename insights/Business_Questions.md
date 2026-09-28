# Business Questions & Insights

> All monetary values are in US dollars. Results are based on the complete Sample Superstore dataset (9,994 records).

## Business Question 1 — Overall Business Performance

### Business Question

What is the overall sales, profit, order volume, customer base, unit volume, and profit margin of the business?

### SQL Approach

We used aggregate functions to calculate the overall business KPIs:

- `COUNT(*)` → total records
- `COUNT(DISTINCT Order ID)` → total orders
- `COUNT(DISTINCT Customer ID)` → total customers
- `SUM(Sales)` → total sales
- `SUM(Profit)` → total profit
- `SUM(Quantity)` → total units sold
- `SUM(Profit) / SUM(Sales)` → overall profit margin

### Result

| KPI | Result |
|---|---:|
| Total Records | 9,994 |
| Total Orders | 5,009 |
| Total Customers | 793 |
| Total Sales | 2,297,200.86 |
| Total Profit | 286,397.02 |
| Total Units Sold | 37,873 |
| Overall Profit Margin | 12.47% |

### Business Insight

The dataset contains 5,009 orders from 793 customers, generating approximately 2.30 million in sales and 286.40K in profit. The overall profit margin is 12.47%, providing a baseline for evaluating performance across categories, regions, customers, products, discounts, and time periods.

---

## Business Question 2 — Category Performance

### Business Question

Which product categories generate the most sales and profit, and how does their profitability compare?

### SQL Approach

We grouped the data by `Category` and calculated:

- `SUM(Sales)` → total sales
- `SUM(Profit)` → total profit
- `SUM(Quantity)` → total units sold
- `SUM(Profit) / SUM(Sales)` → profit margin

The results were then ordered by total profit in descending order.

### Result

| Category | Total Sales | Total Profit | Total Units | Profit Margin |
|---|---:|---:|---:|---:|
| Technology | 836,154.03 | 145,454.95 | 6,939 | 17.40% |
| Office Supplies | 719,047.03 | 122,490.80 | 22,906 | 17.04% |
| Furniture | 741,999.80 | 18,451.27 | 8,028 | 2.49% |

### Business Insight

Technology generates the highest total profit at 145,454.95 and also has the highest profit margin at 17.40%, narrowly ahead of Office Supplies.

Office Supplies has a similar margin of 17.04% and generates 122,490.80 in profit while selling substantially more units than Technology.

Furniture generates 741,999.80 in sales, which is comparable to the other categories, but its profit is only 18,451.27, resulting in a much lower 2.49% profit margin.

This indicates that high sales volume does not necessarily translate into high profitability, making Furniture a category that warrants further investigation.

---

## Business Question 3 — Regional Performance

### Business Question

How does sales and profitability performance vary across different regions?

### SQL Approach

We grouped the data by `Region` and calculated:

- `SUM(Sales)` → total sales
- `SUM(Profit)` → total profit
- `SUM(Profit) / SUM(Sales)` → profit margin
- `AVG(Discount)` → average discount level

The results were ordered by total profit in descending order.

### Result

| Region | Total Sales | Total Profit | Profit Margin | Avg. Discount |
|---|---:|---:|---:|---:|
| West | 725,457.82 | 108,418.45 | 14.94% | 10.93% |
| East | 678,781.24 | 91,522.78 | 13.48% | 14.54% |
| South | 391,721.91 | 46,749.43 | 11.93% | 14.73% |
| Central | 501,239.89 | 39,706.36 | 7.92% | 24.04% |

### Business Insight

Regional performance varies across both sales and profitability. West generates the highest total profit at 108,418.45 and has a 14.94% profit margin.

The Central region generates 501,239.89 in sales, but its profit margin is only 7.92%, the lowest among the four regions. Central also has the highest average discount (24.04%), compared with 10.93% in West. This is an association and does not by itself show that discounting caused the lower margin.

This shows that sales volume alone does not determine regional profitability.

---

## Business Question 4 — Sub-Category Profitability

### Business Question

Which product sub-categories are loss-making, and how significant are their losses?

### SQL Approach

We grouped the data by `Sub-Category` and calculated:

- `SUM(Sales)` → total sales
- `SUM(Profit)` → total profit
- `SUM(Profit) / SUM(Sales)` → profit margin
- `HAVING SUM(Profit) < 0` → filters for loss-making sub-categories

### Result

| Sub-Category | Total Sales | Total Profit | Profit Margin |
|---|---:|---:|---:|
| Tables | 206,965.53 | -17,725.48 | -8.56% |
| Bookcases | 114,880.00 | -3,472.56 | -3.02% |
| Supplies | 46,673.54 | -1,189.10 | -2.55% |

### Business Insight

Three sub-categories are loss-making: Tables, Bookcases, and Supplies.

Tables is the largest loss-making sub-category, generating 206,965.53 in sales but producing a 17,725.48 loss, resulting in a -8.56% profit margin.

Because Tables has the largest loss, we investigated it further in Business Question 5 by comparing its performance across regions and examining average discount levels.

---

## Business Question 5 — Tables Sub-Category Investigation

### Business Question

Why is the Tables sub-category loss-making, and how does its profitability vary across regions?

### SQL Approach

Since Tables was identified as the largest loss-making sub-category in Question 4, we filtered the dataset to Tables and grouped the results by `Region`.

We calculated:

- `SUM(Sales)` → regional sales
- `SUM(Profit)` → regional profit
- `SUM(Profit) / SUM(Sales)` → profit margin
- `AVG(Discount)` → average discount level

### Result

| Region | Total Sales | Total Profit | Profit Margin | Avg. Discount |
|---|---:|---:|---:|---:|
| East | 39,139.81 | -11,025.38 | -28.17% | 37.38% |
| South | 43,916.19 | -4,623.06 | -10.53% | 22.25% |
| Central | 39,154.97 | -3,559.65 | -9.09% | 26.25% |
| West | 84,754.56 | 1,482.61 | 1.75% | 20.00% |

### Business Insight

Tables shows substantial regional variation. The East region has the largest loss at -11,025.38 and the lowest profit margin at -28.17%. It also has the highest average discount at 37.38%.

In contrast, the West region generates 1,482.61 in profit with the lowest average discount among the four regions at 20.00%.

The results show an association between higher average discounts and weaker Tables profitability, but this analysis alone does not establish that discounts caused the losses. This relationship is investigated further in the discount analysis.

---

## Business Question 6 — Discount & Profitability

### Business Question

How does the level of discount relate to sales and profit margins?

### SQL Approach

We created discount bands using a `CASE` expression:

- No Discount → 0%
- Low Discount → >0% to 20%
- Medium Discount → >20% to 40%
- High Discount → >40%

We then calculated total sales, total profit, and profit margin for each band. Profit margin was calculated as `SUM(Profit) / SUM(Sales)` for each band.

### Result

| Discount Band | Records | Sales | Profit | Profit Margin |
|---|---:|---:|---:|---:|
| No Discount | 4,798 | 1,087,908.47 | 320,987.60 | 29.51% |
| Low Discount | 3,803 | 846,522.24 | 100,785.47 | 11.91% |
| Medium Discount | 460 | 234,137.90 | -35,817.47 | -15.30% |
| High Discount | 933 | 128,632.25 | -99,558.59 | -77.40% |

### Business Insight

Profitability declines substantially across the discount bands. Transactions with no discount have a 29.51% profit margin, while the high-discount band has a -77.40% margin.

The 1,393 records discounted above 20% produced a combined loss of about 135.4K.

This demonstrates a strong association between higher discount levels and lower profitability in this dataset. However, the analysis does not establish causation.

---

## Business Question 7 — Average Order Value

### Business Question

What is the average value of an order across the business?

### SQL Approach

We calculated Average Order Value (AOV) by dividing total sales by the number of distinct orders.

### Result

| Metric | Result |
|---|---:|
| Total Orders | 5,009 |
| Total Sales | 2,297,200.86 |
| Average Order Value | 458.61 |

### Business Insight

The average order generates approximately 458.61 in sales. This provides a baseline for comparing order values across customers, regions, categories, or other segments.

---

## Business Question 8 — Customer Performance

### Business Question

Which customers generate the highest sales and which generate the highest profit?

### SQL Approach

We aggregated the dataset at the customer level and calculated sales, profit, order count, AOV, and profit margin.

Two rankings were performed:

1. Customers ranked by total sales
2. Customers ranked by total profit

### Result

**Highest-sales customer:**

| Customer | Orders | Sales | AOV |
|---|---:|---:|---:|
| Sean Miller | 5 | 25,043.05 | 5,008.61 |

**Highest-profit customer:**

| Customer | Sales | Profit | Profit Margin |
|---|---:|---:|---:|
| Tamara Chand | 19,052.22 | 8,981.32 | 47.14% |

### Business Insight

The customer generating the highest sales is not necessarily the customer generating the highest profit.

Sean Miller generated the highest customer-level sales, while Tamara Chand generated the highest total profit. This demonstrates the importance of evaluating revenue and profitability separately when analyzing customer performance.

---

## Business Question 9 — Loss-Making Customers

### Business Question

Which customers generate significant losses despite generating sales?

### SQL Approach

We grouped the data by customer and calculated:

- Total orders
- Total sales
- Total profit
- Profit margin

We then used `HAVING SUM(Profit) < 0` to identify customers whose overall profit was negative and ordered them by total profit to identify the largest losses.

### Result

The most loss-making customer identified was:

| Customer | Orders | Sales | Profit | Profit Margin |
|---|---:|---:|---:|---:|
| Cindy Stewart | 6 | 5,690.06 | -6,626.39 | -116.46% |

Another notable example is Sean Miller, who generated the highest customer-level sales but was still loss-making:

| Customer | Sales | Profit | Profit Margin |
|---|---:|---:|---:|
| Sean Miller | 25,043.05 | -1,980.74 | -7.91% |

### Business Insight

Customer revenue does not necessarily translate into customer profitability. Some customers generate substantial sales while producing an overall loss. This highlights the importance of evaluating both revenue and profit when analyzing customer performance.

---

## Business Question 10 — Customer Sales Concentration

### Business Question

How concentrated are total sales among the top 20% of customers?

### SQL Approach

We used multiple CTEs and window functions to:

1. Calculate total sales for each customer.
2. Rank customers by sales using `ROW_NUMBER()`.
3. Count the total number of customers using `COUNT(*) OVER()`.
4. Identify the top 20% of customers.
5. Calculate their contribution to total sales.

### Result

| Metric | Result |
|---|---:|
| Total Customers | 793 |
| Top 20% Customers | 159 |
| Sales from Top 20% | 1,106,064.33 |
| Total Sales | 2,297,200.86 |
| Sales Contribution | 48.15% |

### Business Insight

The top approximately 20% of customers (159) account for 48.15% of total sales, about 2.4 times their share of the customer base. This is moderate concentration, weaker than a classic 80/20 pattern.

---

## Business Question 11 — Product Performance

### Business Question

Which products generate the highest sales and profit, and which high-sales products are loss-making?

### SQL Approach

We grouped the data by `Product ID` and `Product Name` (some product IDs are shared by different products) and calculated total sales, total profit, and profit margin.

Separate analyses were performed to:

- Rank products by total sales.
- Rank products by total profit.
- Identify products with more than 10,000 in sales but negative profit.

### Result

The Canon imageCLASS 2200 Advanced Copier generated the highest product-level sales:

| Metric | Result |
|---|---:|
| Sales | 61,599.82 |
| Profit | 25,199.93 |
| Profit Margin | 40.91% |

The analysis also identified high-sales products that were loss-making.

Example:

**Cubify CubeX 3D Printer Double Head Print**

| Metric | Result |
|---|---:|
| Sales | 11,099.96 |
| Profit | -8,879.97 |
| Profit Margin | -80.00% |

### Business Insight

Product-level performance varies significantly. Some products generate substantial sales and strong profits, while others generate meaningful sales but produce losses.

Some high-sales products, such as the HON 5400 Series Task Chairs (21,870.58 in sales), break even with zero profit and would not appear in a loss-only filter.

This demonstrates why sales volume alone is insufficient for evaluating product performance.

---

## Business Question 12 — Time-Based Performance

### Business Question

How do sales and profitability change over time, and which months show the highest and lowest performance?

### SQL Approach

We grouped the data by year and month using `YEAR()` and `MONTH()` and calculated:

- Total sales
- Total profit
- Profit margin

Additional queries were used to identify the months with the highest sales, highest profit, and lowest profit.

### Result

| Metric | Month | Result |
|---|---|---:|
| Highest Sales | November 2017 | 118,447.83 |
| Highest Profit | December 2016 | 17,885.31 |
| Lowest Profit | January 2015 | -3,281.01 |

### Business Insight

Monthly performance varies considerably across the dataset. The month with the highest sales was not the same month as the highest profit, demonstrating that revenue and profitability can behave differently over time.
