-- ====================================================================
-- DATA WAREHOUSE STAR SCHEMA - RETAIL CHAIN
-- ====================================================================
-- This schema implements a star schema design for retail analytics
-- with one central fact table and three dimension tables
-- ====================================================================

-- --------------------------------------------------------------------
-- DIMENSION TABLE 1: dim_date
-- --------------------------------------------------------------------
-- Time dimension for date-based analysis
-- Includes useful date attributes for reporting
-- --------------------------------------------------------------------

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day_of_week VARCHAR(20) NOT NULL
);

-- Sample data: Key dates from 2023
INSERT INTO dim_date (date_key, full_date, day, month, year, quarter, month_name, day_of_week) VALUES
(20230115, '2023-01-15', 15, 1, 2023, 1, 'January', 'Sunday'),
(20230205, '2023-02-05', 5, 2, 2023, 1, 'February', 'Sunday'),
(20230220, '2023-02-20', 20, 2, 2023, 1, 'February', 'Monday'),
(20230331, '2023-03-31', 31, 3, 2023, 1, 'March', 'Friday'),
(20230604, '2023-06-04', 4, 6, 2023, 2, 'June', 'Sunday'),
(20230809, '2023-08-09', 9, 8, 2023, 3, 'August', 'Wednesday'),
(20230815, '2023-08-15', 15, 8, 2023, 3, 'August', 'Tuesday'),
(20231026, '2023-10-26', 26, 10, 2023, 4, 'October', 'Thursday'),
(20231020, '2023-10-20', 20, 10, 2023, 4, 'October', 'Friday'),
(20231208, '2023-12-08', 8, 12, 2023, 4, 'December', 'Friday'),
(20231212, '2023-12-12', 12, 12, 2023, 4, 'December', 'Tuesday');


-- --------------------------------------------------------------------
-- DIMENSION TABLE 2: dim_store
-- --------------------------------------------------------------------
-- Store location dimension
-- Note: NULL store_city values cleaned and standardized
-- --------------------------------------------------------------------

CREATE TABLE dim_store (
    store_key INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- Sample data: All stores with cleaned city information
INSERT INTO dim_store (store_key, store_name, store_city, region) VALUES
(1, 'Chennai Anna', 'Chennai', 'South'),
(2, 'Bangalore MG', 'Bangalore', 'South'),
(3, 'Delhi South', 'Delhi', 'North'),
(4, 'Mumbai Central', 'Mumbai', 'West'),
(5, 'Pune FC Road', 'Pune', 'West');


-- --------------------------------------------------------------------
-- DIMENSION TABLE 3: dim_product
-- --------------------------------------------------------------------
-- Product catalog dimension
-- Note: Category names standardized to Title Case
-- --------------------------------------------------------------------

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Sample data: Unique products with standardized categories
INSERT INTO dim_product (product_key, product_name, category) VALUES
(1, 'Speaker', 'Electronics'),
(2, 'Tablet', 'Electronics'),
(3, 'Phone', 'Electronics'),
(4, 'Smartwatch', 'Electronics'),
(5, 'Laptop', 'Electronics'),
(6, 'Headphones', 'Electronics'),
(7, 'Atta 10kg', 'Groceries'),
(8, 'Biscuits', 'Groceries'),
(9, 'Milk 1L', 'Groceries'),
(10, 'Pulses 1kg', 'Groceries'),
(11, 'Rice 5kg', 'Groceries'),
(12, 'Oil 1L', 'Groceries'),
(13, 'Jeans', 'Clothing'),
(14, 'Jacket', 'Clothing'),
(15, 'Saree', 'Clothing'),
(16, 'T-Shirt', 'Clothing');


-- --------------------------------------------------------------------
-- FACT TABLE: fact_sales
-- --------------------------------------------------------------------
-- Central fact table containing sales transactions
-- Stores numeric measures and foreign keys to dimensions
-- --------------------------------------------------------------------

CREATE TABLE fact_sales (
    transaction_id VARCHAR(20) PRIMARY KEY,
    date_key INT NOT NULL,
    store_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    units_sold INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- Sample data: 10+ cleaned transactions from retail_transactions.csv
-- Note: Dates standardized to YYYYMMDD format
-- Note: Categories standardized to Title Case
-- Note: NULL city values filled based on store name patterns
INSERT INTO fact_sales (transaction_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_amount) VALUES
('TXN5000', 20230815, 1, 1, 'CUST045', 3, 49262.78, 147788.34),
('TXN5001', 20231212, 1, 2, 'CUST021', 11, 23226.12, 255487.32),
('TXN5002', 20230205, 1, 3, 'CUST019', 20, 48703.39, 974067.80),
('TXN5003', 20230220, 3, 2, 'CUST007', 14, 23226.12, 325165.68),
('TXN5004', 20230115, 1, 4, 'CUST004', 10, 58851.01, 588510.10),
('TXN5005', 20230809, 2, 7, 'CUST027', 12, 52464.00, 629568.00),
('TXN5006', 20230331, 5, 4, 'CUST025', 6, 58851.01, 353106.06),
('TXN5007', 20231026, 5, 13, 'CUST041', 16, 2317.47, 37079.52),
('TXN5008', 20231208, 2, 8, 'CUST030', 9, 27469.99, 247229.91),
('TXN5009', 20230815, 2, 4, 'CUST020', 3, 58851.01, 176553.03),
('TXN5010', 20230604, 1, 14, 'CUST031', 15, 30187.24, 452808.60),
('TXN5011', 20231020, 4, 13, 'CUST045', 13, 2317.47, 30127.11);


-- ====================================================================
-- STAR SCHEMA BENEFITS:
-- ====================================================================
-- 1. QUERY PERFORMANCE: Denormalized dimensions for fast joins
-- 2. BUSINESS INTELLIGENCE: Easy to aggregate by date, store, product
-- 3. HISTORICAL TRACKING: Slowly changing dimensions supported
-- 4. SCALABILITY: Fact table can grow to millions of rows
-- 5. FLEXIBILITY: Easy to add new dimensions without restructuring
-- ====================================================================

-- ====================================================================
-- DATA CLEANING APPLIED:
-- ====================================================================
-- 1. DATE STANDARDIZATION: All dates converted to YYYY-MM-DD format
--    and date_key uses YYYYMMDD integer format
-- 2. CATEGORY STANDARDIZATION: "electronics" → "Electronics"
--    "Grocery"/"Groceries" → "Groceries" (consistent)
-- 3. NULL HANDLING: Missing store_city values inferred from store_name
--    Example: "Mumbai Central" without city → "Mumbai" filled in
-- 4. CALCULATED MEASURES: total_amount = units_sold × unit_price
-- ====================================================================
