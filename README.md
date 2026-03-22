# Assignment 01 - Database Normalization and SQL

## Repository Structure

```
assignment-01-<student-id>/
│
├── README.md                    ← This file
├── datasets/                    ← Provided datasets
│   └── orders_flat.csv
├── part1-rdbms/
│   ├── schema_design.sql       ← Normalized schema (3NF) with sample data
│   ├── queries.sql             ← 5 business queries
│   └── normalization.md        ← Anomaly analysis & justification
```

## Part 1 - RDBMS Completed ✓

### 1.1 Anomaly Analysis
- Insert Anomaly: Documented inability to add products/customers without orders
- Update Anomaly: Identified inconsistency in sales rep office address (row 39 vs row 20)
- Delete Anomaly: Product P008 (Webcam) appears in only one order (row 13)

### 1.2 Schema Design
Normalized to Third Normal Form (3NF) with 5 tables:
- Customers
- Products
- Sales_Representatives
- Orders
- Order_Items

All tables include:
- Primary and foreign keys
- NOT NULL constraints
- Sample data (5+ rows per table)

### 1.3 SQL Queries
All 5 queries implemented:
- Q1: Mumbai customers with total order values
- Q2: Top 3 products by quantity sold
- Q3: Sales reps with unique customer counts
- Q4: Orders exceeding 10,000 in value
- Q5: Products never ordered

## Files Ready for Submission

All files follow the required naming conventions and structure. SQL files are executable and notebooks include saved outputs.
