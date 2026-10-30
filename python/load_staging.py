"""
load_staging.py (SQL Server)

Loads every raw CSV from data/ into staging.stg_<file name>, as text.

Run 01_create_staging.sql first, then:
cd python && python load_staging.py
"""

import os
import re
import sys
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# Load database configuration
load_dotenv()

engine = create_engine(
    os.environ["DB_URL"],
    fast_executemany=True
)


# CSV files location
RAW = Path(__file__).resolve().parent.parent.parent / "data"

# Expected CSV files
EXPECTED = [
    "dim_date",
    "dim_line",
    "dim_machine",
    "dim_product",
    "dim_shift",
    "dim_operator",
    "dim_downtime_reason",
    "dim_defect_type",
    "dim_supplier",
    "dim_material_batch",
    "fact_production_orders",
    "fact_production",
    "fact_downtime",
    "fact_defects",
    "fact_maintenance",
    "sensor_readings_raw",
]


# Map table name to CSV path
# Ignores numeric prefixes like 1793_dim_line.csv
found = {
    re.sub(r"^\d+_", "", p.stem): p
    for p in RAW.glob("*.csv")
}


# Check for missing files
missing = [name for name in EXPECTED if name not in found]

if missing:
    sys.exit(f"Missing CSV files in {RAW}: {missing}")


failed = 0


# Load each CSV into its staging table
for name in EXPECTED:

    table = f"stg_{name}"

    print(f"\nLoading {name}...")

    # Read CSV as text
    df = pd.read_csv(
        found[name],
        dtype=str,
        keep_default_na=False,
        encoding="utf-8-sig"
    )

    # Add source file tracking column
    df["_source_file"] = found[name].name

    # Check database columns
    with engine.begin() as conn:

        db_cols = [
            row[0]
            for row in conn.execute(
                text(
                    "SELECT COLUMN_NAME "
                    "FROM INFORMATION_SCHEMA.COLUMNS "
                    "WHERE TABLE_SCHEMA='staging' "
                    "AND TABLE_NAME=:t "
                    "ORDER BY ORDINAL_POSITION"
                ),
                {"t": table}
            )
        ]

        # Compare CSV columns with SQL table columns
        if db_cols != list(df.columns):

            print(f"{name}: COLUMN MISMATCH")
            print(f"  csv: {list(df.columns)}")
            print(f"  db : {db_cols}")

            failed += 1
            continue

        # Clear previous data before loading
        conn.execute(
            text(f"TRUNCATE TABLE staging.[{table}]")
        )

    # Insert data into SQL Server in batches
    df.to_sql(
        table,
        engine,
        schema="staging",
        if_exists="append",
        index=False,
        chunksize=5000
    )

    # Verify loaded row count
    with engine.connect() as conn:

        n = conn.execute(
            text(f"SELECT COUNT(*) FROM staging.[{table}]")
        ).scalar()

    # Compare CSV and SQL row counts
    ok = n == len(df)

    failed += 0 if ok else 1

    print(
        f"{name:28s} "
        f"csv={len(df):>7} "
        f"table={n:>7} "
        f"-> {'OK' if ok else 'MISMATCH'}"
    )


# Final result
print(
    "\nALL OK"
    if failed == 0
    else f"\n{failed} table(s) with problems"
)