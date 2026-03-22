// ====================================================================
// MONGODB OPERATIONS - E-COMMERCE PRODUCT CATALOG
// ====================================================================
// Database: ecommerce_db
// Collection: products
// ====================================================================

// Connect to database (if running in MongoDB shell)
// use ecommerce_db

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    "_id": "ELEC001",
    "product_name": "Samsung Galaxy S23 Ultra",
    "category": "Electronics",
    "brand": "Samsung",
    "price": 89999,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 45,
    "specifications": {
      "screen_size": "6.8 inches",
      "processor": "Snapdragon 8 Gen 2",
      "ram": "12GB",
      "storage": "256GB",
      "battery": "5000mAh",
      "camera": {
        "rear": "200MP + 12MP + 10MP + 10MP",
        "front": "12MP"
      },
      "os": "Android 13",
      "5g_enabled": true,
      "voltage": "100-240V",
      "power_adapter": "25W Super Fast Charging"
    },
    "warranty": {
      "duration_months": 12,
      "type": "Manufacturer Warranty",
      "coverage": "Hardware defects only",
      "extended_available": true
    },
    "ratings": {
      "average": 4.6,
      "total_reviews": 2847
    },
    "tags": ["smartphone", "5G", "flagship", "Android"],
    "seller": {
      "name": "TechZone India",
      "rating": 4.8,
      "location": "Mumbai"
    },
    "added_date": "2024-03-15",
    "last_updated": "2024-11-20"
  },
  {
    "_id": "CLO001",
    "product_name": "Levi's Men's Regular Fit Jeans",
    "category": "Clothing",
    "brand": "Levi's",
    "price": 2999,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 120,
    "specifications": {
      "gender": "Men",
      "type": "Jeans",
      "fit": "Regular Fit",
      "material": "98% Cotton, 2% Elastane",
      "color": "Dark Blue",
      "pattern": "Solid",
      "wash_care": "Machine wash cold",
      "closure": "Zipper with button"
    },
    "sizes_available": [
      {
        "size": "30",
        "waist_inches": 30,
        "length_inches": 32,
        "stock": 25
      },
      {
        "size": "32",
        "waist_inches": 32,
        "length_inches": 32,
        "stock": 40
      },
      {
        "size": "34",
        "waist_inches": 34,
        "length_inches": 32,
        "stock": 35
      },
      {
        "size": "36",
        "waist_inches": 36,
        "length_inches": 32,
        "stock": 20
      }
    ],
    "care_instructions": [
      "Machine wash cold with like colors",
      "Do not bleach",
      "Tumble dry low",
      "Iron at low temperature if needed"
    ],
    "ratings": {
      "average": 4.4,
      "total_reviews": 1523
    },
    "tags": ["denim", "casual", "classic", "men's fashion"],
    "seller": {
      "name": "Fashion Hub",
      "rating": 4.7,
      "location": "Delhi"
    },
    "return_policy": {
      "returnable": true,
      "days": 30,
      "conditions": "Unworn with tags attached"
    },
    "added_date": "2024-01-10",
    "last_updated": "2024-10-05"
  },
  {
    "_id": "GRO001",
    "product_name": "Organic Basmati Rice",
    "category": "Groceries",
    "brand": "India Gate",
    "price": 845,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 250,
    "specifications": {
      "type": "Basmati Rice",
      "variant": "White Rice",
      "organic": true,
      "packaging": "Sealed bag",
      "weight": "5kg",
      "unit": "kg",
      "grain_length": "Extra Long",
      "aging": "Aged 2 years"
    },
    "nutritional_info": {
      "serving_size": "100g",
      "calories": 345,
      "protein": "7.5g",
      "carbohydrates": "78g",
      "fat": "0.5g",
      "fiber": "1.3g",
      "sodium": "5mg"
    },
    "expiry_info": {
      "manufacturing_date": "2024-01-15",
      "expiry_date": "2025-01-14",
      "best_before": "2024-12-15",
      "shelf_life_months": 12
    },
    "certifications": [
      "USDA Organic",
      "India Organic",
      "FSSAI Approved"
    ],
    "storage_instructions": "Store in a cool, dry place. Keep away from direct sunlight. Refrigerate after opening.",
    "ratings": {
      "average": 4.7,
      "total_reviews": 3892
    },
    "tags": ["rice", "organic", "basmati", "staple food", "vegetarian", "vegan"],
    "seller": {
      "name": "GroceryMart",
      "rating": 4.9,
      "location": "Bangalore"
    },
    "added_date": "2024-02-20",
    "last_updated": "2024-11-18"
  }
]);


// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  }
).pretty();

/*
Expected Result: Returns the Samsung Galaxy S23 Ultra document
Rationale: This query filters products by category and price range,
useful for displaying premium electronics in a dedicated section
of the e-commerce website.
*/


// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find(
  {
    category: "Groceries",
    "expiry_info.expiry_date": { $lt: "2025-01-01" }
  }
).pretty();

/*
Expected Result: Returns the Organic Basmati Rice document
(expiry date: 2025-01-14 is after 2025-01-01, so this would return
empty unless we have other grocery items expiring earlier)

Note: For testing purposes, this query demonstrates how to access
nested fields (expiry_info.expiry_date) and use date comparison.
In a real system, this would help identify products approaching
expiration for discount or removal.
*/


// OP4: updateOne() — add a "discount_percent" field to a specific product
db.products.updateOne(
  { _id: "CLO001" },
  {
    $set: {
      discount_percent: 20,
      discount_valid_until: "2024-12-31",
      discounted_price: 2399
    },
    $currentDate: {
      last_updated: true
    }
  }
);

/*
Explanation: This operation adds a discount to the Levi's Jeans product.
Using $set allows us to add new fields without affecting existing data.
The $currentDate operator automatically updates the last_updated timestamp.
This is useful for running promotional campaigns on specific products.
*/


// OP5: createIndex() — create an index on category field and explain why
db.products.createIndex(
  { category: 1 },
  { name: "idx_category" }
);

/*
WHY THIS INDEX IS IMPORTANT:

1. QUERY PERFORMANCE:
   - The category field is frequently used in filtering operations
   - OP2 and OP3 both filter by category first
   - Without an index, MongoDB performs a full collection scan
   - With an index, MongoDB can quickly locate matching documents

2. COMMON ACCESS PATTERN:
   - E-commerce sites typically display products by category
   - Users browse "Electronics", "Clothing", or "Groceries" sections
   - Category-based queries are among the most frequent operations
   
3. SCALABILITY:
   - As the product catalog grows to thousands/millions of documents,
     the performance gain from this index becomes critical
   - Index reduces query time from O(n) to O(log n)

4. COMPOUND QUERIES:
   - This index also benefits compound queries that start with category
   - Example: { category: "Electronics", price: { $gt: 20000 } }
   - MongoDB can use the category index to narrow down results first

PERFORMANCE IMPACT:
- Without index: Scans all documents (slow for large collections)
- With index: Direct lookup to matching categories (fast)
- Recommended for any field used frequently in query filters

TRADE-OFFS:
- Indexes consume disk space
- Indexes slow down write operations slightly (insert/update/delete)
- BUT: Read performance gain far outweighs these costs for
  frequently queried fields like category
*/


// ====================================================================
// ADDITIONAL USEFUL QUERIES (BONUS - NOT REQUIRED)
// ====================================================================

// Find all products in stock with ratings above 4.5
db.products.find(
  {
    in_stock: true,
    "ratings.average": { $gte: 4.5 }
  }
);

// Count products by category
db.products.aggregate([
  {
    $group: {
      _id: "$category",
      count: { $sum: 1 },
      avg_price: { $avg: "$price" }
    }
  }
]);

// Find products with specific tags
db.products.find(
  {
    tags: { $in: ["organic", "smartphone"] }
  }
);
