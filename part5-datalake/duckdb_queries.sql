
-- ====================================================================
-- Q1: List all customers along with the total number of orders they have placed
-- ====================================================================

SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.city,
    c.email,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM 
    read_csv_auto('customers.csv') AS c
LEFT JOIN 
    read_json_auto('orders.json') AS o 
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.name, c.city, c.email
ORDER BY 
    total_orders DESC, total_spent DESC;

/*
EXPLANATION:
- read_csv_auto() automatically detects column types and headers from CSV
- read_json_auto() parses JSON array and infers schema
- LEFT JOIN ensures all customers appear even if they have 0 orders
- COUNT(o.order_id) gives order count per customer
- COALESCE handles NULL totals for customers with no orders
*/


-- ====================================================================
-- Q2: Find the top 3 customers by total order value
-- ====================================================================

SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.city,
    SUM(o.total_amount) AS total_order_value,
    COUNT(o.order_id) AS number_of_orders,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM 
    read_csv_auto('customers.csv') AS c
INNER JOIN 
    read_json_auto('orders.json') AS o 
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.name, c.city
ORDER BY 
    total_order_value DESC
LIMIT 3;

/*
EXPLANATION:
- INNER JOIN filters to only customers who have placed orders
- SUM(total_amount) gives cumulative spending per customer
- AVG provides average order size for customer segmentation insights
- LIMIT 3 returns top spenders only
- Useful for identifying VIP customers for targeted marketing
*/


-- ====================================================================
-- Q3: List all products purchased by customers from Bangalore
-- ====================================================================

-- Note: This query assumes the products.parquet file has columns:
-- product_id, product_name, category, price

SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COUNT(DISTINCT o.order_id) AS times_ordered_from_bangalore,
    SUM(o.num_items) AS total_units_sold_bangalore
FROM 
    read_csv_auto('customers.csv') AS c
INNER JOIN 
    read_json_auto('orders.json') AS o 
    ON c.customer_id = o.customer_id
INNER JOIN 
    read_parquet('products.parquet') AS p 
    ON o.product_id = p.product_id
WHERE 
    c.city = 'Bangalore'
GROUP BY 
    p.product_id, p.product_name, p.category, p.price
ORDER BY 
    times_ordered_from_bangalore DESC, total_units_sold_bangalore DESC;

/*
EXPLANATION:
- read_parquet() reads columnar Parquet files efficiently
- Filters customers by city = 'Bangalore'
- DISTINCT + GROUP BY shows unique products ordered from Bangalore
- times_ordered gives popularity metric for regional preferences
- Useful for regional inventory management and targeted promotions
*/


-- ====================================================================
-- Q4: Join all three files to show: customer name, order date, product name, and quantity
-- ====================================================================

-- This query demonstrates DuckDB's ability to seamlessly join across
-- CSV, JSON, and Parquet formats in a single query

SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.city AS customer_city,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    p.product_name,
    p.category,
    p.price AS unit_price,
    o.num_items AS quantity,
    (p.price * o.num_items) AS line_total
FROM 
    read_csv_auto('customers.csv') AS c
INNER JOIN 
    read_json_auto('orders.json') AS o 
    ON c.customer_id = o.customer_id
INNER JOIN 
    read_parquet('products.parquet') AS p 
    ON o.product_id = p.product_id
WHERE 
    o.status != 'cancelled'
ORDER BY 
    o.order_date DESC, c.customer_id;

/*
EXPLANATION:
- Demonstrates cross-format JOIN: CSV + JSON + Parquet
- Filters out cancelled orders for active transaction analysis
- Calculates line_total (price × quantity) for each order item
- Ordered by most recent orders first
- This query type is typical in data lakes where source data exists
  in multiple formats but needs unified analytical views
*/


-- ====================================================================
-- BONUS QUERY: Data Lake Analytics Example
-- ====================================================================

-- Most valuable product categories by city

SELECT 
    c.city,
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.num_items) AS total_units_sold,
    SUM(p.price * o.num_items) AS total_revenue,
    ROUND(AVG(p.price * o.num_items), 2) AS avg_order_value
FROM 
    read_csv_auto('customers.csv') AS c
INNER JOIN 
    read_json_auto('orders.json') AS o 
    ON c.customer_id = o.customer_id
INNER JOIN 
    read_parquet('products.parquet') AS p 
    ON o.product_id = p.product_id
WHERE 
    o.status IN ('delivered', 'shipped')
GROUP BY 
    c.city, p.category
HAVING 
    total_revenue > 1000
ORDER BY 
    c.city, total_revenue DESC;

/*
BUSINESS VALUE:
- Identifies best-selling product categories by geographic region
- Filters to completed/in-transit orders only (excludes processing/cancelled)
- HAVING clause removes low-revenue category-city combinations
- Enables regional marketing strategies and inventory optimization
*/


