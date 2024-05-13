-- IS [NOT] DISTINCT FROM Comparison Operator

USE AdventureWorks2019
GO

-- Using = or != is insufficient when considering NULLs
CREATE OR ALTER PROCEDURE TestForEquality(@Value1 int, @Value2 int) AS
BEGIN

	IF @Value1 = @Value2   PRINT 'Equal'
	IF @Value1 != @Value2  PRINT 'Not Equal'

END
GO

EXEC TestForEquality 5, 10
EXEC TestForEquality 5, 5
EXEC TestForEquality 5, NULL
EXEC TestForEquality NULL, NULL
GO

-- Must combine IS [NOT] NULL with = or !=
CREATE OR ALTER PROCEDURE TestForEquality(@Value1 int, @Value2 int) AS
BEGIN

	IF (@Value1 = @Value2 AND @Value1 IS NOT NULL AND @Value2 IS NOT NULL) OR (@Value1 IS NULL AND @Value2 IS NULL)	PRINT 'Equal'
	IF (@Value1 != @Value2 AND @Value1 IS NOT NULL AND @Value2 IS NOT NULL) OR (@Value1 IS NULL AND @Value2 IS NOT NULL) OR (@Value1 IS NOT NULL AND @Value2 IS NULL)  PRINT 'Not Equal'

END
GO

EXEC TestForEquality 5, 10
EXEC TestForEquality 5, 5
EXEC TestForEquality 5, NULL
EXEC TestForEquality NULL, NULL
GO

-- Use IS [NOT] DISTINCT FROM to handle NULLs as ordinary values
CREATE OR ALTER PROCEDURE TestForEquality(@Value1 int, @Value2 int) AS
BEGIN

	IF @Value1 IS NOT DISTINCT FROM @Value2		PRINT 'Equal'
	IF @Value1 IS DISTINCT FROM @Value2			PRINT 'Not Equal'

END
GO

EXEC TestForEquality 5, 10
EXEC TestForEquality 5, 5
EXEC TestForEquality 5, NULL
EXEC TestForEquality NULL, NULL

-- *** Usage in Data Retrieval

USE WideWorldImporters
GO

SELECT * FROM Sales.Orders

SELECT COUNT(*) FROM Sales.Orders
SELECT COUNT(*) FROM Sales.Orders WHERE PickingCompletedWhen IS NULL

CREATE NONCLUSTERED INDEX IDX_Orders_PickingCompletedWhen ON Sales.Orders (PickingCompletedWhen)

-- Enable actual execution plan (press `Ctrl+M`)

-- Next, we execute a parameterized query to identify all orders for a specified picking completion date. We expect to see 35 rows retrieved.

-- Find all the orders for a specific picking completion date (should yield 35 rows using an index seek)
DECLARE @dt datetime2 = '2013-01-01 12:00:00.0000000'

-- Using = leverages an index seek
SELECT * FROM Sales.Orders
WHERE PickingCompletedWhen = @dt

GO

-- Using =, we get 0 rows when @dt is NULL, even though there are 3085 rows with a NULL value
DECLARE @dt datetime2 = NULL

SELECT * FROM Sales.Orders
WHERE PickingCompletedWhen = @dt

GO

-- Using ISNULL and a Predetermined Value

-- Use ISNULL with predetermined value for comparing both non-NULL and NULL values (works, but requires an index scan)
DECLARE @dt datetime2

SET @dt = '2013-01-01 12:00:00.0000000'
SELECT * FROM Sales.Orders
WHERE ISNULL(PickingCompletedWhen, '9999-12-31 23:59:59.9999999') = ISNULL(@dt, '9999-12-31 23:59:59.9999999')

SET @dt = NULL
SELECT * FROM Sales.Orders
WHERE ISNULL(PickingCompletedWhen, '9999-12-31 23:59:59.9999999') = ISNULL(@dt, '9999-12-31 23:59:59.9999999')

GO

-- Use IS NULL in addition to = for comparing both non-NULL and NULL values (works, but requires an index scan)
DECLARE @dt datetime2

SET @dt = '2013-01-01 12:00:00.0000000'
SELECT * FROM Sales.Orders
WHERE
    (@dt IS NOT NULL AND PickingCompletedWhen = @dt) OR
    (@dt IS NULL AND PickingCompletedWhen IS NULL)

SET @dt = NULL
SELECT * FROM Sales.Orders
WHERE
    (@dt IS NOT NULL AND PickingCompletedWhen = @dt) OR
    (@dt IS NULL AND PickingCompletedWhen IS NULL)

GO

-- Use IS NOT DISTINCT FROM (works for both NULL and non-NULL checks, using an index seek)
DECLARE @dt datetime2

SET @dt = '2013-01-01 12:00:00.0000000'
SELECT * FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT DISTINCT FROM @dt

SET @dt = NULL
SELECT * FROM Sales.Orders
WHERE PickingCompletedWhen IS NOT DISTINCT FROM @dt

-- Cleanup
DROP INDEX Sales.Orders.IDX_Orders_PickingCompletedWhen
