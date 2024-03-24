/* Custom history cleanup script - keep most recent N change(s) only */

USE MyDB
GO

-- (begin populate)
CREATE TABLE Employee
(
	EmployeeId		int PRIMARY KEY,
	FirstName		varchar(20) NOT NULL,
	LastName		varchar(20) NOT NULL,
	Salary			int,
	ValidFrom		datetime2 GENERATED ALWAYS AS ROW START NOT NULL,
	ValidTo			datetime2 GENERATED ALWAYS AS ROW END   NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))
GO

INSERT INTO Employee (EmployeeId, FirstName, LastName, Salary) VALUES
 (1, 'Ken',		'Sanchez',		25000),
 (3, 'Roberto',	'Tamburello',	25000),
 (4, 'Rob',		'Walters',		25000),
 (5, 'Gail',	'Erickson',		25000)
GO

SELECT * FROM Employee
SELECT * FROM EmployeeHistory

GO
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
GO

-- Simulate one year-old history row of each employee with a prior Salary value of 20000
INSERT INTO EmployeeHistory (EmployeeId, FirstName, LastName, Salary, ValidFrom, ValidTo)
 SELECT EmployeeId, FirstName, LastName,
	20000,							-- Previous salary
	DATEADD(YEAR, -1, ValidFrom),	-- ValidFrom = current ValidFrom - YEAR
	ValidFrom						-- ValidTo = current ValidFrom
 FROM Employee

-- Simulate two year-old history row of each employee with a prior Salary value of 15000
INSERT INTO EmployeeHistory (EmployeeId, FirstName, LastName, Salary, ValidFrom, ValidTo)
 SELECT EmployeeId, FirstName, LastName,
	15000,							-- Previous salary
	DATEADD(YEAR, -1, ValidFrom),	-- ValidFrom = previous ValidFrom - YEAR
	ValidFrom						-- ValidTo = previous ValidFrom
 FROM EmployeeHistory

-- Simulate a history row that was created two years ago and deleted a year ago
INSERT INTO EmployeeHistory (EmployeeId, FirstName, LastName, Salary, ValidFrom, ValidTo)
 VALUES(2, 'Terri', 'Duffy',
	24500,									-- Previous salary
	DATEADD(YEAR, -2, SYSUTCDATETIME()),	-- ValidFrom = 2 years ago
	DATEADD(YEAR, -1, SYSUTCDATETIME()))	-- ValidTo = 1 year ago

ALTER TABLE Employee SET (SYSTEM_VERSIONING = ON (
	HISTORY_TABLE = dbo.EmployeeHistory,
	DATA_CONSISTENCY_CHECK = ON))
GO

-- Add another employee to the base table with no history
INSERT INTO Employee(EmployeeId, FirstName, LastName, Salary)
 VALUES(6, 'Jossef', 'Goldberg', 22750)

-- Perform one more update on row #5
UPDATE Employee
SET FirstName = 'Gabriel', Salary = 26250
WHERE EmployeeId = 5

-- (end populate)

SELECT *, [Table] = 'BASE' FROM Employee UNION ALL
SELECT *, [Table] = 'HISTORY' FROM EmployeeHistory
ORDER BY EmployeeId, ValidFrom

-- Number the history rows chronologically...
WITH HistoryCte AS 
(
  SELECT
	*,
	RowNum = ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY ValidFrom DESC)
  FROM
	EmployeeHistory
)
SELECT * FROM HistoryCte 
-- WHERE RowNum > 1
-- WHERE RowNum > 2
 ORDER BY EmployeeId, ValidFrom

-- ...then you can delete on row number
WITH HistoryCte AS 
(
  SELECT
	*,
	RowNum = ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY ValidFrom DESC)
  FROM
	EmployeeHistory
)
DELETE HistoryCte
 WHERE RowNum > 1

-- ensure that any potential writers will be blocked while the changes are taking place
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

	ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
	GO

	WITH HistoryCte AS 
	(
	  SELECT
		*,
		RowNum = ROW_NUMBER() OVER (PARTITION BY EmployeeId ORDER BY ValidFrom DESC)
	  FROM
		EmployeeHistory
	)
	DELETE HistoryCte
	 WHERE RowNum > 1  --  to delete in batches: https://sqlperformance.com/2013/03/io-subsystem/chunk-deletes

	SELECT @@ROWCOUNT AS DeletedRows
	-- ROLLBACK TRANSACTION

	GO
	ALTER TABLE Employee SET (SYSTEM_VERSIONING = ON (
		HISTORY_TABLE = dbo.EmployeeHistory,
		DATA_CONSISTENCY_CHECK = ON))
	GO

COMMIT TRANSACTION

SELECT * FROM Employee
SELECT * FROM EmployeeHistory

SELECT *, [Table] = 'BASE' FROM Employee UNION ALL
SELECT *, [Table] = 'HISTORY' FROM EmployeeHistory
ORDER BY EmployeeId, ValidFrom

GO
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
GO
DROP TABLE Employee
DROP TABLE EmployeeHistory
