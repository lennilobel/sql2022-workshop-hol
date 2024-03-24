/* =================== IS [NOT] DISTINCT FROM =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/queries/is-distinct-from-transact-sql?view=sql-server-ver16

USE MyDB
GO

DROP TABLE IF EXISTS Sample
GO

CREATE TABLE Sample (
	Id int IDENTITY PRIMARY KEY,
	Value int,
	Message nvarchar(50)
)

CREATE NONCLUSTERED INDEX IDX_Sample_Value ON Sample (Value)

INSERT INTO Sample VALUES 
 (NULL, 'hello'),
 (10, NULL),
 (17, 'abc'),
 (17, 'yes'),
 (NULL, NULL)

GO

SELECT * FROM Sample WHERE Value != 17						-- Gets non-17, but ignores NULLs
SELECT * FROM Sample WHERE Value != 17 OR Value IS NULL		-- Gets non-17, including NULLs
SELECT * FROM Sample WHERE Value != 17 OR Value = NULL		-- Using = with NULL never works

-- Using IS DISTINCT FROM
SELECT * FROM Sample WHERE Value IS DISTINCT FROM 17		-- Gets non-17, including NULLs

-- Using IS DISTINCT FROM NULL isn't helpful, since it's the same as IS NOT NULL
SELECT * FROM Sample WHERE Value IS DISTINCT FROM NULL		-- Gets non-NULLs
SELECT * FROM Sample WHERE Value IS NOT NULL				-- Gets non-NULLs
SELECT * FROM Sample WHERE Value != NULL					-- Never works

-- Using IS NOT DISTINCT FROM
SELECT * FROM Sample WHERE Value IS NOT DISTINCT FROM 17	-- Gets 17
SELECT * FROM Sample WHERE Value = 17						-- Gets 17

-- Using IS NOT DISTINCT FROM NULL isn't helpful, since it's the same as IS NULL
SELECT * FROM Sample WHERE Value IS NOT DISTINCT FROM NULL	-- Gets the NULLs (same as IS NULL)
SELECT * FROM Sample WHERE Value IS NULL					-- Gets the NULLs
SELECT * FROM Sample WHERE Value = NULL						-- Never works


USE WideWorldImporters
GO

DROP INDEX IF EXISTS Sales.Orders.IDX_Orders_PickingCompletedWhen;
GO

CREATE NONCLUSTERED INDEX IDX_Orders_PickingCompletedWhen ON Sales.Orders (PickingCompletedWhen);
GO



-- This is a demo for the enhanced IS [NOT] DISTINCT FROM T-SQL function in SQL Server 2022
-- Enable Include Actual Execution Plan for each query

-- Find all the orders for a specific picking completion date (should yield 35 rows using an index seek)
DECLARE @dt datetime2 = '2013-01-01 12:00:00.0000000'

SELECT * FROM Sales.Orders
WHERE
	PickingCompletedWhen = @dt

GO

-- Find all the orders where picking was not completed (when comparing with NULL using =, this returns 0 rows even though there are 3085 rows with a NULL value)
DECLARE @dt datetime2 = NULL

SELECT * FROM Sales.Orders
WHERE
	PickingCompletedWhen = @dt

SELECT * FROM Sales.Orders
WHERE
	PickingCompletedWhen IS NULL

GO

-- Try to use ISNULL to convert NULL to 12/31/9999 (works, but requires an index scan)
DECLARE @dt AS datetime2 = NULL

SELECT * FROM Sales.Orders
WHERE
	ISNULL(PickingCompletedWhen, '9999-12-31 23:59:59.9999999') = ISNULL(@dt, '9999-12-31 23:59:59.9999999')

GO

-- Try to use IS NULL in addition to = for comparing both non-NULL and NULL values (works, but requires an index scan)
DECLARE @dt AS date = NULL

SELECT * FROM Sales.Orders
WHERE
	(@dt IS NOT NULL AND PickingCompletedWhen = @dt) OR
	(@dt IS NULL AND PickingCompletedWhen IS NULL)

GO

-- Use IS NOT DISTINCT FROM (works for both NULL and non-NULL checks, using an index seek)
DECLARE @dt datetime2
SET @dt = NULL -- '2013-01-01 12:00:00.0000000'

SELECT * FROM Sales.Orders
WHERE
	PickingCompletedWhen IS NOT DISTINCT FROM @dt

GO

-- Cleanup

USE WideWorldImporters
GO
DROP INDEX IF EXISTS Sales.Orders.IDX_Orders_PickingCompletedWhen
GO
USE MyDB
GO
DROP TABLE IF EXISTS Sample
GO
