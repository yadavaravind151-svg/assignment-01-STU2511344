-- ====================================================================
-- BUSINESS QUERIES - RETAIL COMPANY DATABASE
-- ====================================================================
-- These queries demonstrate how the normalized schema makes
-- querying easier and more efficient
-- ====================================================================

-- Q1: List all customers from Mumbai along with their total order value
SELECT 
    c.customer_id,
    c.customer_name,
    c.customer_email,
    c.customer_city,
    SUM(oi.quantity * p.unit_price) AS total_order_value
FROM 
    Customers c
    INNER JOIN Orders o ON c.customer_id = o.customer_id
    INNER JOIN Order_Items oi ON o.order_id = oi.order_id
    INNER JOIN Products p ON oi.product_id = p.product_id
WHERE 
    c.customer_city = 'Mumbai'
GROUP BY 
    c.customer_id, c.customer_name, c.customer_email, c.customer_city
ORDER BY 
    total_order_value DESC;


-- Q2: Find the top 3 products by total quantity sold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    SUM(oi.quantity) AS total_quantity_sold
FROM 
    Products p
    INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, p.product_name, p.category, p.unit_price
ORDER BY 
    total_quantity_sold DESC
LIMIT 3;


-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT 
    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.sales_rep_email,
    sr.office_address,
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM 
    Sales_Representatives sr
    LEFT JOIN Orders o ON sr.sales_rep_id = o.sales_rep_id
GROUP BY 
    sr.sales_rep_id, sr.sales_rep_name, sr.sales_rep_email, sr.office_address
ORDER BY 
    unique_customers_handled DESC;


-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT 
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.sales_rep_id,
    sr.sales_rep_name,
    o.order_date,
    SUM(oi.quantity * p.unit_price) AS total_order_value
FROM 
    Orders o
    INNER JOIN Customers c ON o.customer_id = c.customer_id
    INNER JOIN Sales_Representatives sr ON o.sales_rep_id = sr.sales_rep_id
    INNER JOIN Order_Items oi ON o.order_id = oi.order_id
    INNER JOIN Products p ON oi.product_id = p.product_id
GROUP BY 
    o.order_id, o.customer_id, c.customer_name, o.sales_rep_id, sr.sales_rep_name, o.order_date
HAVING 
    SUM(oi.quantity * p.unit_price) > 10000
ORDER BY 
    total_order_value DESC;


-- Q5: Identify any products that have never been ordered
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM 
    Products p
    LEFT JOIN Order_Items oi ON p.product_id = oi.product_id
WHERE 
    oi.product_id IS NULL
ORDER BY 
    p.product_id;

-- ====================================================================
-- QUERY EXPLANATIONS:
-- ====================================================================
-- Q1: Shows power of normalized schema - join multiple tables to get
--     customer-specific totals without data duplication
-- Q2: Aggregates across order items to find bestsellers
-- Q3: Uses LEFT JOIN to include reps even if they have no orders
-- Q4: Demonstrates GROUP BY with HAVING for filtered aggregations
-- Q5: Uses LEFT JOIN to find orphaned records (products with no orders)
-- ====================================================================
