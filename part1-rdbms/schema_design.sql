-- ====================================================================
-- RETAIL COMPANY DATABASE - NORMALIZED SCHEMA (3NF)
-- ====================================================================
-- This schema eliminates insert, update, and delete anomalies
-- by properly separating entities into their own tables
-- ====================================================================

-- --------------------------------------------------------------------
-- TABLE 1: Customers
-- --------------------------------------------------------------------
-- Stores customer information independently of orders
-- This solves the update anomaly where customer info was duplicated
-- across multiple orders
-- --------------------------------------------------------------------

CREATE TABLE Customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_city VARCHAR(50) NOT NULL
);

-- Sample data: 5 customers
INSERT INTO Customers (customer_id, customer_name, customer_email, customer_city) VALUES
('C001', 'Rohan Mehta', 'rohan@gmail.com', 'Mumbai'),
('C002', 'Priya Sharma', 'priya@gmail.com', 'Delhi'),
('C003', 'Amit Verma', 'amit@gmail.com', 'Bangalore'),
('C004', 'Sneha Iyer', 'sneha@gmail.com', 'Chennai'),
('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai');

-- --------------------------------------------------------------------
-- TABLE 2: Products
-- --------------------------------------------------------------------
-- Stores product catalog independently of orders
-- This solves the insert anomaly (can add products without orders)
-- and delete anomaly (deleting orders won't delete product info)
-- --------------------------------------------------------------------

CREATE TABLE Products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- Sample data: 5 products
INSERT INTO Products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop', 'Electronics', 55000.00),
('P002', 'Mouse', 'Electronics', 800.00),
('P003', 'Desk Chair', 'Furniture', 8500.00),
('P004', 'Notebook', 'Stationery', 120.00),
('P005', 'Headphones', 'Electronics', 3200.00);

-- --------------------------------------------------------------------
-- TABLE 3: Sales_Representatives
-- --------------------------------------------------------------------
-- Stores sales rep information independently
-- Eliminates duplication of rep details across orders
-- --------------------------------------------------------------------

CREATE TABLE Sales_Representatives (
    sales_rep_id VARCHAR(10) PRIMARY KEY,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(100) NOT NULL,
    office_address VARCHAR(200) NOT NULL
);

-- Sample data: 3 sales representatives
INSERT INTO Sales_Representatives (sales_rep_id, sales_rep_name, sales_rep_email, office_address) VALUES
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai', 'anita@corp.com', 'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar', 'ravi@corp.com', 'South Zone, MG Road, Bangalore - 560001');

-- --------------------------------------------------------------------
-- TABLE 4: Orders
-- --------------------------------------------------------------------
-- Stores order header information
-- Links to Customers and Sales_Representatives via foreign keys
-- --------------------------------------------------------------------

CREATE TABLE Orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    sales_rep_id VARCHAR(10) NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (sales_rep_id) REFERENCES Sales_Representatives(sales_rep_id)
);

-- Sample data: 5 orders
INSERT INTO Orders (order_id, customer_id, sales_rep_id, order_date) VALUES
('ORD1027', 'C002', 'SR02', '2023-11-02'),
('ORD1114', 'C001', 'SR01', '2023-08-06'),
('ORD1132', 'C003', 'SR02', '2023-03-07'),
('ORD1002', 'C002', 'SR02', '2023-01-17'),
('ORD1075', 'C005', 'SR03', '2023-04-18');

-- --------------------------------------------------------------------
-- TABLE 5: Order_Items
-- --------------------------------------------------------------------
-- Junction table linking Orders and Products (many-to-many relationship)
-- Stores quantity for each product in each order
-- Composite primary key ensures each product appears only once per order
-- --------------------------------------------------------------------

CREATE TABLE Order_Items (
    order_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Sample data: 5 order items
INSERT INTO Order_Items (order_id, product_id, quantity) VALUES
('ORD1027', 'P004', 4),
('ORD1114', 'P002', 2),
('ORD1132', 'P002', 5),
('ORD1002', 'P005', 1),
('ORD1075', 'P003', 3);

-- ====================================================================
-- SCHEMA BENEFITS:
-- ====================================================================
-- 1. No Insert Anomaly: Can add products, customers, or sales reps
--    independently without needing orders
-- 2. No Update Anomaly: Customer email changed? Update ONE row in
--    Customers table instead of dozens across orders
-- 3. No Delete Anomaly: Delete an order? Product and customer info
--    remain intact in their respective tables
-- 4. Data Integrity: Foreign keys ensure referential integrity
-- 5. Storage Efficiency: No duplication of customer, product, or
--    sales rep information
-- ====================================================================
