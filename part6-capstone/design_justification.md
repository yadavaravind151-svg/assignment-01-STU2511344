## Storage Systems

The hospital's four goals require a multi-database architecture, each system chosen for its specific strengths.

**Goal 1: Predict patient readmission risk** uses a **Data Warehouse (Snowflake)** combined with **PostgreSQL OLTP**. Historical treatment data, diagnoses, medications, and demographics are extracted from the transactional PostgreSQL database and loaded into Snowflake's star schema. The warehouse aggregates patient encounters, calculates features like readmission rates and comorbidity indices, and feeds these into a machine learning model (scikit-learn or XGBoost) for training. Snowflake's columnar storage enables fast analytical queries across millions of patient records without impacting operational performance.

**Goal 2: Allow plain English queries of patient history** requires a **Vector Database (Pinecone or Weaviate)**. Patient records, clinical notes, lab results, and radiology reports are converted into embeddings using a medical language model. When a doctor asks "Has this patient had a cardiac event before?", the query is embedded and compared against the vector database using cosine similarity. This returns semantically relevant records even when exact terminology differs, enabling natural language search that keyword databases cannot support.

**Goal 3: Generate monthly management reports** relies on the **Data Warehouse (Snowflake)**. Bed occupancy data, department-wise costs, patient volumes, and revenue metrics are aggregated from transactional systems via nightly ETL pipelines. The warehouse maintains historical snapshots and pre-calculated rollups, enabling fast dashboard queries without scanning operational tables. Reports on trends, budget variance, and resource utilization query years of data in seconds.

**Goal 4: Stream and store real-time ICU vitals** uses a **Time-Series Database (InfluxDB)** fed by **Apache Kafka**. ICU monitors emit heart rate, blood pressure, oxygen saturation, and temperature readings every few seconds. Kafka ingests this high-velocity stream, and InfluxDB writes it efficiently in columnar time-series format optimized for range queries. Anomaly detection algorithms monitor the stream in real-time, triggering alerts when vital signs deviate from safe thresholds. InfluxDB's retention policies automatically downsample old data to conserve storage while maintaining granular recent history.

## OLTP vs OLAP Boundary

The **OLTP (transactional) boundary** encompasses the PostgreSQL database and real-time Kafka streams. This layer handles:
- Patient admissions, discharges, transfers
- Medication orders and administration
- Appointment scheduling
- Lab test requests
- Real-time vital sign ingestion

These systems prioritize low-latency writes, ACID guarantees, and row-level locking for concurrent updates. Queries are point lookups or small-range scans.

The **OLAP (analytical) boundary** begins at the ETL pipeline that extracts data nightly from PostgreSQL into Snowflake. This layer includes:
- The data warehouse with historical patient encounters
- Pre-aggregated metrics for reporting
- Machine learning feature engineering
- Vector embeddings for semantic search

OLAP systems sacrifice real-time freshness for query performance on large datasets. The boundary is temporal: operational data flows into analytical stores with acceptable latency (nightly batch for reports, near-real-time for ML models, streaming for ICU alerts).

## Trade-offs

**Significant Trade-off: Data Duplication vs. Performance**

The architecture deliberately duplicates patient data across four storage systems: PostgreSQL holds operational records, Snowflake stores historical aggregates, Pinecone contains vectorized notes, and InfluxDB archives vitals. This redundancy consumes storage and creates synchronization challenges. If a patient's allergy is updated in PostgreSQL, the vector database embedding must be regenerated, introducing consistency windows where different systems show different truths.

**Mitigation Strategy:**

Implement a **Change Data Capture (CDC) pipeline** using Debezium to monitor PostgreSQL write-ahead logs. When critical fields update (allergies, diagnoses, medications), CDC triggers asynchronous updates to dependent systems. For the vector database, embeddings regenerate in near-real-time. For the warehouse, updates queue for the next ETL cycle unless flagged as critical. A "golden source" principle designates PostgreSQL as authoritative for current patient state, while derived systems acknowledge eventual consistency. Data lineage tracking logs propagation delays, and the doctor dashboard displays staleness indicators when vector search results exceed freshness thresholds. This balances the performance benefits of specialized storage against the consistency risks of duplication.
