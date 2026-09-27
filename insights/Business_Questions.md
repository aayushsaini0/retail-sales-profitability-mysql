# Business Questions & Insights

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
| Total Records | 9,694 |
| Total Orders | 4,931 |
| Total Customers | 793 |
| Total Sales | 2,272,449.86 |
| Total Profit | 282,857.75 |
| Total Units Sold | 36,749 |
| Overall Profit Margin | 12.45% |

### Business Insight

The dataset contains 4,931 orders from 793 customers, generating approximately 2.27 million in sales and 282.86K in profit. The overall profit margin is 12.45%, providing a baseline for evaluating performance across categories, regions, customers, products, discounts, and time periods.

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
| Technology | 835,900.07 | 145,387.10 | 6,904 | 17.39% |
| Office Supplies | 703,502.93 | 120,489.89 | 21,990 | 17.13% |
| Furniture | 733,046.86 | 16,980.77 | 7,855 | 2.32% |

### Business Insight

Technology generates the highest total profit at 145,387.10 and also has the highest profit margin at 17.39%.

Office Supplies has a similar margin of 17.13% and generates 120,489.89 in profit while selling substantially more units than Technology.

Furniture generates 733,046.86 in sales, which is comparable to the other categories, but its profit is only 16,980.77, resulting in a much lower 2.32% profit margin.

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

The results were ordered by total profit in descending order.

### Result

| Region | Total Sales | Total Profit | Profit Margin |
|---|---:|---:|---:|
| West | 713,471.34 | 106,021.15 | 14.86% |
| East | 672,194.05 | 90,672.01 | 13.49% |
| South | 388,983.59 | 46,035.69 | 11.83% |
| Central | 497,800.87 | 40,128.90 | 8.06% |

### Business Insight

Regional performance varies across both sales and profitability. West generates the highest total profit at 106,021.15 and has a 14.86% profit margin.

The Central region generates 497,800.87 in sales, but its profit margin is only 8.06%, the lowest among the four regions.

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
| Supplies | 45,952.47 | -1,348.57 | -2.93% |

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
| East | 39,139.81 | -11,025.38 | -28.17% | 37.37% |
| South | 43,916.19 | -4,623.06 | -10.53% | 22.25% |
| Central | 39,154.97 | -3,559.65 | -9.09% | 26.25% |
| West | 84,754.56 | 1,482.61 | 1.75% | 20.00% |

### Business Insight

Tables shows substantial regional variation. The East region has the largest loss at -11,025.38 and the lowest profit margin at -28.17%. It also has the highest average discount at 37.37%.

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

We then calculated total sales, total profit, and profit margin for each band.

### Result

| Discount Band | Records | Sales | Profit | Profit Margin |
|---|---:|---:|---:|---:|
| No Discount | 4,657 | 1,072,777.32 | 317,184.04 | 29.57% |
| Low Discount | 3,693 | 838,235.31 | 99,827.47 | 11.91% |
| Medium Discount | 459 | 234,065.97 | -35,825.86 | -15.31% |
| High Discount | 885 | 127,371.25 | -98,327.91 | -77.20% |

### Business Insight

Profitability declines substantially across the discount bands. Transactions with no discount have a 29.57% profit margin, while the high-discount band has a -77.20% margin.

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
| Total Orders | 4,931 |
| Total Sales | 2,272,449.86 |
| Average Order Value | 460.85 |

### Business Insight

The average order generates approximately 460.85 in sales. This provides a baseline for comparing order values across customers, regions, categories, or other segments.

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
| Tamara Chand | 19,017.85 | 8,964.48 | 47.14% |

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
| Sales from Top 20% | 1,096,133.32 |
| Total Sales | 2,272,449.86 |
| Sales Contribution | 48.24% |

### Business Insight

The top approximately 20% of customers account for 48.24% of total sales. This indicates that a relatively small portion of the customer base contributes a substantial share of overall revenue.

---

## Business Question 11 — Product Performance

### Business Question

Which products generate the highest sales and profit, and which high-sales products are loss-making?

### SQL Approach

We grouped the data by `Product Name` and calculated total sales, total profit, and profit margin.

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
| Highest Sales | November 2017 | 117,383.38 |
| Highest Profit | December 2016 | 17,547.22 |
| Lowest Profit | January 2015 | -3,291.02 |

### Business Insight

Monthly performance varies considerably across the dataset. The month with the highest sales was not the same month as the highest profit, demonstrating that revenue and profitability can behave differently over time.
