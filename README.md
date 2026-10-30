
# 🏭 Smart Factory Data Warehouse & Analytics

An end-to-end Data Engineering project focused on building a centralized Data Warehouse for a smart manufacturing environment.

The project uses manufacturing and production data to create a structured analytical database that supports production monitoring, machine performance analysis, downtime tracking, defect analysis, and maintenance reporting.

---

## 🎯 Project Objectives

* Integrate data from multiple manufacturing data sources.
* Build a centralized SQL Server Data Warehouse.
* Organize manufacturing data using a Star Schema.
* Prepare a structured foundation for ETL and analytical reporting.
* Support data-driven decision-making through organized production data.

---

## 🛠️ Technologies Used

| Technology   | Purpose                                |
| ------------ | -------------------------------------- |
| Python       | Data loading and database integration  |
| Pandas       | CSV processing and data handling       |
| SQL Server   | Database and Data Warehouse            |
| SQL          | Database schema design and management  |
| SQLAlchemy   | Python–SQL Server connectivity        |
| PyODBC       | SQL Server connectivity                |
| Git & GitHub | Version control and project management |

---

## 📂 Repository Structure

```text
smart_factory_project/
│
├── docs/
│
├── python/
│   ├── load_staging.py
│   └── test_connection.py
│
├── sql/
│   ├── 01_staging/
│   │   └── 01_create_staging.sql
│   │
│   └── 02_dw/
│       └── 02_create_dw_schema.sql
│
├── .gitignore
├── .env                 # Local configuration (not committed)
└── README.md
```

**Note:** Raw CSV files, virtual environments, and local environment configuration files are excluded from GitHub.

---

## 🗄️ Database Architecture

The project database is named:

`smartfactory`

It uses three database schemas:

| Schema      | Purpose                                        |
| ----------- | ---------------------------------------------- |
| `staging` | Stores raw source data before transformation   |
| `dw`      | Contains the dimensional Data Warehouse        |
| `gold`    | Reserved for business-ready analytical outputs |

---

## ✅ Task 1: Repository Setup, Database Connection & Staging Data Loading

### 1. Repository Setup

* Created the GitHub repository.
* Established the initial project folder structure.
* Configured `.gitignore` to exclude sensitive and unnecessary local files.
* Prepared the Python environment and installed the required dependencies.

### 2. Database Setup

* Created the `smartfactory` database using SQL Server.
* Configured the Python connection using SQLAlchemy and PyODBC.
* Successfully tested the database connection.

### 3. Staging Schema Creation

Created 16 staging tables to receive the raw manufacturing data.

All source columns were initially stored as `NVARCHAR(500)` to preserve the original values before data transformation.

### 4. Raw Data Loading

Developed a Python loading script (`load_staging.py`) using Pandas and SQLAlchemy.

The script performs the following operations:

* Reads the source CSV files.
* Preserves source values during loading.
* Adds a `_source_file` column to track data lineage.
* Checks source columns against the target staging tables.
* Loads records into SQL Server in batches.
* Compares CSV row counts with SQL Server table counts.

### Loading Results

| Dataset                |    Records Loaded |
| ---------------------- | ----------------: |
| dim_date               |               546 |
| dim_line               |                 5 |
| dim_machine            |                26 |
| dim_product            |                18 |
| dim_shift              |                 3 |
| dim_operator           |                88 |
| dim_downtime_reason    |                24 |
| dim_defect_type        |                30 |
| dim_supplier           |                17 |
| dim_material_batch     |             1,346 |
| fact_production_orders |             1,902 |
| fact_production        |            34,727 |
| fact_downtime          |           158,728 |
| fact_defects           |           158,008 |
| fact_maintenance       |            13,046 |
| sensor_readings_raw    |           281,023 |
| **Total**        | **659,537** |

**Validation:** All 16 CSV files were successfully loaded, and their row counts matched the corresponding SQL Server staging tables.

---

## ✅ Task 2: Data Warehouse Schema Design & Implementation

### 1. Schema Design

Reviewed the provided database schema and adapted the design to Microsoft SQL Server.

Designed a dimensional Data Warehouse following the **Star Schema** approach.

### 2. Dimension Tables

Created 10 dimension tables to describe the main manufacturing entities:

| Dimension Table   | Description                          |
| ----------------- | ------------------------------------ |
| DimDate           | Calendar and time-related attributes |
| DimLine           | Production line information          |
| DimMachine        | Machine and equipment details        |
| DimProduct        | Product information                  |
| DimShift          | Production shift details             |
| DimOperator       | Operator information                 |
| DimDowntimeReason | Downtime reasons and categories      |
| DimDefectType     | Defect types and classifications     |
| DimSupplier       | Supplier information                 |
| DimMaterialBatch  | Raw material batch details           |

### 3. Fact Tables

Created 6 fact tables to store measurable manufacturing events and operational activities:

| Fact Table           | Description                                           |
| -------------------- | ----------------------------------------------------- |
| FactProduction       | Production quantities, runtime, downtime, and output  |
| FactDowntime         | Machine downtime events and durations                 |
| FactDefects          | Defect quantities, dispositions, and associated costs |
| FactMaintenance      | Maintenance work orders, labor, and costs             |
| FactProductionOrders | Planned and actual production order information       |
| FactSensorReadings   | Machine sensor measurements and readings              |

### 4. Analytical View

Created the SQL Server view:

`dw.v_OEE_Machine_Shift_Date`

The view calculates key Overall Equipment Effectiveness (OEE) components:

* **Availability:** Run Time / Planned Production Time
* **Performance:** Actual Output / Expected Output
* **Quality:** Good Units / Total Units
* **OEE:** Availability × Performance × Quality

### 5. Implementation Results

| Metric               |       Result |
| -------------------- | -----------: |
| Database             | smartfactory |
| Database Schemas     |            3 |
| Dimension Tables     |           10 |
| Fact Tables          |            6 |
| Total DW Tables      |           16 |
| OEE Analytical View  |      Created |
| SQL Server Execution |   Successful |

The Data Warehouse schema was successfully created and verified in SQL Server.

---

## 📌 Current Project Status

| Task   | Description                                                  | Status       |
| ------ | ------------------------------------------------------------ | ------------ |
| Task 1 | Repository Setup, Database Connection & Staging Data Loading | ✅ Completed |
| Task 2 | Data Warehouse Schema Design & Implementation                | ✅ Completed |

**Current achievement:** Successfully established the project repository, loaded 659,537 records into 16 staging tables, and implemented a dimensional Data Warehouse containing 10 dimensions and 6 fact tables.

---

## 👨‍💻 GitHub Repository

[Smart Factory Data Warehouse Project](https://github.com/mazenismail17/smart_factory_project)
