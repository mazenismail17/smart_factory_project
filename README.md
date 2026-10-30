# smart_factory_project



## Task 1: Repository, Database Setup & Staging Load

**Status: Completed**

### Completed Work

- Created and configured the GitHub repository.
- Set up SQL Server database (`smartfactory`).
- Created database schemas:
  - `staging`
  - `dw`
  - `gold`
- Created 16 staging tables.
- Configured Python environment and SQL Server connectivity.
- Developed a Python ETL script to load raw CSV files into SQL Server staging tables.
- Validated the loading process by comparing CSV and SQL row counts.

### Loading Results

| Metric                 |  Result |
| ---------------------- | ------: |
| CSV Files Loaded       |      16 |
| Staging Tables Created |      16 |
| Total Records Loaded   | 659,537 |
| Loading Validation     |  Passed |

### Technical Stack

- SQL Server
- Python
- Pandas
- SQLAlchemy
- PyODBC
- Git & GitHub

### Next Step

Design and implement the Data Warehouse Star Schema.
