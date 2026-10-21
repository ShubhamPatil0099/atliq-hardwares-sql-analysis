/*
===============================================================================
PROJECT: AtliQ Hardwares - Sales and Financial Data Analysis
DATABASE: MySQL
ENVIRONMENT: MySQL Workbench

PURPOSE
-------
This script contains selected SQL analyses based on the queries shared for the
AtliQ Hardwares learning project. The business questions below are inferred
from the SQL logic; they may not be the original course questions.

IMPORTANT
---------
1. Run these queries only after the required database tables, views, and
   functions are available in your MySQL environment.
2. This script does not contain invented results. Run each query and record
   findings from the actual output.
3. Check the schema and join relationships before using results in a portfolio.
4. The gross-sales calculations assume fact_gross_price contains the applicable
   gross price for each product and fiscal year.
===============================================================================
*/


/* ============================================================================
   QUERY 1: CUSTOMER-LEVEL PRODUCT SALES ANALYSIS
   Business question:
   What were the sales quantities and estimated gross sales values for each
   product purchased by customer 90002002 during fiscal year 2021?

   Concepts:
   JOINs, filtering, calculated columns, sorting, user-defined fiscal-year
   function.

   Note:
   Gross sales here are calculated as sold quantity multiplied by unit gross
   price. This is not net sales and does not deduct discounts.
============================================================================ */

SELECT
    s.date,
    s.product_code,
    p.product,
    p.variant,
    s.sold_quantity,
    g.gross_price AS gross_price_per_item,
    ROUND(g.gross_price * s.sold_quantity, 2) AS gross_sales_amount
FROM fact_sales_monthly AS s
JOIN dim_product AS p
    ON p.product_code = s.product_code
JOIN fact_gross_price AS g
    ON g.product_code = s.product_code
    AND g.fiscal_year = get_fiscal_year(s.date)
WHERE s.customer_code = 90002002
    AND get_fiscal_year(s.date) = 2021
ORDER BY s.date ASC
LIMIT 1000000;


/* ============================================================================
   QUERY 2: MARKET SEGMENTATION BY SALES QUANTITY
   Business question:
   Which markets exceeded 5,000,000 units sold in fiscal year 2021, and which
   fell below that threshold?

   Concepts:
   JOIN, SUM, GROUP BY, conditional logic using IF.

   Note:
   This rule assigns 'Gold' to markets above 5,000,000 units and 'Silver' to
   all other markets. These are labels defined by this query, not verified
   company-wide business rules.
============================================================================ */

SELECT
    c.market,
    SUM(s.sold_quantity) AS total_qty,
    IF(
        SUM(s.sold_quantity) > 5000000,
        'Gold',
        'Silver'
    ) AS out_badge
FROM fact_sales_monthly AS s
JOIN dim_customer AS c
    ON c.customer_code = s.customer_code
WHERE s.fiscal_year = 2021
GROUP BY c.market
ORDER BY total_qty DESC;


/* ============================================================================
   QUERY 3: SALES, PRODUCT PRICING, AND PRE-INVOICE DISCOUNT
   Business question:
   What were the sales quantities, gross sales values, and pre-invoice discount
   percentages associated with sales records in fiscal year 2021?

   Concepts:
   Multiple JOINs, calculated columns, fiscal-year filtering.

   Note:
   This query retrieves the discount percentage but does not calculate a
   discounted sales amount.
============================================================================ */

SELECT
    s.date,
    s.fiscal_year,
    s.customer_code,
    s.product_code,
    p.product,
    p.variant,
    s.sold_quantity,
    g.gross_price AS gross_price_per_item,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_sales_amount,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly AS s
JOIN dim_product AS p
    ON p.product_code = s.product_code
JOIN fact_gross_price AS g
    ON g.product_code = s.product_code
    AND g.fiscal_year = s.fiscal_year
JOIN fact_pre_invoice_deductions AS pre
    ON pre.customer_code = s.customer_code
    AND pre.fiscal_year = s.fiscal_year
WHERE s.fiscal_year = 2021;


/* ============================================================================
   QUERY 4: ENRICH SALES RECORDS WITH CUSTOMER, PRODUCT, AND PRICE DETAILS
   Business question:
   How can sales records be combined with customer, product, and gross-price
   information to calculate gross sales amounts?

   Concepts:
   Multiple JOINs, calculated columns, relational data analysis.

   Note:
   This is a row-level query. It does not aggregate the data by customer or
   product. Fiscal-year matching is included in the price join.
============================================================================ */

SELECT
    s.date,
    s.fiscal_year,
    s.customer_code,
    c.customer,
    c.market,
    s.product_code,
    p.product,
    p.variant,
    s.sold_quantity,
    g.gross_price AS gross_price_per_item,
    ROUND(s.sold_quantity * g.gross_price, 2) AS gross_sales_amount
FROM fact_sales_monthly AS s
JOIN dim_product AS p
    ON s.product_code = p.product_code
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
JOIN fact_gross_price AS g
    ON g.product_code = s.product_code
    AND g.fiscal_year = s.fiscal_year;


/* ============================================================================
   QUERY 5: TOP FIVE PRODUCTS BY NET SALES
   Business question:
   Which five products generated the highest net sales in fiscal year 2021?

   Concepts:
   Querying a view, SUM, GROUP BY, ORDER BY, LIMIT.

   Dependency:
   Assumes the net_sales view exists and exposes product, net_sales, and
   fiscal_year fields.
============================================================================ */

SELECT
    product,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM net_sales
WHERE fiscal_year = 2021
GROUP BY product
ORDER BY net_sales_mln DESC
LIMIT 5;


/* ============================================================================
   QUERY 6: CUSTOMER CONTRIBUTION TO TOTAL NET SALES
   Business question:
   How much net sales did each customer generate, and what percentage of total
   net sales did each customer contribute in fiscal year 2021?

   Concepts:
   CTE, JOIN, aggregation, window function, percentage calculation.

   Dependency:
   Assumes the net_sales view exposes customer_code, net_sales, and fiscal_year.
============================================================================ */

WITH customer_sales AS (
    SELECT
        c.customer,
        ROUND(SUM(ns.net_sales) / 1000000, 2) AS net_sales_mln
    FROM net_sales AS ns
    JOIN dim_customer AS c
        ON c.customer_code = ns.customer_code
    WHERE ns.fiscal_year = 2021
    GROUP BY c.customer
)
SELECT
    customer,
    net_sales_mln,
    ROUND(
        net_sales_mln * 100.0 / NULLIF(SUM(net_sales_mln) OVER (), 0),
        2
    ) AS pct_of_total_net_sales
FROM customer_sales
ORDER BY net_sales_mln DESC;


/* ============================================================================
   QUERY 7: CUSTOMER CONTRIBUTION TO NET SALES WITHIN EACH REGION
   Business question:
   What percentage of net sales within each region came from each customer
   during fiscal year 2021?

   Concepts:
   CTE, JOIN, GROUP BY, window function with PARTITION BY.

   Note:
   The percentage is calculated against the total of the customer-level
   net_sales_mln values in each region.
============================================================================ */

WITH customer_region_sales AS (
    SELECT
        c.customer,
        c.region,
        SUM(ns.net_sales) / 1000000.0 AS net_sales_mln
    FROM net_sales AS ns
    JOIN dim_customer AS c
        ON c.customer_code = ns.customer_code
    WHERE ns.fiscal_year = 2021
    GROUP BY
        c.customer,
        c.region
)
SELECT
    customer,
    region,
    ROUND(net_sales_mln, 2) AS net_sales_mln,
    ROUND(
        net_sales_mln * 100.0
        / NULLIF(SUM(net_sales_mln) OVER (PARTITION BY region), 0),
        2
    ) AS pct_share_region
FROM customer_region_sales
ORDER BY region, net_sales_mln DESC;


/* ============================================================================
   QUERY 8: TOP THREE PRODUCTS BY QUANTITY SOLD WITHIN EACH DIVISION
   Business question:
   Which products ranked in the top three by total quantity sold within each
   division during fiscal year 2021?

   Concepts:
   CTEs, SUM, GROUP BY, DENSE_RANK, PARTITION BY.

   Note:
   DENSE_RANK preserves ties. Therefore, a division may return more than three
   products when multiple products share a rank.
============================================================================ */

WITH division_product_qty AS (
    SELECT
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_qty
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY
        p.division,
        p.product
),
ranked_products AS (
    SELECT
        division,
        product,
        total_qty,
        DENSE_RANK() OVER (
            PARTITION BY division
            ORDER BY total_qty DESC
        ) AS product_rank
    FROM division_product_qty
)
SELECT
    division,
    product,
    total_qty,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY division, product_rank, product;


/* ============================================================================
   QUERY 9: TOP TWO MARKETS BY GROSS SALES WITHIN EACH REGION
   Business question:
   Which markets ranked highest by gross sales within each region during
   fiscal year 2021?

   Concepts:
   CTEs, JOINs, aggregation, DENSE_RANK, PARTITION BY.

   Calculation:
   Gross sales amount = sold quantity * gross price per item.

   Validation:
   This assumes each product/fiscal-year pair matches one appropriate gross
   price row. Verify the table's grain and join cardinality in your schema.
============================================================================ */

WITH market_sales AS (
    SELECT
        c.market,
        c.region,
        SUM(s.sold_quantity * g.gross_price) / 1000000.0 AS gross_sales_mln
    FROM fact_sales_monthly AS s
    JOIN dim_customer AS c
        ON s.customer_code = c.customer_code
    JOIN fact_gross_price AS g
        ON g.product_code = s.product_code
        AND g.fiscal_year = s.fiscal_year
    WHERE s.fiscal_year = 2021
    GROUP BY
        c.market,
        c.region
),
ranked_markets AS (
    SELECT
        market,
        region,
        gross_sales_mln,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY gross_sales_mln DESC
        ) AS market_rank
    FROM market_sales
)
SELECT
    market,
    region,
    ROUND(gross_sales_mln, 2) AS gross_sales_mln,
    market_rank
FROM ranked_markets
WHERE market_rank <= 2
ORDER BY region, market_rank, market;
