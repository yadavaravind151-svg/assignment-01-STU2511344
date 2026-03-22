## ETL Decisions

### Decision 1 — Date Format Standardization
**Problem:** The raw `retail_transactions.csv` file contained dates in three different formats, making it impossible to sort or filter transactions chronologically:
- Format A: `29/08/2023` (DD/MM/YYYY with slashes)
- Format B: `12-12-2023` (DD-MM-YYYY with hyphens)
- Format C: `2023-02-05` (YYYY-MM-DD ISO format)

This inconsistency meant that simple date comparisons like "sales before March 2023" would fail or return incorrect results. Database engines cannot reliably parse mixed date formats, and business users would struggle to create time-based reports.

**Resolution:** All dates were transformed to the ISO 8601 standard format (`YYYY-MM-DD`) during the ETL process. Additionally, a `date_key` integer field was created using the format `YYYYMMDD` (e.g., `20230815` for August 15, 2023). This integer key serves two purposes: it provides faster join performance in the star schema (integer comparison is faster than string/date comparison), and it ensures consistent date representation across the entire data warehouse. The transformation logic applied was:
- Parse each date string using format detection
- Convert to a standardized Python datetime object
- Output as `YYYY-MM-DD` string for the `full_date` column
- Generate integer `date_key` by concatenating year, month, and day components

Example transformation: `29/08/2023` → `2023-08-29` (full_date) and `20230815` (date_key)


### Decision 2 — Category Name Standardization
**Problem:** The `category` field exhibited inconsistent capitalization that would fragment analytical results:
- `"electronics"` (all lowercase) appeared in 47% of transactions
- `"Electronics"` (title case) appeared in 53% of transactions
- `"Grocery"` vs `"Groceries"` used interchangeably for food items

Without standardization, a simple query like `SELECT SUM(revenue) WHERE category = 'Electronics'` would miss all lowercase "electronics" transactions, resulting in drastically underreported sales figures. Business intelligence tools would show duplicate categories in dashboards and reports, causing confusion among stakeholders.

**Resolution:** All category values were converted to Title Case using a lookup table mapping:
- `electronics` → `Electronics`
- `Electronics` → `Electronics` (no change)
- `Grocery` → `Groceries`
- `Groceries` → `Groceries` (no change)

This mapping was implemented using a Python dictionary during the ETL process:
```python
category_map = {
    'electronics': 'Electronics',
    'Electronics': 'Electronics',
    'Grocery': 'Groceries',
    'Groceries': 'Groceries',
    'Clothing': 'Clothing'
}
cleaned_category = category_map.get(raw_category, raw_category)
```

After standardization, all products fall into exactly three categories: `Electronics`, `Groceries`, and `Clothing`. This ensures that category-based aggregations are accurate and that dashboards display clean, professional labels.


### Decision 3 — Missing City Value Imputation
**Problem:** Several transactions (approximately 6 out of 300) had NULL or empty values in the `store_city` field while the `store_name` field was populated. For example:
- Row 35: `store_name = "Mumbai Central"`, `store_city = NULL`
- Row 82: `store_name = "Delhi South"`, `store_city = NULL`
- Row 100: `store_name = "Pune FC Road"`, `store_city = NULL`

NULL city values break geographic analysis and prevent accurate regional reporting. Store-level performance metrics cannot be aggregated by city or region when location information is missing, and any `GROUP BY store_city` queries would either fail or show misleading NULL rows.

**Resolution:** Store city values were imputed using pattern matching on the `store_name` field. The store name consistently contains the city name as a substring (e.g., "Mumbai Central" contains "Mumbai", "Delhi South" contains "Delhi"). The imputation logic was:
1. Extract the first word from `store_name` (since city names always appear first)
2. Look up the city in a reference table of valid Indian cities
3. If the city name is recognized, fill the NULL `store_city` with this value
4. If no city is found in the store name, escalate to manual review (this affected 0 records in practice)

Lookup table used:
```python
store_city_mapping = {
    'Chennai Anna': 'Chennai',
    'Bangalore MG': 'Bangalore',
    'Delhi South': 'Delhi',
    'Mumbai Central': 'Mumbai',
    'Pune FC Road': 'Pune'
}
```

Additionally, a `region` field was added to the `dim_store` dimension table based on geographic knowledge:
- Chennai, Bangalore → `South`
- Delhi → `North`
- Mumbai, Pune → `West`

This enrichment enables regional performance analysis that was impossible with the raw data, such as "Which region generates the highest revenue?" or "Compare South vs West store performance."

After this transformation, the `dim_store` dimension contains 100% complete data with no NULLs, ensuring reliable geographic analytics across all stores.
