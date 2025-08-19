/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Retrieve all columns for a specific table (dim_customers)
SELECT * FROM gold.dim_customers



/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT nullif(country,'n/a')
FROM gold.dim_customers
WHERE nullif(country,'n/a') IS NOT NULL

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT
product_name,
category,
subcategory
FROM gold.dim_products





/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT 
min(order_date) last_order_date,
max(order_date) first_order_date,
DATEDIFF(Month,min(order_date), max(order_date)) Duration
FROM gold.fact_sales

-- Find the youngest and oldest customer based on birthdate

SELECT 
min(birthdate) as oldest_customer,
max(birthdate) as youngest_customer
FROM gold.dim_customers

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
--SELECT Sales_amount * quantity * price as Total_sales
SELECT SUM(Sales_amount) Total_sales
FROM gold.fact_sales


-- Find how many items are sold
SELECT COUNT( DISTINCT product_key) as uniqe_items FROM gold.fact_sales

-- Find the average selling price
SELECT AVG(price) as AVG_price FROM gold.fact_sales

-- Find the Total number of Orders
SELECT COUNt(DISTINCT order_number) TOTAL_Orders FROM gold.fact_sales

-- Find the total number of products
SELECT COUNT( DISTINCT product_key ) as total_products FROM gold.dim_products

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_id) total_customers  FROM gold.dim_customers

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT c.customer_id) Total_customers
FROM gold.dim_customers c
JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS Measure_name , SUM(Sales_amount) as Measure_value FROM gold.fact_sales
Union ALL
SELECT 'Total Sold Items' AS Measure_name , COUNT( DISTINCT product_key) as Measure_value FROM gold.fact_sales
UNION ALL
SELECT 'AVG_Selling_Price' AS Measure_name , AVG(price) as Measure_value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL Orders' AS Measure_name , COUNt(DISTINCT order_number) Measure_value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL Products' AS Measure_name , COUNT( DISTINCT product_key ) as Measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS Measure_name, COUNT(DISTINCT customer_id) Measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Ordred Customers' AS Measure_name, COUNT(DISTINCT Customer_key) Measure_value FROM gold.fact_sales


/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
SELECT country
,COUNt(DISTINCT customer_key) as total_customers
FROM gold.dim_customers
GROUP BY country
HAVING country != 'n/a'

-- Find total customers by gender
SELECT gender,
COUNT(DISTINCT customer_key) Total_customers
FROM gold.dim_customers
GROUP BY gender
HAVING gender != 'n/a'


-- Find total products by category
SELECT category,
COUNT( DISTINCT product_key) Total_prducts
From gold.dim_products
GROUP BY category
Having category IS NOT NULL

-- What is the average costs in each category?
SELECT category,
AVG(cost) Avg_Cost
FROM gold.dim_products
GROUP BY category
Having category IS NOT NULL

-- What is the total revenue generated for each category?
SELECT p.category,
SUM(s.sales_amount) Total_revenue
FROM gold.fact_sales s
JOIN gold.dim_products p
ON p.product_key = s.product_key
GROUP BY p.category


-- What is the total revenue generated by each customer?

SELECT c.customer_number Customer,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_number


-- What is the distribution of sold items across countries?
SELECT c.country,
COUNT(DISTINCT f.product_key) Sold_Items
FROM gold.dim_customers c
JOIN gold.fact_sales f
ON c.customer_key = f.customer_key
GROUP BY c.country
HaVING c.country != 'n/a'


/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Ranking Functions: TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
SELECT  top 5 p.product_name,
SUM(f.sales_amount) Total_revenue
FROM gold.dim_products p
JOIN gold.fact_sales f
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount) DESC

-- What are the 5 worst-performing products in terms of sales?
SELECT  top 5 p.product_name,
SUM(f.sales_amount) Total_revenue
FROM gold.dim_products p
JOIN gold.fact_sales f
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(f.sales_amount) 

-- Find the top 10 customers who have generated the highest revenue
SELECT  top 10 c.customer_number, 
SUM(f.sales_amount) Total_revenue
FROM gold.dim_customers c
JOIN gold.fact_sales f
ON f.customer_key = c.customer_key
GROUP BY c.customer_number 
ORDER BY SUM(f.sales_amount) DESC



-- The 3 customers with the fewest orders placed
SELECT TOP 3 c.customer_number Cutomer,
COUNT( DISTINCT f.order_number) No_of_Orders
FROM gold.dim_customers c
JOIN gold.fact_sales f
ON f.customer_key = c.customer_key
GROUP BY c.customer_number
ORDER BY COUNT( DISTINCT f.order_number) 



--SELECT top 3 c.customer_number Cutomer,
--SUM(f.Sales_amount) Total_revenue
--FROM gold.dim_customers c
--JOIN gold.fact_sales f
--ON f.customer_key= c.customer_key
--GROUP BY c.customer_number
--ORDER BY SUM(f.Sales_amount) 

