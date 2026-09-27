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

## Data Preparation

The dataset was imported into **MySQL Workbench** and loaded into the `superstore` table within the `retail_analytics` database.

During preparation:

1. The dataset was imported using MySQL Workbench.
2. `Order Date` was converted from text format to the MySQL `DATE` data type.
3. Data quality checks were performed for:
   - Missing values
   - Duplicate Row IDs
   - Negative sales values
   - Negative profit values
   - Date range
4. The final dataset contains **9,694 records**.

## Data Quality Notes

Negative profit values were retained because they represent **loss-making transactions**, which are relevant to the profitability analysis.

No missing values were identified in the key fields checked, and no duplicate `Row ID` values were found.

## Data Availability

The raw CSV file is not included in this repository. Please download the dataset directly from the original Kaggle source above.

The SQL analysis in this project is based on the imported and prepared dataset.
