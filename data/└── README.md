# Dataset

## Source

The dataset used for this project is the **Sample Superstore Dataset**, obtained from Kaggle:

https://www.kaggle.com/datasets/vivek468/superstore-dataset-final

## Dataset Overview

The dataset contains retail transaction records covering:

- Orders
- Customers
- Products
- Categories and sub-categories
- Sales
- Quantity
- Discount
- Profit
- Geographic information
- Order and shipping dates

All monetary values are in US dollars, and the data covers US customers and regions.

## Data Preparation

The dataset was loaded into the `retail_analytics` database in MySQL using a two-stage approach (see section 0 of the SQL script):

1. The CSV was loaded with `LOAD DATA INFILE` into a staging table, `superstore_raw`, where every column is text so that no row is rejected during import.
2. The data was then converted into a typed table, `superstore`:
   - `Order Date` and `Ship Date` were converted from text to `DATE`
   - `Sales`, `Discount` and `Profit` were stored as `DECIMAL`
   - `Postal Code` was kept as text to preserve leading zeros
3. Data quality checks were performed for:
   - Row count reconciliation against the source file
   - Missing values
   - Duplicate Row IDs
   - Negative sales and profit values
   - Date range
4. The final dataset contains **9,994 records** across **21 columns**, covering **2014-01-03 to 2017-12-30**.

## Data Quality Notes

Negative profit values were retained because they represent **loss-making transactions**, which are relevant to the profitability analysis.

No missing values were identified in the key fields checked, and no duplicate `Row ID` values were found.

### Issues found and resolved

- **Row loss on first import:** the MySQL Workbench Import Wizard loaded only 9,694 of 9,994 rows, likely due to column type guessing and non-UTF-8 characters. This was detected by comparing the row count with the maximum Row ID, and resolved by reloading the file with `LOAD DATA` into a text staging table.
- **File encoding:** the CSV is Windows-1252 encoded, so it is loaded with `CHARACTER SET latin1`.
- **Hidden characters:** 225 product names contained non-breaking spaces (U+00A0), which were replaced with normal spaces so identical products group correctly.
- **Shared product IDs:** some product IDs are reused for different products (for example, one ID maps to both a bookcase and a library). Products are therefore grouped by both Product ID and Product Name.

## Data Availability

The raw CSV (`Sample - Superstore.csv`) is not included in this repository. Download it from the Kaggle source above, place it in the folder returned by `SHOW VARIABLES LIKE 'secure_file_priv';`, update the path in section 0.3 of the SQL script, and run the script top to bottom to rebuild the database.
