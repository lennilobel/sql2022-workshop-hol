/* =================== Temporal Data =================== */

USE MyDB
GO


/* Creating a new temporal table */

-- Create system-versioned table (temporal table) with custom history table name (must specify schema)
CREATE TABLE Employee
(
	EmployeeId		int PRIMARY KEY,
	FirstName		varchar(20) NOT NULL,
	LastName		varchar(20) NOT NULL,
	DepartmentName	varchar(50) NOT NULL,
	ValidFrom		datetime2 GENERATED ALWAYS AS ROW START NOT NULL, 
	ValidTo			datetime2 GENERATED ALWAYS AS ROW END NOT NULL,   
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))
GO

-- Show tables (base table and history table)
SELECT
	object_id,
	name,
	temporal_type,
	temporal_type_desc,
	history_table_id
 FROM
	sys.tables
 WHERE
	object_id = OBJECT_ID('dbo.Employee', 'U') OR
	object_id = ( 
		SELECT history_table_id 
		FROM sys.tables
		WHERE object_id = OBJECT_ID('dbo.Employee', 'U')
)
GO

-- Cleanup
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
DROP TABLE Employee
DROP TABLE EmployeeHistory
GO


/* Converting an existing table to temporal */

CREATE TABLE Employee
(
	EmployeeId		int PRIMARY KEY,
	FirstName		varchar(20) NOT NULL,
	LastName		varchar(20) NOT NULL,
	DepartmentName	varchar(50) NOT NULL,
)
GO

INSERT INTO Employee VALUES
 (1, 'Ken',		'Sanchez',		'Executive'),
 (2, 'Terri',	'Duffy',		'Engineering'),
 (3, 'Roberto',	'Tamburello',	'Engineering'),
 (4, 'Rob',		'Walters',		'Engineering'),
 (5, 'Gail',	'Erickson',		'Engineering'),
 (6, 'Jossef',	'Goldberg',		'Engineering')
GO

SELECT * FROM Employee

-- Convert to temporal table by adding required datetime2 column pair in PERIOD FOR SYSTEM_TIME
ALTER TABLE Employee ADD
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT CAST('1900-01-01 00:00:00.0000000' AS datetime2),
    ValidTo   datetime2 GENERATED ALWAYS AS ROW END   NOT NULL DEFAULT CAST('9999-12-31 23:59:59.9999999' AS datetime2),
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
GO

-- Turn on temporal (table must have a PK and SYSTEM_TIME period)
ALTER TABLE Employee 
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))
GO


/* Apply changes (update/delete) */

-- History table starts out empty with no changes made yet
SELECT * FROM Employee
SELECT * FROM EmployeeHistory

-- Update row 5 three times (FirstName, then DepartmentName twice)
UPDATE Employee SET FirstName = 'Gabriel' WHERE EmployeeId = 5
WAITFOR DELAY '00:00:02'
UPDATE Employee SET DepartmentName = 'Support' WHERE EmployeeId = 5
WAITFOR DELAY '00:00:02'
UPDATE Employee SET DepartmentName = 'Executive' WHERE EmployeeId = 5

-- Delete row 2
DELETE Employee WHERE EmployeeId = 2
GO
 
-- History table shows the changes
SELECT * FROM Employee
SELECT * FROM EmployeeHistory ORDER BY EmployeeId, ValidFrom
GO

-- Try again with pre-populated history
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
DROP TABLE Employee
DROP TABLE EmployeeHistory


/* Pre-populate history */

CREATE TABLE Employee
(
	EmployeeId		int PRIMARY KEY,
	FirstName		varchar(20) NOT NULL,
	LastName		varchar(20) NOT NULL,
	DepartmentName	varchar(50) NOT NULL,
	ValidFrom		datetime2 NOT NULL, 
	ValidTo			datetime2 NOT NULL
)

CREATE TABLE EmployeeHistory
(
	EmployeeId		int NOT NULL,
	FirstName		varchar(20) NOT NULL,
	LastName		varchar(20) NOT NULL,
	DepartmentName	varchar(50) NOT NULL,
	ValidFrom		datetime2 NOT NULL, 
	ValidTo			datetime2 NOT NULL
)

INSERT INTO Employee VALUES
 (1, 'Ken',		'Sanchez',		'Executive',	'2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (3, 'Roberto',	'Tamburello',	'Engineering',	'2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (4, 'Rob',		'Walters',		'Engineering',	'2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (5, 'Gabriel',	'Erickson',		'Executive',	'2018-12-03 09:00:00', '9999-12-31 23:59:59.9999999'),
 (6, 'Jossef',	'Goldberg',		'Engineering',	'2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999')

INSERT INTO EmployeeHistory VALUES
 (2, 'Terri',	'Duffy',		'Engineering',	'2018-10-07 08:33:00', '2018-11-16 00:00:00'),	-- deleted 11/16
 (5, 'Gabriel',	'Erickson',		'Support',		'2018-11-18 04:26:00', '2018-12-03 09:00:00'),
 (5, 'Gabriel',	'Erickson',		'Engineering',	'2018-11-01 11:59:00', '2018-11-18 04:26:00'),
 (5, 'Gail',	'Erickson',		'Engineering',	'2018-10-07 08:33:00', '2018-11-01 11:59:00')

ALTER TABLE Employee
 ADD PERIOD FOR SYSTEM_TIME (ValidFrom,ValidTo)

ALTER TABLE Employee SET (SYSTEM_VERSIONING = ON (
	HISTORY_TABLE = dbo.EmployeeHistory,
	DATA_CONSISTENCY_CHECK = ON)
)

-- History table shows the changes
SELECT * FROM Employee
SELECT * FROM EmployeeHistory ORDER BY EmployeeId, ValidFrom
GO


/* Run temporal queries */

-- 1) FOR SYSTEM_TIME AS OF

SELECT * FROM Employee ORDER BY EmployeeId										-- Gabriel Erickson, Executive		Deleted
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-12-01' ORDER BY EmployeeId	-- Gabriel Erickson, Support		Deleted
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-15' ORDER BY EmployeeId	-- Gabriel Erickson, Engineering	Exists
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-10-10' ORDER BY EmployeeId	-- Gail Erickson, Engineering		Exists
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-10-01' ORDER BY EmployeeId	-- No data

-- When AS OF falls on boundary, later version is returned (matches on ValidFrom, not ValidTo)
SELECT * FROM EmployeeHistory WHERE ValidFrom = '2018-11-18 04:26:00' OR ValidTo = '2018-11-18 04:26:00' ORDER BY EmployeeId, ValidFrom
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:26:00' ORDER BY EmployeeId	-- Support
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:25:59' ORDER BY EmployeeId	-- Engineering

-- 2) FOR SYSTEM_TIME FROM A TO B

-- All time
SELECT * FROM Employee FOR SYSTEM_TIME FROM '1900-01-01' TO '9999-12-31' WHERE EmployeeId = 5

-- Within range
SELECT * FROM Employee FOR SYSTEM_TIME FROM '2018-11-02' TO '2018-12-01' WHERE EmployeeId = 5

-- Using same value for A and B behaves like AS OF
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:26:01' WHERE EmployeeId = 5
SELECT * FROM Employee FOR SYSTEM_TIME FROM  '2018-11-18 04:26:01' TO '2018-11-18 04:26:01' WHERE EmployeeId = 5

-- ...unless the value is on a boundary of two versions - then you get ZERO records!
SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:26:00' WHERE EmployeeId = 5
SELECT * FROM Employee FOR SYSTEM_TIME FROM  '2018-11-18 04:26:00' TO '2018-11-18 04:26:00' WHERE EmployeeId = 5

-- 3) FOR SYSTEM_TIME BETWEEN A AND B

-- These two are equivalent
SELECT * FROM Employee FOR SYSTEM_TIME FROM    '2018-11-02' TO  '2018-12-03 08:59:59' WHERE EmployeeId = 5
SELECT * FROM Employee FOR SYSTEM_TIME BETWEEN '2018-11-02' AND '2018-12-03 08:59:59' WHERE EmployeeId = 5

-- With BETWEEN we get an extra row for upper bound match on ValidFrom
SELECT * FROM Employee FOR SYSTEM_TIME FROM    '2018-11-02' TO  '2018-12-03 09:00:00' WHERE EmployeeId = 5
SELECT * FROM Employee FOR SYSTEM_TIME BETWEEN '2018-11-02' AND '2018-12-03 09:00:00' WHERE EmployeeId = 5

-- 4) FOR SYSTEM_TIME CONTAINED IN (A, B)

SELECT * FROM Employee FOR SYSTEM_TIME FROM			'2018-11-02' TO	'2018-12-04'	WHERE EmployeeId = 5
SELECT * FROM Employee FOR SYSTEM_TIME CONTAINED IN('2018-11-02',	'2018-12-04')	WHERE EmployeeId = 5


/* Schema changes */

-- Add a column (gets added to history table automatically)
ALTER TABLE Employee
   ADD RegionID int NULL

SELECT * FROM Employee
SELECT * FROM EmployeeHistory

-- Drop a column (gets dropped from history table automatically)
ALTER TABLE Employee
   DROP COLUMN RegionID

SELECT * FROM Employee
SELECT * FROM EmployeeHistory


/* Hidden period columns */

-- Create and populate a system-versioned table with hidden period columns
CREATE TABLE Employee2(
	EmployeeId int PRIMARY KEY,
	FirstName varchar(20) NOT NULL,
	LastName varchar(20) NOT NULL,
	DepartmentName varchar(50) NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo   datetime2 GENERATED ALWAYS AS ROW END HIDDEN   NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Employee2History))
GO

INSERT INTO Employee2 (EmployeeId, FirstName, LastName, DepartmentName) VALUES
 (1, 'Ken', 'Sanchez', 'Executive'),
 (2, 'Terri', 'Duffy', 'Engineering'),
 (3, 'Roberto', 'Tamburello', 'Engineering')

-- Hidden period columns are not returned with SELECT *
SELECT * FROM Employee2

-- Hidden period columns can be returned explicitly
SELECT EmployeeId, LastName, ValidFrom, ValidTo FROM Employee2

-- Cleanup
ALTER TABLE Employee2 SET (SYSTEM_VERSIONING = OFF)
GO
DROP TABLE Employee2
DROP TABLE Employee2History
GO
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
GO
DROP TABLE Employee
DROP TABLE EmployeeHistory
