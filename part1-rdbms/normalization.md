## Anomaly Analysis

### Insert Anomaly
**Location**: Cannot be demonstrated with a specific row, as it's the absence of capability.

**Description**: The denormalized structure prevents us from adding new entities that haven't participated in a transaction. For example:
- We cannot add a new product (e.g., "Printer" with product_id P009) to the system until someone places an order for it
- We cannot register a new customer until they make their first purchase
- We cannot add a new sales representative to the system until they handle their first order

This forces the business to either create dummy/fake orders or delay recording important business entities until they are involved in a transaction.

### Update Anomaly
**Location**: Rows 20, 39, 154, 156, 160, 172, 175, 176, 182 for customer C008 (Kavya Rao) and sales rep SR01 (Deepak Joshi)

**Description**: Inconsistent data exists for the same sales representative's office address:
- Row 20: "Mumbai HQ, Nariman Point, Mumbai - 400021"
- Row 39: "Mumbai HQ, Nariman Pt, Mumbai - 400021" (abbreviated "Pt")
- Rows 154, 156, 160, 172, 176, 182: "Mumbai HQ, Nariman Pt, Mumbai - 400021"

This inconsistency demonstrates the update anomaly - when SR01's office address needs to be updated, it must be changed in multiple rows (SR01 appears in 45+ rows). Missing even a single row creates data inconsistency. The same issue applies to customer emails, product prices, and sales rep contact information, which are all duplicated across multiple rows.

### Delete Anomaly
**Location**: Row 13 (order ORD1185) for product P008 (Webcam)

**Description**: Product P008 (Webcam) appears in only one order in the entire dataset (row 13). If this order is deleted or cancelled:
- We lose all information about the Webcam product (product_id, name, category, unit_price)
- We cannot reference this product for inventory, pricing, or catalog purposes
- Historical knowledge that this product existed in our system is completely lost

This forces the business to either keep cancelled/invalid orders in the system or lose product information entirely.

## Normalization Justification

The manager's argument that "keeping everything in one table is simpler" reflects a common misconception that confuses simplicity with convenience. While a single table may seem easier to query initially, this perceived simplicity quickly becomes a liability as the dataset grows.

**Data Integrity and Consistency**: The current flat file contains 187 rows with massive redundancy. Customer "Rohan Mehta" (C001) appears in 14 different rows with identical personal information repeated each time. If Rohan updates his email from rohan@gmail.com to rohan.mehta@gmail.com, all 14 rows must be updated. The current dataset already shows evidence of this problem - sales representative SR01's office address appears in two different formats ("Nariman Point" vs "Nariman Pt"), demonstrating that update inconsistencies have already occurred.

**Storage Efficiency and Scalability**: Each of the 187 rows stores complete customer details, product information, and sales rep data. Customer C001's name, email, and city are stored 14 times unnecessarily. With 8 unique customers, 8 products, and 3 sales reps, a normalized design would store this reference data exactly once each, reducing redundancy by over 85%. As order volume grows to thousands or millions, this redundancy becomes economically wasteful in terms of storage costs and query performance.

**Business Flexibility**: The insert anomaly prevents basic business operations. We cannot add new products to our catalog until someone orders them, cannot onboard new sales representatives until they close their first deal, and cannot register potential customers for marketing purposes. A normalized design separates these concerns, allowing each entity to exist independently.

**Maintenance and Evolution**: Product price changes, sales territory reassignments, and customer relocations all require hunting down and updating dozens of rows. In a normalized structure, changing product P001's price from 55,000 to 52,000 is a single UPDATE statement affecting one row. In the flat file, it requires updating 16+ rows - and missing even one creates pricing inconsistencies that could result in billing errors, customer disputes, or revenue loss.

The "complexity" of normalization is a one-time design cost that pays dividends every day through improved data integrity, reduced storage, and simplified maintenance.
