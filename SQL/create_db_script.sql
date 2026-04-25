
-- 0. Create DB (if not exists)
IF DB_ID('TashlumimDB') IS NULL
BEGIN
    CREATE DATABASE TashlumimDB;
END;
GO

-- Use the DB
USE TashlumimDB;
GO

--1.Create tables.
-- Create Data table.
IF OBJECT_ID('dbo.t_data', 'U') IS NULL
BEGIN
    CREATE TABLE t_data (
        data_id INT PRIMARY KEY IDENTITY(1,1),
        a FLOAT NOT NULL,
        b FLOAT NOT NULL,
        c FLOAT NOT NULL,
        d FLOAT NOT NULL
);
END;

-- Create Targil table.
IF OBJECT_ID('dbo.t_targil', 'U') IS NULL
BEGIN
    CREATE TABLE t_targil (
        targil_id INT PRIMARY KEY IDENTITY(1,1),
        targil VARCHAR(MAX) NOT NULL,
        tnai VARCHAR(MAX) NULL,
        targil_false VARCHAR(MAX) NULL
    );
END;

-- Create Result table
IF OBJECT_ID('dbo.t_results', 'U') IS NULL
BEGIN
    CREATE TABLE t_results (
        resultsl_id INT PRIMARY KEY IDENTITY(1,1),
        data_id INT FOREIGN KEY REFERENCES t_data(data_id),
        targil_id INT FOREIGN KEY REFERENCES t_targil(targil_id),
        method VARCHAR(50) NOT NULL,
        result FLOAT
    );
END;

-- Create log table
IF OBJECT_ID('dbo.t_log', 'U') IS NULL
BEGIN
    CREATE TABLE t_log (
        log_id INT PRIMARY KEY IDENTITY(1,1),
        targil_id INT FOREIGN KEY REFERENCES t_targil(targil_id),
        method VARCHAR(50) NOT NULL,
        run_time FLOAT,
        calc_time FLOAT,
        write_time FLOAT
    );
END;

-- 2.Insert data.

-- Populating one million records using a CTE (Common Table Expression) with a leading semicolon.
;WITH Numbers AS (
    SELECT TOP (1000000) 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.t_data (a, b, c, d)
SELECT
    -- Using ABS(CHECKSUM(NEWID())) as a reliable seed for random float generation
    CAST(ABS(CHECKSUM(NEWID())) % 1000 / 10.0 AS FLOAT), 
    CAST(ABS(CHECKSUM(NEWID())) % 1000 / 10.0 AS FLOAT),
    CAST(ABS(CHECKSUM(NEWID())) % 101 AS FLOAT),
    CAST(ABS(CHECKSUM(NEWID())) % 5001 / 10.0 AS FLOAT)
FROM Numbers;

-- 3.Inserting sample formulas based on page 2 of the assignmen
INSERT INTO dbo.t_targil (targil, tnai, targil_false)
VALUES 
('a + b', NULL, NULL),                      -- Simple
('(a + b) * 8', NULL, NULL),                -- Complex
('b * 2', 'a > 5', 'b / 2'),                -- Conditional
('a + 1', 'b < 10', 'd - 1'),               -- Conditional
('POWER(c, 2)', NULL, NULL),                -- Math
('(a + b) * 2', 'c > 10', '(a + b) / 2'),   -- Conditional
('(a + b) * (c + d)', NULL, NULL);

