/* =================== GENERATE_SERIES =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/generate-series-transact-sql?view=sql-server-ver16

-- GENERATE_SERIES eliminates the need to use cumbersome numbers tables, recursive CTEs, and other on-the-fly
-- sequence generation techniques we've used in the past.

-- Do this this the old way, use a recursive CTE (ugly)
;WITH GenerateSeriesCte(value) AS 
(
	SELECT 1 UNION ALL 
	SELECT value + 1 FROM GenerateSeriesCte WHERE value < 1000
)
SELECT value = value FROM GenerateSeriesCte
OPTION (MAXRECURSION 1000)
GO

-- To use GENERATE_SERIES, database must be at compatibility level 160 (SQL Server 2022) or higher
SELECT compatibility_level FROM sys.databases WHERE name = 'AdventureWorks2019'
ALTER DATABASE AdventureWorks2019 SET COMPATIBILITY_LEVEL = 160
GO

-- 1 to 10
SELECT value
FROM GENERATE_SERIES(1, 10)

-- 1 to 50, step 5
SELECT value
FROM GENERATE_SERIES(1, 50, 5)

-- 0.0 to 1.0, step .1, parameterized
DECLARE @start decimal(2, 1) = 0.0
DECLARE @stop decimal(2, 1) = 1.0
DECLARE @step decimal(2, 1) = 0.1

SELECT value
FROM GENERATE_SERIES(@start, @stop, @step)

-- Generate a series of dates
GO
DECLARE @StartOn date = '2023-02-05'
DECLARE @EndOn date = '2023-11-15'

DECLARE @DayCount int = DATEDIFF(DAY, @StartOn, @EndOn)

SELECT
	TheDate = DATEADD(DAY, value, @StartOn)
FROM
	GENERATE_SERIES(0, @DayCount)

-- Build a contiguous series of date/time values to report on intervals, where not all intervals are populated
USE MyDB
GO

DROP TABLE IF EXISTS Sales
GO

CREATE TABLE Sales
(
	OrderDateTime	datetime,
	Total			decimal(12,2)
)

-- Populate sales data, where some hours have no sales
INSERT Sales(OrderDateTime, Total) VALUES
 ('2022-05-01 09:35', 21000),
 ('2022-05-01 09:47', 30000),
 ('2022-05-01 11:35', 23000),
 ('2022-05-01 12:55', 32500),
 ('2022-05-01 12:57', 16000),
 ('2022-05-01 13:42', 17900),
 ('2022-05-01 15:05', 20950),
 ('2022-05-01 15:45', 24700),
 ('2022-05-01 15:49', 18750),
 ('2022-05-01 15:51', 21800)
GO

-- For business hours on May 1, a regular GROUP BY gaives us hourly sales, but doesn't include hours with no sales:
DECLARE @Start datetime = '2022-05-01 09:00'
DECLARE @End   datetime = '2022-05-01 17:00'

;WITH SalesAtHourCte AS (
	SELECT
		Total,
		OrderHour = DATEADD(HOUR, DATEDIFF(HOUR, @Start, OrderDateTime), @Start) 
    FROM
		Sales
    WHERE
		OrderDateTime >= @Start AND OrderDateTime <  @End
)
SELECT
	OrderHour,
	HourlySales = SUM(Total)  
FROM
	SalesAtHourCte
GROUP BY
	OrderHour

GO

-- To include hours with no sales:
DECLARE @Start datetime = '2022-05-01 09:00'
DECLARE @End   datetime = '2022-05-01 17:00'

;WITH SalesAtHourCte AS (
	-- Get the sales at every hour
	SELECT
		Total,
		OrderHour = DATEADD(HOUR, DATEDIFF(HOUR, @Start, OrderDateTime), @Start) 
    FROM
		Sales
    WHERE
		OrderDateTime >= @Start AND OrderDateTime <  @End
),
SalesByHourCte AS (
	-- Group and sum per hour
	SELECT
		OrderHour,
		HourlySales = SUM(Total)  
	FROM
		SalesAtHourCte
	GROUP BY
		OrderHour
),
HoursSeriesCte(OrderHour) AS (
	-- Generate contiguous hour series
    SELECT @Start
    UNION ALL
    SELECT DATEADD(HOUR, 1, OrderHour) FROM HoursSeriesCte WHERE OrderHour < @End
)
SELECT
	hs.OrderHour,
	HourlySales = ISNULL(sbh.HourlySales, 0)
FROM
	HoursSeriesCte AS hs
	LEFT JOIN SalesByHourCte AS sbh ON hs.OrderHour = sbh.OrderHour
WHERE
	hs.OrderHour < @End

GO

-- A better way, using GENERATE_SERIES and DATE_BUCKET()
DECLARE @Start datetime = '2022-05-01 09:00'
DECLARE @End   datetime = '2022-05-01 17:00'

;WITH HoursSeriesCte(OrderHour) AS
(
	SELECT
		DATEADD(HOUR, gs.value, @Start)
	FROM
		GENERATE_SERIES(0, DATEDIFF(HOUR, @Start, @End) - 1) AS gs
)
SELECT
	hs.OrderHour,
	HourlySales = COALESCE(SUM(Total),0)
FROM
	HoursSeriesCte AS hs
	LEFT JOIN Sales AS s ON DATE_BUCKET(HOUR, 1, s.OrderDateTime) = hs.OrderHour
--	LEFT JOIN Sales AS s ON s.OrderDateTime >= hs.OrderHour AND s.OrderDateTime < DATEADD(HOUR, 1, hs.OrderHour)  /* non-DATE_BUCKET alternative */
GROUP BY
	hs.OrderHour

-- Cleanup
DROP TABLE IF EXISTS Sales
