# Retail Sales & Profitability Analysis Using MySQL

## Project Overview

This project analyzes retail sales and profitability data using MySQL to answer practical business questions related to revenue, profit margins, customers, products, discounts, regions, and time-based performance.

The analysis was performed on the Sample Superstore dataset and focuses on using SQL to transform raw transactional data into business-relevant insights.

## Business Objective

The objective of this project is to understand:

- Overall sales and profitability performance
- Category and sub-category performance
- Regional differences in sales and profitability
- The relationship between discount levels and profitability
- Customer sales and profitability patterns
- Customer sales concentration
- Product-level sales and profitability
- High-sales but loss-making products
- Monthly sales and profitability trends

---

## Dataset

**Dataset:** Sample Superstore

The dataset contains retail order-level transaction data including:

- Order and customer information
- Product categories and sub-categories
- Geographic information
- Sales
- Quantity
- Discount
- Profit
- Order dates

### Dataset Statistics

| Metric | Value |
|---|---:|
| Records | 9,694 |
| Orders | 4,931 |
| Customers | 793 |
| Units Sold | 36,749 |
| Total Sales | ₹2,272,449.86 |
| Total Profit | ₹282,857.75 |
| Overall Profit Margin | 12.45% |
| Date Range | 2014-01-04 to 2017-12-30 |

The original `Order Date` field was imported as text and converted to the `DATE` data type before performing time-series analysis.

---

## Tools & Technologies

- **MySQL**
- **MySQL Workbench**
- **SQL**
- Sample Superstore Dataset

### SQL Concepts Used

- `SELECT`
- `WHERE`
- `GROUP BY`
- `HAVING`
- Aggregate functions
- `CASE` expressions
- `ORDER BY`
- `LIMIT`
- Date functions
- Common Table Expressions (CTEs)
- Window functions
- `ROW_NUMBER()`
- `COUNT() OVER()`
- `CEIL()`
- `CROSS JOIN`
- Conditional filtering
- Profit-margin calculations

---

## Analysis & Business Questions

### 1. What is the overall sales and profitability performance?

The dataset generated:

- ₹2.27M in total sales
- ₹282.86K in total profit
- 12.45% overall profit margin

### 2. Which product categories perform best?

Technology generated the highest total profit at **₹145,387.10** and had the highest category-level profit margin at **17.39%**.

Furniture generated substantial sales but had a significantly lower profit margin of **2.32%**.

### 3. Which regions perform best?

The West region generated the highest sales and profit:

- Sales: **₹713,471.34**
- Profit: **₹106,021.15**
- Profit Margin: **14.86%**

Central had the lowest regional profit margin at **8.06%**.

### 4. Which sub-categories are loss-making?

Three sub-categories generated negative total profit:

| Sub-Category | Total Profit |
|---|---:|
| Tables | -₹17,725.48 |
| Bookcases | -₹3,472.56 |
| Supplies | -₹1,348.57 |

Tables was the largest absolute loss-making sub-category.

### 5. How does discounting relate to profitability?

The analysis found a strong association between higher discount bands and lower aggregate profitability.

| Discount Band | Profit Margin |
|---|---:|
| No Discount | 29.57% |
| Low Discount | 11.91% |
| Medium Discount | -15.31% |
| High Discount | -77.20% |

For the Tables sub-category, profitability also declined substantially as discount levels increased.

These results represent observed relationships in the dataset and do not establish causation.

### 6. What is the Average Order Value?

The average order value was:

**₹460.85**

The calculation uses distinct orders rather than transaction rows because the dataset contains multiple records per order.

### 7. Which customers generate the most sales and profit?

The highest-sales customer generated:

**₹25,043.05 in sales**

while the highest-profit customer generated:

**₹8,964.48 in profit**.

This demonstrates that sales volume and profitability can differ at the customer level.

### 8. Are any high-sales customers loss-making?

Yes.

For example, the highest-sales customer generated:

- Sales: **₹25,043.05**
- Profit: **-₹1,980.74**
- Profit Margin: **-7.91%**

This demonstrates why customer evaluation should consider profitability rather than sales alone.

### 9. How concentrated are customer sales?

The analysis ranked all **793 customers** by total sales.

The top approximately **20% (159 customers)** generated:

**₹1,096,133.32**, representing **48.24% of total sales**.

This indicates meaningful concentration of sales among the highest-value customers.

### 10. Which products generate the most sales and profit?

Product-level analysis was used to identify the top products by:

- Total sales
- Total profit
- Profit margin

The analysis also compared sales leadership with profitability to identify cases where high sales did not necessarily translate into positive profit.

### 11. Are there high-sales but loss-making products?

Products with:

- **Sales > ₹10,000**
- **Total Profit < ₹0**

were identified for further investigation.

The analysis identified **8 products** meeting these criteria.

One example was the Cubify CubeX 3D Printer Double Head Print:

- Sales: **₹11,099.96**
- Profit: **-₹8,879.97**
- Profit Margin: **-80.00%**

### 12. How does sales and profitability performance change over time?

Monthly analysis was performed using the converted `Order Date` field.

| Metric | Month | Value |
|---|---|---:|
| Highest Sales | November 2017 | ₹117,383.38 |
| Highest Profit | December 2016 | ₹17,547.22 |
| Lowest Profit | January 2015 | -₹3,291.02 |

The highest-sales month and highest-profit month were different, demonstrating that revenue and profitability should be evaluated separately.

---

## Key Findings

1. **Technology** generated the highest category-level profit and margin.
2. **Furniture** generated substantial sales but had a low **2.32% profit margin**.
3. **West** was the highest-performing region by sales, profit, and margin.
4. **Tables** was the largest loss-making sub-category.
5. Higher discount bands were associated with substantially lower aggregate profit margins.
6. The top approximately **20% of customers generated 48.24% of total sales**.
7. High sales at the customer or product level did not always correspond to positive profitability.
8. Monthly sales and profitability showed different peaks, reinforcing the need to track both metrics.

---

## Repository Structure

```text
retail-sales-profitability-mysql/
│
├── README.md
│
├── sql/
│   └── Retail_Sales_Profitability_Analysis.sql
│
├── data/
│   └── README.md
│
└── insights/
    └── Business_Questions.md
