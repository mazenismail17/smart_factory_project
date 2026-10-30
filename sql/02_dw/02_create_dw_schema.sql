/* ============================================================
   SMART FACTORY DATA WAREHOUSE
   Platform: Microsoft SQL Server
   Architecture: Star Schema
   Version: 2.0

   Database: smartfactory

   Prerequisites:
   - Staging database and tables already exist.
   - Schema: staging

   Important:
   - Creates DW tables only.
   - Does not modify or delete staging data.
   - Does not load data.
   - ETL will be implemented separately.
   ============================================================ */

USE smartfactory;
GO

/* ============================================================
   1. CREATE DW SCHEMA
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'dw'
)
    EXEC('CREATE SCHEMA dw');
GO


/* ============================================================
   2. DIMENSION TABLES
   ============================================================ */


/* -------------------------
   DIM DATE

   DateKey format: YYYYMMDD
   ------------------------- */

CREATE TABLE dw.DimDate (
    DateKey INT NOT NULL PRIMARY KEY,
    FullDate DATE NOT NULL,

    DayNumber TINYINT,
    WeekNumber TINYINT,
    MonthNumber TINYINT,
    MonthName NVARCHAR(20),
    QuarterNumber TINYINT,
    YearNumber SMALLINT,

    WeekdayName NVARCHAR(20),

    IsWeekend BIT,
    IsPlantDay BIT,
    IsHoliday BIT,
    HolidayName NVARCHAR(100),
    IsRamadan BIT,

    Season NVARCHAR(30),
    AvgAmbientTempC DECIMAL(6,2),

    CONSTRAINT UQ_DimDate_FullDate
        UNIQUE (FullDate)
);
GO


/* -------------------------
   DIM LINE
   ------------------------- */

CREATE TABLE dw.DimLine (
    LineKey INT IDENTITY(1,1) PRIMARY KEY,

    LineID NVARCHAR(100),
    LineName NVARCHAR(150),

    ProductCategory NVARCHAR(100),
    Building NVARCHAR(100),

    ShiftsPerDay TINYINT,
    OperatingDays NVARCHAR(100),

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM MACHINE

   SourceLineID is retained
   for source traceability.
   ------------------------- */

CREATE TABLE dw.DimMachine (
    MachineKey INT IDENTITY(1,1) PRIMARY KEY,

    MachineID NVARCHAR(100),
    MachineName NVARCHAR(150),
    AssetTag NVARCHAR(100),

    SourceLineID NVARCHAR(100),

    ProcessStep INT,
    ProcessStage NVARCHAR(100),
    MachineType NVARCHAR(100),

    IdealRatePerHour DECIMAL(12,2),

    Manufacturer NVARCHAR(150),
    InstallDate DATE,

    ValueAddedFactor DECIMAL(8,4),

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM PRODUCT
   ------------------------- */

CREATE TABLE dw.DimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,

    ProductID NVARCHAR(100),
    ProductName NVARCHAR(200),

    SKU NVARCHAR(100),
    ProductFamily NVARCHAR(100),

    SourceLineID NVARCHAR(100),

    SizeML DECIMAL(12,2),
    PackType NVARCHAR(100),

    UnitCost DECIMAL(18,4),
    SellingPrice DECIMAL(18,4),

    RateFactor DECIMAL(8,4),

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM SHIFT
   ------------------------- */

CREATE TABLE dw.DimShift (
    ShiftKey INT IDENTITY(1,1) PRIMARY KEY,

    ShiftID NVARCHAR(100),
    ShiftName NVARCHAR(100),

    StartTime TIME(0),
    EndTime TIME(0),

    PlannedMinutes INT,

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM OPERATOR
   ------------------------- */

CREATE TABLE dw.DimOperator (
    OperatorKey INT IDENTITY(1,1) PRIMARY KEY,

    OperatorID NVARCHAR(100),
    OperatorName NVARCHAR(150),

    SourceLineID NVARCHAR(100),
    SourceShiftID NVARCHAR(100),

    HireDate DATE,
    PriorExperienceYears DECIMAL(5,2),

    CertificationDate DATE,
    IsCertified BIT,

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM DOWNTIME REASON
   ------------------------- */

CREATE TABLE dw.DimDowntimeReason (
    DowntimeReasonKey INT IDENTITY(1,1) PRIMARY KEY,

    ReasonID NVARCHAR(100),
    ReasonName NVARCHAR(150),

    Category NVARCHAR(100),
    IsPlanned BIT,

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM DEFECT TYPE
   ------------------------- */

CREATE TABLE dw.DimDefectType (
    DefectTypeKey INT IDENTITY(1,1) PRIMARY KEY,

    DefectID NVARCHAR(100),
    DefectName NVARCHAR(150),

    DefectCategory NVARCHAR(100),
    IsReworkable BIT,

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM SUPPLIER
   ------------------------- */

CREATE TABLE dw.DimSupplier (
    SupplierKey INT IDENTITY(1,1) PRIMARY KEY,

    SupplierID NVARCHAR(100),
    SupplierCode NVARCHAR(100),

    SupplierName NVARCHAR(200),
    Country NVARCHAR(100),

    MaterialType NVARCHAR(100),
    LeadTimeDays INT,

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* -------------------------
   DIM MATERIAL BATCH
   ------------------------- */

CREATE TABLE dw.DimMaterialBatch (
    MaterialBatchKey INT IDENTITY(1,1) PRIMARY KEY,

    BatchID NVARCHAR(100),

    SupplierCode NVARCHAR(100),
    SupplierName NVARCHAR(200),

    MaterialType NVARCHAR(100),

    ReceivedDate DATE,
    QualityGrade NVARCHAR(20),

    SourceSystem NVARCHAR(100)
        DEFAULT 'SmartFactory'
);
GO


/* ============================================================
   3. FACT TABLES
   ============================================================ */


/* -------------------------
   FACT PRODUCTION

   Grain:
   One source production record.

   Business identifiers:
   ProductionID, OrderID
   ------------------------- */

CREATE TABLE dw.FactProduction (
    ProductionFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    ProductionID NVARCHAR(100),
    OrderID NVARCHAR(100),

    DateKey INT,
    LineKey INT,
    ShiftKey INT,
    MachineKey INT,
    ProductKey INT,
    OperatorKey INT,
    MaterialBatchKey INT,
    SupplierKey INT,

    PlannedTimeMin DECIMAL(12,2),
    DowntimeMin DECIMAL(12,2),
    RunTimeMin DECIMAL(12,2),

    IdealRatePerHour DECIMAL(12,2),

    TotalUnits BIGINT,
    GoodUnits BIGINT,
    DefectiveUnits BIGINT,
    ScrapUnits BIGINT,
    ReworkUnits BIGINT,

    EntrySource NVARCHAR(100),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactProduction_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactProduction_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactProduction_Shift
        FOREIGN KEY (ShiftKey)
        REFERENCES dw.DimShift(ShiftKey),

    CONSTRAINT FK_FactProduction_Machine
        FOREIGN KEY (MachineKey)
        REFERENCES dw.DimMachine(MachineKey),

    CONSTRAINT FK_FactProduction_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactProduction_Operator
        FOREIGN KEY (OperatorKey)
        REFERENCES dw.DimOperator(OperatorKey),

    CONSTRAINT FK_FactProduction_Batch
        FOREIGN KEY (MaterialBatchKey)
        REFERENCES dw.DimMaterialBatch(MaterialBatchKey),

    CONSTRAINT FK_FactProduction_Supplier
        FOREIGN KEY (SupplierKey)
        REFERENCES dw.DimSupplier(SupplierKey)
);
GO


/* -------------------------
   FACT DOWNTIME

   Grain:
   One downtime event.

   ProductionID is a
   degenerate business identifier.
   ------------------------- */

CREATE TABLE dw.FactDowntime (
    DowntimeFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    DowntimeID NVARCHAR(100),
    ProductionID NVARCHAR(100),

    DateKey INT,
    LineKey INT,
    ShiftKey INT,
    MachineKey INT,
    ProductKey INT,
    OperatorKey INT,

    DowntimeReasonKey INT,

    StartTime TIME(0),
    EndTime TIME(0),

    DurationMin DECIMAL(12,2),

    IsMicroStop BIT,

    OperatorComment NVARCHAR(MAX),
    Source NVARCHAR(100),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactDowntime_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactDowntime_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactDowntime_Shift
        FOREIGN KEY (ShiftKey)
        REFERENCES dw.DimShift(ShiftKey),

    CONSTRAINT FK_FactDowntime_Machine
        FOREIGN KEY (MachineKey)
        REFERENCES dw.DimMachine(MachineKey),

    CONSTRAINT FK_FactDowntime_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactDowntime_Operator
        FOREIGN KEY (OperatorKey)
        REFERENCES dw.DimOperator(OperatorKey),

    CONSTRAINT FK_FactDowntime_Reason
        FOREIGN KEY (DowntimeReasonKey)
        REFERENCES dw.DimDowntimeReason(DowntimeReasonKey)
);
GO


/* -------------------------
   FACT DEFECTS

   Grain:
   One source defect record.
   ------------------------- */

CREATE TABLE dw.FactDefects (
    DefectFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    DefectRecordID NVARCHAR(100),
    ProductionID NVARCHAR(100),

    DateKey INT,
    LineKey INT,
    ShiftKey INT,
    MachineKey INT,
    ProductKey INT,
    OperatorKey INT,

    DefectTypeKey INT,

    Quantity BIGINT,

    Disposition NVARCHAR(50),
    CostLost DECIMAL(18,4),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactDefects_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactDefects_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactDefects_Shift
        FOREIGN KEY (ShiftKey)
        REFERENCES dw.DimShift(ShiftKey),

    CONSTRAINT FK_FactDefects_Machine
        FOREIGN KEY (MachineKey)
        REFERENCES dw.DimMachine(MachineKey),

    CONSTRAINT FK_FactDefects_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactDefects_Operator
        FOREIGN KEY (OperatorKey)
        REFERENCES dw.DimOperator(OperatorKey),

    CONSTRAINT FK_FactDefects_DefectType
        FOREIGN KEY (DefectTypeKey)
        REFERENCES dw.DimDefectType(DefectTypeKey)
);
GO


/* -------------------------
   FACT MAINTENANCE

   Grain:
   One maintenance work order.

   DowntimeID retained as
   a business identifier.
   ------------------------- */

CREATE TABLE dw.FactMaintenance (
    MaintenanceFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    WorkOrderID NVARCHAR(100),
    DowntimeID NVARCHAR(100),

    MachineKey INT,
    LineKey INT,

    OpenedAt DATETIME2(0),
    ClosedAt DATETIME2(0),

    OpenedDateKey INT,
    ClosedDateKey INT,

    WOType NVARCHAR(100),
    Priority NVARCHAR(50),
    Status NVARCHAR(50),

    DowntimeMin DECIMAL(12,2),

    Technician NVARCHAR(150),
    LaborHours DECIMAL(12,2),

    PartsCostUSD DECIMAL(18,4),
    FailureMode NVARCHAR(200),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactMaintenance_Machine
        FOREIGN KEY (MachineKey)
        REFERENCES dw.DimMachine(MachineKey),

    CONSTRAINT FK_FactMaintenance_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactMaintenance_OpenedDate
        FOREIGN KEY (OpenedDateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactMaintenance_ClosedDate
        FOREIGN KEY (ClosedDateKey)
        REFERENCES dw.DimDate(DateKey)
);
GO


/* -------------------------
   FACT PRODUCTION ORDERS

   Grain:
   One production order.
   ------------------------- */

CREATE TABLE dw.FactProductionOrders (
    ProductionOrderFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    OrderID NVARCHAR(100),

    LineKey INT,
    ProductKey INT,

    PlannedStartDateKey INT,
    ActualEndDateKey INT,
    DueDateKey INT,

    PlannedQty BIGINT,
    ProducedGoodQty BIGINT,

    FillRate DECIMAL(10,4),

    Status NVARCHAR(50),
    Priority NVARCHAR(50),
    CustomerChannel NVARCHAR(100),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactOrders_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactOrders_Product
        FOREIGN KEY (ProductKey)
        REFERENCES dw.DimProduct(ProductKey),

    CONSTRAINT FK_FactOrders_PlannedDate
        FOREIGN KEY (PlannedStartDateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactOrders_ActualDate
        FOREIGN KEY (ActualEndDateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactOrders_DueDate
        FOREIGN KEY (DueDateKey)
        REFERENCES dw.DimDate(DateKey)
);
GO


/* -------------------------
   FACT SENSOR READINGS

   Grain:
   One source sensor reading.
   ------------------------- */

CREATE TABLE dw.FactSensorReadings (
    SensorFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    ReadingID NVARCHAR(100),

    Timestamp DATETIME2(0),
    DateKey INT,

    LineKey INT,
    MachineKey INT,

    TemperatureC DECIMAL(12,4),
    VibrationMmS DECIMAL(12,4),
    PressureBar DECIMAL(12,4),

    SpeedPct DECIMAL(12,4),
    PowerKW DECIMAL(12,4),

    LoadDate DATETIME2(0)
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_FactSensor_Date
        FOREIGN KEY (DateKey)
        REFERENCES dw.DimDate(DateKey),

    CONSTRAINT FK_FactSensor_Line
        FOREIGN KEY (LineKey)
        REFERENCES dw.DimLine(LineKey),

    CONSTRAINT FK_FactSensor_Machine
        FOREIGN KEY (MachineKey)
        REFERENCES dw.DimMachine(MachineKey)
);
GO


/* ============================================================
   4. INDEXES
   ============================================================ */


/* FACT PRODUCTION */

CREATE INDEX IX_FactProduction_Date
ON dw.FactProduction(DateKey);

CREATE INDEX IX_FactProduction_Line
ON dw.FactProduction(LineKey);

CREATE INDEX IX_FactProduction_Machine
ON dw.FactProduction(MachineKey);

CREATE INDEX IX_FactProduction_Product
ON dw.FactProduction(ProductKey);

CREATE INDEX IX_FactProduction_Shift
ON dw.FactProduction(ShiftKey);


/* FACT DOWNTIME */

CREATE INDEX IX_FactDowntime_Date
ON dw.FactDowntime(DateKey);

CREATE INDEX IX_FactDowntime_Line
ON dw.FactDowntime(LineKey);

CREATE INDEX IX_FactDowntime_Machine
ON dw.FactDowntime(MachineKey);


/* FACT DEFECTS */

CREATE INDEX IX_FactDefects_Date
ON dw.FactDefects(DateKey);

CREATE INDEX IX_FactDefects_Line
ON dw.FactDefects(LineKey);

CREATE INDEX IX_FactDefects_DefectType
ON dw.FactDefects(DefectTypeKey);


/* FACT MAINTENANCE */

CREATE INDEX IX_FactMaintenance_Machine
ON dw.FactMaintenance(MachineKey);

CREATE INDEX IX_FactMaintenance_Line
ON dw.FactMaintenance(LineKey);

CREATE INDEX IX_FactMaintenance_OpenedDate
ON dw.FactMaintenance(OpenedDateKey);


/* FACT PRODUCTION ORDERS */

CREATE INDEX IX_FactOrders_PlannedDate
ON dw.FactProductionOrders(PlannedStartDateKey);

CREATE INDEX IX_FactOrders_Product
ON dw.FactProductionOrders(ProductKey);


/* FACT SENSOR READINGS */

CREATE INDEX IX_FactSensor_Timestamp
ON dw.FactSensorReadings(Timestamp);

CREATE INDEX IX_FactSensor_Machine_Timestamp
ON dw.FactSensorReadings(MachineKey, Timestamp);
GO


/* ============================================================
   5. OEE VIEW

   OEE = Availability * Performance * Quality

   Grain:
   One machine, one shift, one date.

   Note:
   Validate time definitions before business use.
   ============================================================ */

CREATE OR ALTER VIEW dw.v_OEE_Machine_Shift_Date
AS

WITH ProductionSummary AS (
    SELECT
        DateKey,
        LineKey,
        ShiftKey,
        MachineKey,

        SUM(CAST(RunTimeMin AS DECIMAL(19,4)))
            AS TotalRunTimeMin,

        SUM(CAST(PlannedTimeMin AS DECIMAL(19,4)))
            AS TotalPlannedTimeMin,

        SUM(CAST(TotalUnits AS DECIMAL(19,4)))
            AS TotalUnits,

        SUM(CAST(GoodUnits AS DECIMAL(19,4)))
            AS GoodUnits,

        SUM(
            CAST(RunTimeMin AS DECIMAL(19,4))
            *
            CAST(IdealRatePerHour AS DECIMAL(19,4))
            / 60.0
        ) AS ExpectedUnits

    FROM dw.FactProduction

    GROUP BY
        DateKey,
        LineKey,
        ShiftKey,
        MachineKey
)

SELECT
    ps.DateKey,
    ps.LineKey,
    ps.ShiftKey,

    ps.MachineKey,
    m.MachineID,
    m.MachineName,

    ps.TotalRunTimeMin,
    ps.TotalPlannedTimeMin,

    ps.TotalUnits,
    ps.GoodUnits,

    CAST(
        ps.TotalRunTimeMin /
        NULLIF(ps.TotalPlannedTimeMin, 0)
        AS DECIMAL(12,4)
    ) AS Availability,

    CAST(
        ps.TotalUnits /
        NULLIF(ps.ExpectedUnits, 0)
        AS DECIMAL(12,4)
    ) AS Performance,

    CAST(
        ps.GoodUnits /
        NULLIF(ps.TotalUnits, 0)
        AS DECIMAL(12,4)
    ) AS Quality,

    CAST(
        (
            ps.TotalRunTimeMin /
            NULLIF(ps.TotalPlannedTimeMin, 0)
        )
        *
        (
            ps.TotalUnits /
            NULLIF(ps.ExpectedUnits, 0)
        )
        *
        (
            ps.GoodUnits /
            NULLIF(ps.TotalUnits, 0)
        )
        AS DECIMAL(12,4)
    ) AS OEE

FROM ProductionSummary ps

INNER JOIN dw.DimMachine m
    ON ps.MachineKey = m.MachineKey;
GO


/* ============================================================
   6. VALIDATION
   ============================================================ */

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t

INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id

WHERE s.name = 'dw'

ORDER BY t.name;
GO


PRINT 'Smart Factory DW schema v2.0 created successfully.';
GO