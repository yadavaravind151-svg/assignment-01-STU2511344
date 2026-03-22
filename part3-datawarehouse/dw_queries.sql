-- ====================================================================
-- ANALYTICAL QUERIES - DATA WAREHOUSE
-- ====================================================================
-- Business intelligence queries leveraging the star schema design
-- ====================================================================

-- Q1: Total sales revenue by product category for each month
SELECT 
    d.year,
    d.month,
    d.month_name,
    p.category,
    SUM(f.total_amount) AS total_revenue,
    SUM(f.units_sold) AS total_units_sold,
    COUNT(f.transaction_id) AS transaction_count
FROM 
    fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
    INNER JOIN dim_product p ON f.product_key = p.product_key
GROUP BY 
    d.year, d.month, d.month_name, p.category
ORDER BY 
    d.year, d.month, p.category;

/*
BUSINESS VALUE:
- Identifies seasonal trends in category performance
- Helps with inventory planning and procurement
- Supports category-specific marketing campaigns
- Example insight: "Electronics sales peak in December (holiday season)"
*/


-- Q2: Top 2 performing stores by total revenue
SELECT 
    s.store_name,
    s.store_city,
    s.region,
    SUM(f.total_amount) AS total_revenue,
    SUM(f.units_sold) AS total_units_sold,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.customer_id), 2) AS revenue_per_customer
FROM 
    fact_sales f
    INNER JOIN dim_store s ON f.store_key = s.store_key
GROUP BY 
    s.store_name, s.store_city, s.region
ORDER BY 
    total_revenue DESC
LIMIT 2;

/*
BUSINESS VALUE:
- Identifies top-performing locations for best practice sharing
- Helps allocate resources to high-revenue stores
- Revenue per customer metric shows efficiency
- Example action: "Replicate Chennai Anna's strategies in underperforming stores"
*/


-- Q3: Month-over-month sales trend across all stores
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.total_amount) AS monthly_revenue,
    SUM(f.units_sold) AS monthly_units,
    COUNT(f.transaction_id) AS monthly_transactions,
    ROUND(SUM(f.total_amount) / COUNT(f.transaction_id), 2) AS avg_transaction_value,
    LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, d.month) AS previous_month_revenue,
    ROUND(
        ((SUM(f.total_amount) - LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, d.month)) 
         / NULLIF(LAG(SUM(f.total_amount)) OVER (ORDER BY d.year, d.month), 0)) * 100, 
        2
    ) AS revenue_growth_percent
FROM 
    fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 
    d.year, d.month, d.month_name
ORDER BY 
    d.year, d.month;

/*
BUSINESS VALUE:
- Tracks overall business growth trajectory
- Identifies months with declining revenue for root cause analysis
- Average transaction value shows customer spending patterns
- Window function (LAG) enables period-over-period comparison
- Example insight: "Revenue dropped 15% in March - investigate supply chain issues"
*/


-- ====================================================================
-- ADDITIONAL ANALYTICAL QUERIES (BONUS)
-- ====================================================================

-- Q4: Product performance analysis
SELECT 
    p.product_name,
    p.category,
    SUM(f.units_sold) AS total_units_sold,
    SUM(f.total_amount) AS total_revenue,
    COUNT(DISTINCT f.customer_id) AS unique_buyers,
    ROUND(AVG(f.unit_price), 2) AS avg_selling_price
FROM 
    fact_sales f
    INNER JOIN dim_product p ON f.product_key = p.product_key
GROUP BY 
    p.product_name, p.category
ORDER BY 
    total_revenue DESC;

/*
BUSINESS VALUE:
- Identifies bestselling products vs slow movers
- Helps optimize product mix and shelf space allocation
- Price elasticity insights through avg_selling_price tracking
*/


-- Q5: Regional performance comparison
SELECT 
    s.region,
    COUNT(DISTINCT s.store_key) AS store_count,
    SUM(f.total_amount) AS regional_revenue,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT s.store_key), 2) AS revenue_per_store,
    SUM(f.units_sold) AS regional_units_sold
FROM 
    fact_sales f
    INNER JOIN dim_store s ON f.store_key = s.store_key
GROUP BY 
    s.region
ORDER BY 
    regional_revenue DESC;

/*
BUSINESS VALUE:
- Compares performance across geographic regions
- Revenue per store normalizes for varying store counts
- Supports regional expansion and investment decisions
*/


-- Q6: Customer purchase behavior by day of week
SELECT 
    d.day_of_week,
    COUNT(f.transaction_id) AS transaction_count,
    SUM(f.total_amount) AS daily_revenue,
    ROUND(AVG(f.total_amount), 2) AS avg_transaction_size,
    SUM(f.units_sold) AS total_units
FROM 
    fact_sales f
    INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY 
    d.day_of_week
ORDER BY 
    daily_revenue DESC;

/*
BUSINESS VALUE:
- Optimizes staffing levels based on peak shopping days
- Schedules promotions on high-traffic days
- Identifies slow days for maintenance and training
*/
