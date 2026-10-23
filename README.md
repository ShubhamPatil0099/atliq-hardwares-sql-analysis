# atliq-hardwares-sql-analysis

# AtliQ Hardwares — Sales and Financial Data Analysis Using SQL

## Project Overview

This project focuses on analyzing business data for AtliQ Hardwares using MySQL.

The analysis explores sales quantities, gross sales, net sales, customer contributions, product performance, and market-level performance. SQL queries are used to combine data from multiple tables, calculate business metrics, and answer business-oriented analytical questions.

The project also demonstrates the use of reusable database objects, including views, stored procedures, and user-defined functions.

## Objectives

* Analyze sales and financial metrics for fiscal year 2021.
* Identify top-performing products and markets.
* Calculate customer contributions to total and regional net sales.
* Segment markets using sales-quantity thresholds.
* Apply SQL techniques to answer business questions.
* Organize analytical logic using reusable database objects.

## Tools and Technologies

* **Database:** MySQL
* **Query Language:** SQL
* **Environment:** MySQL Workbench
* **Data Model:** Relational database
* **Analysis Period:** Fiscal year 2021 for the queries documented here

## Database Tables and Objects

The queries use tables and database objects including:

* `fact_sales_monthly`
* `fact_gross_price`
* `fact_pre_invoice_deductions`
* `dim_product`
* `dim_customer`
* `gross_sales`
* `net_sales`

The database also contains views, stored procedures, and user-defined functions for reusable calculations and analytical operations.

## Business Questions

### 1. Customer-Level Sales Analysis

Retrieve sales quantities, product details, gross prices, and gross sales values for a selected customer during fiscal year 2021.

**SQL concepts:** JOINs, filtering, calculated columns, fiscal-year functions.

### 2. Market Segmentation

Classify markets into Gold and Silver categories based on their total sales quantities.

**SQL concepts:** Aggregation, GROUP BY, conditional logic, JOINs.

### 3. Sales and Discount Analysis

Combine sales quantities, product pricing, and pre-invoice discount percentages to examine sales and discount information.

**SQL concepts:** Multiple JOINs, composite join conditions, filtering.

### 4. Top Five Products by Net Sales

Identify the five products with the highest net sales during fiscal year 2021.

**SQL concepts:** Views, aggregation, sorting, LIMIT.

### 5. Customer Contribution to Net Sales

Calculate customer-level net sales and each customer's percentage contribution to total net sales.

**SQL concepts:** CTEs, aggregation, window functions.

### 6. Regional Customer Contribution

Calculate each customer's percentage contribution to net sales within their region.

**SQL concepts:** CTEs, PARTITION BY, window functions, percentage calculations.

### 7. Top Three Products by Division

Rank products by total quantity sold within each division and identify the top three ranks.

**SQL concepts:** CTEs, DENSE_RANK(), partitioned ranking.

### 8. Top Markets by Regional Gross Sales

Calculate gross sales by market and region, then rank markets within each region.

**SQL concepts:** Aggregation, JOINs, CTEs, DENSE_RANK().

## SQL Skills Demonstrated

* Data retrieval and filtering
* INNER JOINs and multi-table joins
* Aggregate functions
* GROUP BY and ORDER BY
* Conditional logic using IF()
* Common Table Expressions (CTEs)
* Subqueries, where applicable
* Window functions
* DENSE_RANK() and partitioned ranking
* Percentage contribution analysis
* User-defined fiscal-year functions
* Reusable views and stored procedures

## Database Objects

The database includes the following examples of reusable objects, as shown in the development environment:

**Views**

* `gross_sales`
* `net_sales`
* `sales_post_inv_discount`
* `sales_preinv_discount`

**Stored procedures**

* `get_market_badge`
* `get_monthly_gross_sales_for_customer`
* `get_top_n_customer_by_net_sales`
* `get_top_n_market_by_net_sales`
* `get_top_n_product_by_net_sales`
* `get_top_n_products_by_div_and_total_qty`
* `get_top_n_products_per_division_by_qty_sold`

**User-defined functions**

* `get_fiscal_quarter`
* `get_fiscal_year`

These names describe database objects visible in the development environment. Their implementation details and behavior should be documented after inspecting their definitions.

## Key Findings

Key findings will be documented after running and validating the relevant queries.

Examples of metrics to investigate include:

* Products with the highest net sales.
* Customer contributions to total net sales.
* Customer contributions within regions.
* Products with the highest sales quantities within divisions.
* Markets with the highest gross sales within regions.

Numerical results and business interpretations will be added only after verification.

## Repository Structure

The repository contains SQL scripts organized by business question or analytical technique, along with documentation describing the project, methods, and findings.

## How to Run the Queries

1. Set up the required MySQL database.
2. Load the authorized project dataset and required tables.
3. Create or import the necessary views and user-defined functions.
4. Open the SQL scripts in MySQL Workbench.
5. Execute the queries and verify the results.

The required schema, database objects, and dataset must be available for the queries to run successfully.

## Learning Outcomes

This project provided practical experience in writing analytical SQL queries, combining relational data, calculating business metrics, ranking products and markets, and using reusable database objects.

It also strengthened my ability to translate business questions into SQL logic and interpret query results.

## Project Context

This is a learning portfolio project based on the AtliQ Hardwares business-analysis exercises.

The repository documents the SQL analysis, techniques used, and verified findings. Relevant course and dataset sources will be credited where applicable.


## Query Results

### 1. Top Products by Net Sales

Identifies the five products with the highest net sales
during fiscal year 2021.

![Top Products by Net Sales](screenshots/top-products-by-net-sales.png)

### 2. Customer Contribution Analysis

Calculates each customer's percentage contribution to
total net sales.

![Customer Contribution](screenshots/customer-net-sales-contribution.png)

### 3. Top Products by Division

Ranks products by quantity sold within each division.

![Top Products by Division](screenshots/top-products-by-division.png)

### 4. Top Markets by Region

Ranks markets within each region by gross sales.

![Top Markets by Region](screenshots/top-markets-by-region.png)
