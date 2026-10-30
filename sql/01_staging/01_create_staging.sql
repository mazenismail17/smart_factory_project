-- =====================================================================
-- 01_create_staging.sql  (SQL Server)
-- Purpose : raw landing layer. One stg_* table per CSV, every column is text,
--           plus _source_file. Nothing is cleaned or converted here.
-- Run     : once in SSMS. Safe to re-run (drops and recreates stg_* tables).
-- =====================================================================
IF DB_ID(N'smartfactory') IS NULL CREATE DATABASE smartfactory;
GO
USE smartfactory;
GO
IF SCHEMA_ID(N'staging') IS NULL EXEC(N'CREATE SCHEMA staging');
GO
IF SCHEMA_ID(N'dw')      IS NULL EXEC(N'CREATE SCHEMA dw');
GO
IF SCHEMA_ID(N'gold')    IS NULL EXEC(N'CREATE SCHEMA gold');
GO

IF OBJECT_ID(N'staging.stg_dim_supplier', N'U') IS NOT NULL DROP TABLE staging.stg_dim_supplier;
GO
CREATE TABLE staging.stg_dim_supplier (
    [supplier_id] NVARCHAR(500) NULL,
    [supplier_code] NVARCHAR(500) NULL,
    [supplier_name] NVARCHAR(500) NULL,
    [country] NVARCHAR(500) NULL,
    [material_type] NVARCHAR(500) NULL,
    [lead_time_days] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_fact_defects', N'U') IS NOT NULL DROP TABLE staging.stg_fact_defects;
GO
CREATE TABLE staging.stg_fact_defects (
    [defect_record_id] NVARCHAR(500) NULL,
    [production_id] NVARCHAR(500) NULL,
    [defect_id] NVARCHAR(500) NULL,
    [quantity] NVARCHAR(500) NULL,
    [disposition] NVARCHAR(500) NULL,
    [cost_lost] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_fact_downtime', N'U') IS NOT NULL DROP TABLE staging.stg_fact_downtime;
GO
CREATE TABLE staging.stg_fact_downtime (
    [downtime_id] NVARCHAR(500) NULL,
    [production_id] NVARCHAR(500) NULL,
    [date] NVARCHAR(500) NULL,
    [shift_id] NVARCHAR(500) NULL,
    [machine_id] NVARCHAR(500) NULL,
    [start_time] NVARCHAR(500) NULL,
    [end_time] NVARCHAR(500) NULL,
    [duration_min] NVARCHAR(500) NULL,
    [reason_id] NVARCHAR(500) NULL,
    [is_micro_stop] NVARCHAR(500) NULL,
    [operator_comment] NVARCHAR(500) NULL,
    [source] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_fact_maintenance', N'U') IS NOT NULL DROP TABLE staging.stg_fact_maintenance;
GO
CREATE TABLE staging.stg_fact_maintenance (
    [work_order_id] NVARCHAR(500) NULL,
    [machine_id] NVARCHAR(500) NULL,
    [wo_type] NVARCHAR(500) NULL,
    [priority] NVARCHAR(500) NULL,
    [status] NVARCHAR(500) NULL,
    [opened_at] NVARCHAR(500) NULL,
    [closed_at] NVARCHAR(500) NULL,
    [downtime_min] NVARCHAR(500) NULL,
    [technician] NVARCHAR(500) NULL,
    [labor_hours] NVARCHAR(500) NULL,
    [parts_cost_usd] NVARCHAR(500) NULL,
    [failure_mode] NVARCHAR(500) NULL,
    [downtime_id] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_fact_production', N'U') IS NOT NULL DROP TABLE staging.stg_fact_production;
GO
CREATE TABLE staging.stg_fact_production (
    [production_id] NVARCHAR(500) NULL,
    [date] NVARCHAR(500) NULL,
    [shift_id] NVARCHAR(500) NULL,
    [machine_id] NVARCHAR(500) NULL,
    [product_id] NVARCHAR(500) NULL,
    [operator_id] NVARCHAR(500) NULL,
    [batch_id] NVARCHAR(500) NULL,
    [planned_time_min] NVARCHAR(500) NULL,
    [downtime_min] NVARCHAR(500) NULL,
    [run_time_min] NVARCHAR(500) NULL,
    [ideal_rate_per_hour] NVARCHAR(500) NULL,
    [total_units] NVARCHAR(500) NULL,
    [good_units] NVARCHAR(500) NULL,
    [defective_units] NVARCHAR(500) NULL,
    [scrap_units] NVARCHAR(500) NULL,
    [rework_units] NVARCHAR(500) NULL,
    [order_id] NVARCHAR(500) NULL,
    [entry_source] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_fact_production_orders', N'U') IS NOT NULL DROP TABLE staging.stg_fact_production_orders;
GO
CREATE TABLE staging.stg_fact_production_orders (
    [order_id] NVARCHAR(500) NULL,
    [line_id] NVARCHAR(500) NULL,
    [product_id] NVARCHAR(500) NULL,
    [planned_start_date] NVARCHAR(500) NULL,
    [actual_end_date] NVARCHAR(500) NULL,
    [due_date] NVARCHAR(500) NULL,
    [planned_qty] NVARCHAR(500) NULL,
    [produced_good_qty] NVARCHAR(500) NULL,
    [fill_rate] NVARCHAR(500) NULL,
    [status] NVARCHAR(500) NULL,
    [priority] NVARCHAR(500) NULL,
    [customer_channel] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_date', N'U') IS NOT NULL DROP TABLE staging.stg_dim_date;
GO
CREATE TABLE staging.stg_dim_date (
    [date] NVARCHAR(500) NULL,
    [day] NVARCHAR(500) NULL,
    [week] NVARCHAR(500) NULL,
    [month] NVARCHAR(500) NULL,
    [month_name] NVARCHAR(500) NULL,
    [quarter] NVARCHAR(500) NULL,
    [year] NVARCHAR(500) NULL,
    [weekday_name] NVARCHAR(500) NULL,
    [is_weekend] NVARCHAR(500) NULL,
    [is_plant_day] NVARCHAR(500) NULL,
    [is_holiday] NVARCHAR(500) NULL,
    [holiday_name] NVARCHAR(500) NULL,
    [is_ramadan] NVARCHAR(500) NULL,
    [season] NVARCHAR(500) NULL,
    [avg_ambient_temp_c] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_sensor_readings_raw', N'U') IS NOT NULL DROP TABLE staging.stg_sensor_readings_raw;
GO
CREATE TABLE staging.stg_sensor_readings_raw (
    [reading_id] NVARCHAR(500) NULL,
    [timestamp] NVARCHAR(500) NULL,
    [machine_id] NVARCHAR(500) NULL,
    [temperature_c] NVARCHAR(500) NULL,
    [vibration_mm_s] NVARCHAR(500) NULL,
    [pressure_bar] NVARCHAR(500) NULL,
    [speed_pct] NVARCHAR(500) NULL,
    [power_kw] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_defect_type', N'U') IS NOT NULL DROP TABLE staging.stg_dim_defect_type;
GO
CREATE TABLE staging.stg_dim_defect_type (
    [defect_id] NVARCHAR(500) NULL,
    [defect_name] NVARCHAR(500) NULL,
    [defect_category] NVARCHAR(500) NULL,
    [is_reworkable] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_downtime_reason', N'U') IS NOT NULL DROP TABLE staging.stg_dim_downtime_reason;
GO
CREATE TABLE staging.stg_dim_downtime_reason (
    [reason_id] NVARCHAR(500) NULL,
    [reason_name] NVARCHAR(500) NULL,
    [category] NVARCHAR(500) NULL,
    [is_planned] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_line', N'U') IS NOT NULL DROP TABLE staging.stg_dim_line;
GO
CREATE TABLE staging.stg_dim_line (
    [line_id] NVARCHAR(500) NULL,
    [line_name] NVARCHAR(500) NULL,
    [product_category] NVARCHAR(500) NULL,
    [building] NVARCHAR(500) NULL,
    [shifts_per_day] NVARCHAR(500) NULL,
    [operating_days] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_machine', N'U') IS NOT NULL DROP TABLE staging.stg_dim_machine;
GO
CREATE TABLE staging.stg_dim_machine (
    [machine_id] NVARCHAR(500) NULL,
    [machine_name] NVARCHAR(500) NULL,
    [asset_tag] NVARCHAR(500) NULL,
    [line_id] NVARCHAR(500) NULL,
    [process_step] NVARCHAR(500) NULL,
    [process_stage] NVARCHAR(500) NULL,
    [machine_type] NVARCHAR(500) NULL,
    [ideal_rate_per_hour] NVARCHAR(500) NULL,
    [manufacturer] NVARCHAR(500) NULL,
    [install_date] NVARCHAR(500) NULL,
    [value_added_factor] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_material_batch', N'U') IS NOT NULL DROP TABLE staging.stg_dim_material_batch;
GO
CREATE TABLE staging.stg_dim_material_batch (
    [batch_id] NVARCHAR(500) NULL,
    [supplier_code] NVARCHAR(500) NULL,
    [supplier] NVARCHAR(500) NULL,
    [material_type] NVARCHAR(500) NULL,
    [received_date] NVARCHAR(500) NULL,
    [quality_grade] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_operator', N'U') IS NOT NULL DROP TABLE staging.stg_dim_operator;
GO
CREATE TABLE staging.stg_dim_operator (
    [operator_id] NVARCHAR(500) NULL,
    [operator_name] NVARCHAR(500) NULL,
    [line_id] NVARCHAR(500) NULL,
    [shift_id] NVARCHAR(500) NULL,
    [hire_date] NVARCHAR(500) NULL,
    [prior_experience_years] NVARCHAR(500) NULL,
    [certification_date] NVARCHAR(500) NULL,
    [is_certified] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_product', N'U') IS NOT NULL DROP TABLE staging.stg_dim_product;
GO
CREATE TABLE staging.stg_dim_product (
    [product_id] NVARCHAR(500) NULL,
    [product_name] NVARCHAR(500) NULL,
    [sku] NVARCHAR(500) NULL,
    [product_family] NVARCHAR(500) NULL,
    [line_id] NVARCHAR(500) NULL,
    [size_ml] NVARCHAR(500) NULL,
    [pack_type] NVARCHAR(500) NULL,
    [unit_cost] NVARCHAR(500) NULL,
    [selling_price] NVARCHAR(500) NULL,
    [rate_factor] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO

IF OBJECT_ID(N'staging.stg_dim_shift', N'U') IS NOT NULL DROP TABLE staging.stg_dim_shift;
GO
CREATE TABLE staging.stg_dim_shift (
    [shift_id] NVARCHAR(500) NULL,
    [shift_name] NVARCHAR(500) NULL,
    [start_time] NVARCHAR(500) NULL,
    [end_time] NVARCHAR(500) NULL,
    [planned_minutes] NVARCHAR(500) NULL,
    [_source_file] NVARCHAR(200) NULL
);
GO
