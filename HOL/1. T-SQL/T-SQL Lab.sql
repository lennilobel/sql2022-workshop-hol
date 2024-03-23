/* Step */
-- DATE_BUCKET

/* =================== DATE_BUCKET =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-bucket-transact-sql
-- https://database.guide/about-the-date_bucket-function-in-azure-sql-edge/
-- https://sqlperformance.com/2021/08/t-sql-queries/bucketizing-date-and-time-data

-- DATE_BUCKET eliminates the need to round datetime values, extract date parts, perform wild conversions
-- to and from other types like float, or make elaborate and unintuitive dateadd/datediff calculations

--HOL: Two-day bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-01'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-02'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-03'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-04'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-05'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-06'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-07'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-08'), @Origin)

GO
--HOL: The same two-day bucket, with an origin date one day earlier
DECLARE @Origin date = '2021-12-31'
SELECT
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-01'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-02'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-03'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-04'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-05'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-06'), @Origin),
	'2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-07'), @Origin),
	'1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-08'), @Origin)

GO
--HOL: Three-day bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-01'), @Origin),
	'2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-02'), @Origin),
	'3/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-03'), @Origin),
	'1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-04'), @Origin),
	'2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-05'), @Origin),
	'3/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-06'), @Origin),
	'1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-07'), @Origin),
	'2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-08'), @Origin)

GO
--HOL: Four-day bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'1/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-01'), @Origin),
	'2/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-02'), @Origin),
	'3/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-03'), @Origin),
	'4/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-04'), @Origin),
	'1/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-05'), @Origin),
	'2/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-06'), @Origin),
	'3/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-07'), @Origin),
	'4/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-08'), @Origin)

GO
--HOL: One-week bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'1/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-01'), @Origin),
	'2/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-02'), @Origin),
	'3/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-03'), @Origin),
	'4/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-04'), @Origin),
	'5/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-05'), @Origin),
	'6/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-06'), @Origin),
	'7/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-07'), @Origin),
	'1/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-08'), @Origin)

GO
--HOL: One-month bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'Jan/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-01-15'), @Origin),
	'Feb/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-02-20'), @Origin),
	'Mar/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-03-13'), @Origin),
	'Apr/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-04-01'), @Origin),
	'May/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-05-23'), @Origin),
	'Jun/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-06-30'), @Origin),
	'Jul/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-07-15'), @Origin),
	'Aug/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-08-30'), @Origin)

GO
--HOL: Three-month bucket
DECLARE @Origin date = '2022-01-01'
SELECT
	'Jan/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-01-15'), @Origin),
	'Feb/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-02-20'), @Origin),
	'Mar/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-03-13'), @Origin),
	'Apr/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-04-01'), @Origin),
	'May/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-05-23'), @Origin),
	'Jun/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-06-30'), @Origin),
	'Jul/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-07-15'), @Origin),
	'Aug/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-08-30'), @Origin)

GO

--HOL: Simplify week boundary calculations

-- BEFORE: Completely unintuitive/cryptic way to get the previous Saturday
DECLARE @Today date = GETDATE()
DECLARE @PreviousSaturday date = DATEADD(DAY, - (DATEPART(WEEKDAY, @Today) + @@DATEFIRST) % 7, @Today)
SELECT @PreviousSaturday
GO

-- AFTER: Much simpler with DATE_BUCKET, using any known Saturday date as the origin
SELECT DATE_BUCKET
(
	WEEK,						-- week-sized buckets
	1,							-- where each bucket is one week
	CAST(GETDATE() AS date),	-- get the start of today's bucket
	DATEFROMPARTS(2024, 2, 24)	-- where the origin (e.g., 2024-02-24) is any Saturday
)	
GO

--HOL: Query the SalesOrderHeader table, and get the DueDate bucket based on quarter-width buckets
USE AdventureWorks2019
GO

-- Get the DueDate bucket based on quarter-width buckets
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	DueDateQuarterNumber = DATEPART(QUARTER, DueDate),											-- The quarter without the year
	DueDateQuarterBucketDate = DATE_BUCKET(QUARTER, 1, DueDate),								-- The quarter of each year
	DueDateQuarterBucketDayIndex = DATEDIFF(DAY, DATE_BUCKET(QUARTER, 1, DueDate), DueDate),	-- How many days into the quarter
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber
FROM
	Sales.SalesOrderHeader
ORDER BY
	DueDate

/* Step */
-- DATETRUNC

/* =================== DATETRUNC =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/datetrunc-transact-sql?view=sql-server-ver16
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/set-datefirst-transact-sql?view=sql-server-ver16
-- https://database.guide/return-the-iso-week-number-from-a-date-in-sql-server-t-sql/
-- https://www.quora.com/What-is-the-SQL-Server-equivalent-of-DATE_TRUNC

DECLARE @d date = '2023-05-17'
SELECT
	@d						AS FullDate,
	DATETRUNC(QUARTER, @d)	AS TruncateToQuarter,
	DATETRUNC(YEAR, @d)		AS TruncateToYear
GO

DECLARE @dt datetime2 = '2023-05-17 02:04:23.1234567'
SELECT
	@dt						AS FullDateTime,
	DATETRUNC(HOUR, @dt)	AS TruncateToHour,
	DATETRUNC(DAY, @dt)		AS TruncateToDay
GO

DECLARE @dt datetime2 = '2023-05-17 11:30:15.1234567'					-- Wednesday
SELECT 'FullDateTime',			@dt							UNION ALL
SELECT 'TruncateToMicrosecond',	DATETRUNC(MICROSECOND, @dt)	UNION ALL
SELECT 'TruncateToMillisecond',	DATETRUNC(MILLISECOND, @dt)	UNION ALL
SELECT 'TruncateToSecond',		DATETRUNC(SECOND, @dt)		UNION ALL
SELECT 'TruncateToMinute',		DATETRUNC(MINUTE, @dt)		UNION ALL
SELECT 'TruncateToHour',		DATETRUNC(HOUR, @dt)		UNION ALL
SELECT 'TruncateToDay',			DATETRUNC(DAY, @dt)			UNION ALL	-- \_ DAY is equivalent
SELECT 'TruncateToDayOfYear',	DATETRUNC(DAYOFYEAR, @dt)	UNION ALL	-- /  to DAYOFYEAR
SELECT 'TruncateToIsoWeek',		DATETRUNC(ISO_WEEK, @dt)	UNION ALL	-- Mon; where ISO weeks start on Monday
SELECT 'TruncateToWeek',		DATETRUNC(WEEK, @dt)		UNION ALL	-- Sun; using the default DATEFIRST setting value of 7 (U.S. English)
SELECT 'TruncateToMonth',		DATETRUNC(MONTH, @dt)		UNION ALL
SELECT 'TruncateToQuarter',		DATETRUNC(QUARTER, @dt)		UNION ALL
SELECT 'TruncateToYear',		DATETRUNC(YEAR, @dt)
GO


-- Use SET DATEFIRST to set the first day of the week, from 1-6 (Mon-Sat) or 7 (Sun, the default)

--
--     Sun    Mon    Tue    Wed    Thu    Fri    Sat
--     5/14   5/15   5/16   5/17   5/18   5/19   5/20

DECLARE @dt datetime2 = '2023-05-17 11:30:15.1234567'

SELECT 'FullDateTime',			@dt						-- Wed

SET DATEFIRST 7											-- week starts on Sun (default)
SELECT 'WeekStartingSunday',	DATETRUNC(WEEK, @dt)	-- 3 days earlier

SET DATEFIRST 6											-- week starts on Sat
SELECT 'WeekStartingSaturday',	DATETRUNC(WEEK, @dt)	-- 4 days earlier

SET DATEFIRST 3											-- week starts on Wed
SELECT 'WeekStartingWednesday',	DATETRUNC(WEEK, @dt)	-- same day

SET DATEFIRST 7											-- restore the default

USE AdventureWorks2019
GO

-- Note that DATETRUNC is equivalent to DATE_BUCKET with a bucket size of one and an origin of 1/1/1900
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	DueDateQuarterNumber = DATEPART(QUARTER, DueDate),
	DueDateQuarterDate = DATETRUNC(QUARTER, DueDate),
	DueDateQuarterDayIndex = DATEDIFF(DAY, DATETRUNC(QUARTER, DueDate), DueDate),
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber
FROM
	Sales.SalesOrderHeader
ORDER BY
	DueDate

/* Step */
-- LEAST and GREATEST

/* =================== LEAST and GREATEST =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/logical-functions-greatest-transact-sql
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/logical-functions-least-transact-sql

DECLARE @NumericValue1 varchar(max) = '6.62'
DECLARE @NumericValue2 decimal(18, 4) = 3.1415
DECLARE @NumericValue3 varchar(max) = '7'

DECLARE @StringValue1 varchar(max) = 'Glacier'
DECLARE @StringValue2 varchar(max) = 'Mount Ranier'
DECLARE @StringValue3 varchar(max) = 'Joshua Tree'

-- Like MIN and MAX, but across columns within a single row
SELECT
	LeastNumeric	= LEAST(@NumericValue1, @NumericValue2, @NumericValue3),
	LeastString		= LEAST(@StringValue1, @StringValue2, @StringValue3),
	GreatestNumeric	= GREATEST(@NumericValue1, @NumericValue2, @NumericValue3),
	GreatestString	= GREATEST(@StringValue1, @StringValue2, @StringValue3)

-- Equivalent, before LEAST and GREATEST
SELECT
	LeastNumeric	= CASE
						WHEN @NumericValue1 < @NumericValue2	AND @NumericValue1 < @NumericValue3	THEN @NumericValue1
						WHEN @NumericValue2 < @NumericValue1	AND @NumericValue2 < @NumericValue3	THEN @NumericValue2
						WHEN @NumericValue3 < @NumericValue1	AND @NumericValue3 < @NumericValue2	THEN @NumericValue3
						END,
	LeastString		= CASE
						WHEN @StringValue1 < @StringValue2		AND @StringValue1 < @StringValue3	THEN @StringValue1
						WHEN @StringValue2 < @StringValue1		AND @StringValue2 < @StringValue3	THEN @StringValue2
						WHEN @StringValue3 < @StringValue1		AND @StringValue3 < @StringValue2	THEN @StringValue3
						END,
	GreatestNumeric	= CASE
						WHEN @NumericValue1 > @NumericValue2	AND @NumericValue1 > @NumericValue3	THEN @NumericValue1
						WHEN @NumericValue2 > @NumericValue1	AND @NumericValue2 > @NumericValue3	THEN @NumericValue2
						WHEN @NumericValue3 > @NumericValue1	AND @NumericValue3 > @NumericValue2	THEN @NumericValue3
						END,
	GreatestString	= CASE
						WHEN @StringValue1 > @StringValue2		AND @StringValue1 > @StringValue3	THEN @StringValue1
						WHEN @StringValue2 > @StringValue1		AND @StringValue2 > @StringValue3	THEN @StringValue2
						WHEN @StringValue3 > @StringValue1		AND @StringValue3 > @StringValue2	THEN @StringValue3
						END
GO

USE MyDB
GO

DROP TABLE IF EXISTS Company
GO

-- Using LEAST and GREATEST to find the earliest and latest update date, across three different applications
CREATE TABLE Company
(
	CompanyId			int IDENTITY PRIMARY KEY,
	CompanyName			varchar(40),
	UpdateByApp1Date	date,
	UpdateByApp2Date	date,
	UpdateByApp3Date	date
)

INSERT INTO Company(CompanyName, UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date) VALUES
 ('ABC',   '2022-08-05', '2023-08-04', '2021-08-06'),
 ('Acme',  '2023-07-05', '2021-12-09', '2022-08-14'),
 ('Wonka', '2021-03-05', '2022-01-14', '2023-07-26')

SELECT
	CompanyId,
	CompanyName,
	FirstUpdateDate = LEAST(UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date),
	LastUpdateDate = GREATEST(UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date)
FROM
	Company

/* Step */
-- STRING_SPLIT ordinal

/* =================== STRING_SPLIT Ordinal =================== */

-- STRING_SPLIT (SQL 2016+)
SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/')

-- SQL 2022 supports "enable ordinal" bit parameter to report each item's ordinal position
SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/', 1)

-----------------------------------------------------------------------------------------------------------------------
-- Deduping items using MIN and GROUP BY changes their order
SELECT
	value,
	ordinal
FROM
	STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)

-- The new ordinal is useful for deduping delimited items while preserving their order
SELECT
	value,
	ordinal = MIN(ordinal)
FROM 
	STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)
GROUP BY
	value
ORDER BY
	ordinal

-- Combined with STRING_AGG, we can rebuild the delimited string with dupes eliminated and order preserved
;WITH SplitCte AS (
	SELECT
		value,
		ordinal = MIN(ordinal)
	FROM
		STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)
	GROUP BY
		value
)
SELECT
	Deduped = STRING_AGG(value, '/') WITHIN GROUP (ORDER BY ordinal)
FROM
	SplitCte

-----------------------------------------------------------------------------------------------------------------------
-- Useful if the ordinal is needed when bulk processing rows against IDs supplied as CSV
USE AdventureWorks2019
GO

-- Here are three person rows with IDs 6, 12, and 18
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE BusinessEntityID IN (6, 12, 18)

-- Bulk process the three rows by passing in a CSV string
DECLARE @BusinessEntityIDs varchar(max) = '6,12,18'

-- Process the rows, return an enriched resultset in a different order
;WITH BusinessEntityIDsCte AS (
	SELECT
		CONVERT(int, value) AS BusinessEntityID,
		ordinal
	FROM
		STRING_SPLIT(@BusinessEntityIDs, ',', 1)
)
SELECT
	ids.Ordinal,	-- Returning the ordinal allows the caller to correlate the out-of-sequence results with the original input sequence
	p.FirstName,
	p.LastName,
	e.JobTitle
FROM
	Person.Person AS p
	INNER JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
	INNER JOIN BusinessEntityIDsCte AS ids ON ids.BusinessEntityID = p.BusinessEntityID
ORDER BY
	LastName

/* Step */
-- GENERATE_SERIES

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

-- To include hours with no sales, using GENERATE_SERIES and DATE_BUCKET()
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
GROUP BY
	hs.OrderHour

-- Cleanup
DROP TABLE IF EXISTS Sales

/* Step */
-- TRIM with BOTH, LEADING, and TRAILING

/* =================== LTRIM/RTRIM =================== */

SELECT '|' +	LTRIM('     #  data  .  ')			+ '|'	-- pre-2022
SELECT '|' +	LTRIM('     #  data  .  ', '#., ')	+ '|'	-- 2022 added 'characters' argument (same as TRIM with LEADING keyword)

SELECT '|' +	RTRIM('     #  data  .  ')			+ '|'	-- pre-2022
SELECT '|' +	RTRIM('     #  data  .  ', '#., ')	+ '|'	-- 2022 added 'characters' argument (same as TRIM with TRAILING keyword)

/* =================== TRIM =================== */

SELECT '|' +	TRIM('     data   ')				+ '|'	-- pre 2017
SELECT '|' +	TRIM(' ' FROM '     data   ')		+ '|'	-- 2017 added 'characters FROM' clause

SELECT '|' +	TRIM('<>'  FROM '<<< data >>>')		+ '|'		
SELECT '|' +	TRIM('<> ' FROM '<<< data >>>')		+ '|'	

-- 2022

SELECT '|' +	TRIM(			'#., '	FROM '     #  data  . ')	+ '|'	-- 2017+
SELECT '|' +	TRIM(BOTH		'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added BOTH keyword (same as TRIM)
SELECT '|' +	TRIM(LEADING	'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added LEADING keyword (same as LTRIM with 'characters' argument)
SELECT '|' +	TRIM(TRAILING	'#., '	FROM '     #  data  . ')	+ '|'	-- 2022 added TRAILING keyword (same as RTRIM with 'characters' argument)

/* Step */
-- IS DISTINCT FROM

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

/* Step */
-- Windowing enhancements with the WINDOW clause

/* =================== Windowing =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-window-transact-sql

CREATE DATABASE MyDB
GO

USE MyDB
GO

DROP TABLE IF EXISTS TxnData

CREATE TABLE TxnData (AcctId int, TxnDate date, Amount decimal)

INSERT INTO TxnData (AcctId, TxnDate, Amount) VALUES
  (1, DATEFROMPARTS(2011, 8, 10), 500),  -- 5 transactions for acct 1
  (1, DATEFROMPARTS(2011, 8, 22), 250),
  (1, DATEFROMPARTS(2011, 8, 24), 75),
  (1, DATEFROMPARTS(2011, 8, 26), 125),
  (1, DATEFROMPARTS(2011, 8, 28), 175),
  (2, DATEFROMPARTS(2011, 8, 11), 500),  -- 8 transactions for acct 2
  (2, DATEFROMPARTS(2011, 8, 15), 50),
  (2, DATEFROMPARTS(2011, 8, 22), 5000),
  (2, DATEFROMPARTS(2011, 8, 25), 550),
  (2, DATEFROMPARTS(2011, 8, 27), 105),
  (2, DATEFROMPARTS(2011, 8, 27), 95),
  (2, DATEFROMPARTS(2011, 8, 29), 100),
  (2, DATEFROMPARTS(2011, 8, 30), 2500),
  (3, DATEFROMPARTS(2011, 8, 14), 500),  -- 4 transactions for acct 3
  (3, DATEFROMPARTS(2011, 8, 15), 600),
  (3, DATEFROMPARTS(2011, 8, 22), 25),
  (3, DATEFROMPARTS(2011, 8, 23), 125)

-- OVER with ORDER BY for aggregate functions (SQL 2012+) enables running/sliding aggregations

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  SAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 FROM TxnData
 ORDER BY AcctId, TxnDate
GO

-- SQL 2022 lets you define reusable named windows

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER win,
  RCnt = COUNT(*)    OVER win,
  RMin = MIN(Amount) OVER win,
  RMax = MAX(Amount) OVER win,
  RSum = SUM(Amount) OVER win,
  SAvg = AVG(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 FROM
	TxnData
 WINDOW
	win AS (PARTITION BY AcctId ORDER BY TxnDate)
 ORDER BY
	AcctId, TxnDate

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER winRunning,
  RCnt = COUNT(*)    OVER winRunning,
  RMin = MIN(Amount) OVER winRunning,
  RMax = MAX(Amount) OVER winRunning,
  RSum = SUM(Amount) OVER winRunning,
  SAvg = AVG(Amount) OVER winSliding,
  SCnt = COUNT(*)    OVER winSliding,
  SMin = MIN(Amount) OVER winSliding,
  SMax = MAX(Amount) OVER winSliding,
  SSum = SUM(Amount) OVER winSliding
 FROM
	TxnData
 WINDOW
	winRunning AS (PARTITION BY AcctId ORDER BY TxnDate),
	winSliding AS (winRunning ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 ORDER BY
	AcctId, TxnDate
GO

-- SQL 2022 enhances FIRST_VALUE and LAST_VALUE with IGNORE NULLS and RESPECT NULLS (default)

CREATE TABLE [Order](OrderDate date, ProductID int, Quantity int)
INSERT INTO [Order] VALUES
 ('2011-03-18', 142, 74),
 ('2011-04-11', 123, 95),
 ('2011-04-12', 101, 38),
 ('2011-05-30', 101, 28),
 ('2011-05-21', 130, 12),
 ('2011-07-25', 123, 57),
 ('2011-07-28', 101, 12)

SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) OVER win,
  HighestOn = LAST_VALUE(OrderDate)  OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY OrderDate		-- switch to ProductID to sort results the same as the internal window order

-- But it's a problem if you have NULLs:
DELETE FROM [Order]
INSERT INTO [Order] VALUES
 ('2011-03-18', 142, 74),
 (NULL,			123, 95),	-- HighestOn (95) for ProductID 123 is NULL
 ('2011-04-12', 101, 38),
 ('2011-05-30', 101, 28),
 ('2011-05-21', 130, 12),
 ('2011-07-25', 123, 57),
 (NULL,			101, 12)	-- LowestOn (12) for ProductID 101 is NULL

-- Default is RESPECT NULLS, which gives us NULL order dates for ProductID 101 LowestOn, and for ProductID 123 HighestOn
SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) OVER win,
  HighestOn = LAST_VALUE(OrderDate)  OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY OrderDate		-- switch to ProductID to sort results the same as the internal window order

-- With IGNORE NULLS, we get meaningful (non-NULL) order dates for each product
SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) IGNORE NULLS OVER win,
  HighestOn = LAST_VALUE(OrderDate)  IGNORE NULLS OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY ProductID --OrderDate		-- switch to ProductID to sort results the same as the internal window order

GO

-- Cleanup
DROP TABLE IF EXISTS TxnData
DROP TABLE IF EXISTS [Order]
DROP TABLE IF EXISTS Sales
GO

/* Step */
-- Bit manipulation

/* =================== Bit functions =================== */

-- Color flags:
--			Pos	Dec		Hex		Binary
--	Red		0	  1		  1		00000001
--	Green	1	  2		  2		00000010
--	Blue	2	  4		  4		00000100
--	Yellow	3	  8		  8		00001000
--	Cyan	4	 16		 10		00010000
--	Purple	5	 32		 20		00100000
--	Brown	6	 64		 40		01000000
--	Black	7	128		 80		10000000

-- How many colors (set bits) are in the value?
DECLARE @Colors tinyint				-- A tinyint is an 8-bit unsigned byte

SET @Colors = 0x09					-- 00001001 (red and yellow)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Add in brown and black with a bitwise OR
SET @Colors = @Colors | 0xC0		--    00001001 (red and yellow)
									--  | 11000000 (brown and black)
									--  = 11001001 (red, yellow, brown, and black)
SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Remove yellow, blue, green, and red with a bitwise AND
SET @Colors = @Colors & 0xF0		--    11001001 (red, yellow, brown, and black)
									--	& 11110000 (yellow, blue, green, and red)
									--  = 11000000 (brown and black)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Flip color selections with a bitwise NOT
SET @Colors = ~ @Colors				--    11000000 (brown and black)
									--	~ 
									--  = 00111111 (red, green, blue, yellow, cyan, and purple)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red


SELECT
	@Colors & 0x10 AS IsCyan	-- 00010000

-- Shift bits using LEFT_SHIFT (<<) and RIGHT_SHIFT (>>) to pack and unpack bits within a byte
DECLARE @MinMax tinyint
DECLARE @Min tinyint = 14		-- 1110		0x0E
DECLARE @Max tinyint = 9		-- 1001		0x09

-- Pack @Min and @Max (two 4-bit values in range 0-15) into @MinMax (a single 8-bit value in range 0-255)
SELECT @MinMax = LEFT_SHIFT(@Min, 4) + @Max		-- Shift @Min by four bits, then add @Max
SELECT @MinMax = (@Min << 4 ) + @Max			-- Use << as shorthand for LEFT_SHIFT
SELECT
	Min			= @Min,
	Max			= @Max,
	MinMax		= @MinMax,
	MinHex		= CONVERT(binary(1), @Min),
	MaxHex		= CONVERT(binary(1), @Max),
	MinMaxHex	= CONVERT(binary(1), @MinMax)

-- Unpack @Min from the upper four bits
SELECT @Min = RIGHT_SHIFT(@MinMax, 4)
SELECT @Min = @MinMax >> 4
SELECT
	Min			= @Min,
	MinHex		= CONVERT(binary(1), @Min)

-- Unpack @Max from the lower four bits using a bitwise AND to clear the upper four bits
SELECT @Max = @MinMax & 0x0F
SELECT
	Max			= @Max,
	MaxHex		= CONVERT(binary(1), @Max)

-- You can also individually clear the upper four bits using SET_BIT
SELECT @Max = @MinMax
SELECT @Max = SET_BIT(@Max, 4, 0)
SELECT @Max = SET_BIT(@Max, 5, 0)
SELECT @Max = SET_BIT(@Max, 6, 0)
SELECT @Max = SET_BIT(@Max, 7, 0)
SELECT
	Max			= @Max,
	MaxHex		= CONVERT(binary(1), @Max)


-- Bit manipulation on table data

USE MyDB
GO

DROP TABLE IF EXISTS Customer

CREATE TABLE Customer (
	CustomerId int IDENTITY PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	ColorSelections tinyint NOT NULL,		-- Pack eight single-bit values (0 or 1) in a single byte (0-255)
	MinMax tinyint NOT NULL					-- Pack two four-bit values (0-15) in a single byte (0-255)
)

INSERT INTO Customer
 (FirstName,	LastName,		ColorSelections,	MinMax) VALUES
 ('Ken',		'Sanchez',		0,					0),
 ('Terri',		'Duffy',		18,					18),
 ('Roberto',	'Tamburello',	96,					96),
 ('Rob',		'Walters',		158,				158),
 ('Gail',		'Erickson',		255,				255)

SELECT
	FirstName,
	ColorSelections,
	CONVERT(binary(1), ColorSelections) AS ColorSelectionsHex,
	BIT_COUNT(ColorSelections) AS ColorCount,
	GET_BIT(ColorSelections, 7) AS Black,
	GET_BIT(ColorSelections, 6) AS Brown,
	GET_BIT(ColorSelections, 5) AS Purple,
	GET_BIT(ColorSelections, 4) AS Cyan,
	GET_BIT(ColorSelections, 3) AS Yellow,
	GET_BIT(ColorSelections, 2) AS Blue,
	GET_BIT(ColorSelections, 1) AS Green,
	GET_BIT(ColorSelections, 0) AS Red,
	MinMax,
	CONVERT(binary(1), MinMax) AS MinMaxHex,
	RIGHT_SHIFT(MinMax, 4) AS Min,
	MinMax & 0x0F AS Max
FROM
	Customer

-- Cleanup
DROP TABLE IF EXISTS Customer

/* Windowing enhancements */

/* =================== Windowing =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-window-transact-sql

CREATE DATABASE MyDB
GO

USE MyDB
GO

DROP TABLE IF EXISTS TxnData

CREATE TABLE TxnData (AcctId int, TxnDate date, Amount decimal)

INSERT INTO TxnData (AcctId, TxnDate, Amount) VALUES
  (1, DATEFROMPARTS(2011, 8, 10), 500),  -- 5 transactions for acct 1
  (1, DATEFROMPARTS(2011, 8, 22), 250),
  (1, DATEFROMPARTS(2011, 8, 24), 75),
  (1, DATEFROMPARTS(2011, 8, 26), 125),
  (1, DATEFROMPARTS(2011, 8, 28), 175),
  (2, DATEFROMPARTS(2011, 8, 11), 500),  -- 8 transactions for acct 2
  (2, DATEFROMPARTS(2011, 8, 15), 50),
  (2, DATEFROMPARTS(2011, 8, 22), 5000),
  (2, DATEFROMPARTS(2011, 8, 25), 550),
  (2, DATEFROMPARTS(2011, 8, 27), 105),
  (2, DATEFROMPARTS(2011, 8, 27), 95),
  (2, DATEFROMPARTS(2011, 8, 29), 100),
  (2, DATEFROMPARTS(2011, 8, 30), 2500),
  (3, DATEFROMPARTS(2011, 8, 14), 500),  -- 4 transactions for acct 3
  (3, DATEFROMPARTS(2011, 8, 15), 600),
  (3, DATEFROMPARTS(2011, 8, 22), 25),
  (3, DATEFROMPARTS(2011, 8, 23), 125)

-- OVER with ORDER BY for aggregate functions (SQL 2012+) enables running/sliding aggregations

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  SAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 FROM TxnData
 ORDER BY AcctId, TxnDate
GO

-- SQL 2022 lets you define reusable named windows

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER win,
  RCnt = COUNT(*)    OVER win,
  RMin = MIN(Amount) OVER win,
  RMax = MAX(Amount) OVER win,
  RSum = SUM(Amount) OVER win,
  SAvg = AVG(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 FROM
	TxnData
 WINDOW
	win AS (PARTITION BY AcctId ORDER BY TxnDate)
 ORDER BY
	AcctId, TxnDate

SELECT AcctId, TxnDate, Amount,
  RAvg = AVG(Amount) OVER winRunning,
  RCnt = COUNT(*)    OVER winRunning,
  RMin = MIN(Amount) OVER winRunning,
  RMax = MAX(Amount) OVER winRunning,
  RSum = SUM(Amount) OVER winRunning,
  SAvg = AVG(Amount) OVER winSliding,
  SCnt = COUNT(*)    OVER winSliding,
  SMin = MIN(Amount) OVER winSliding,
  SMax = MAX(Amount) OVER winSliding,
  SSum = SUM(Amount) OVER winSliding
 FROM
	TxnData
 WINDOW
	winRunning AS (PARTITION BY AcctId ORDER BY TxnDate),
	winSliding AS (winRunning ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
 ORDER BY
	AcctId, TxnDate
GO

-- SQL 2022 enhances FIRST_VALUE and LAST_VALUE with IGNORE NULLS and RESPECT NULLS (default)

CREATE TABLE [Order](OrderDate date, ProductID int, Quantity int)
INSERT INTO [Order] VALUES
 ('2011-03-18', 142, 74),
 ('2011-04-11', 123, 95),
 ('2011-04-12', 101, 38),
 ('2011-05-30', 101, 28),
 ('2011-05-21', 130, 12),
 ('2011-07-25', 123, 57),
 ('2011-07-28', 101, 12)

SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) OVER win,
  HighestOn = LAST_VALUE(OrderDate)  OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY OrderDate		-- switch to ProductID to sort results the same as the internal window order

-- But it's a problem if you have NULLs:
DELETE FROM [Order]
INSERT INTO [Order] VALUES
 ('2011-03-18', 142, 74),
 (NULL,			123, 95),	-- HighestOn (95) for ProductID 123 is NULL
 ('2011-04-12', 101, 38),
 ('2011-05-30', 101, 28),
 ('2011-05-21', 130, 12),
 ('2011-07-25', 123, 57),
 (NULL,			101, 12)	-- LowestOn (12) for ProductID 101 is NULL

-- Default is RESPECT NULLS, which gives us NULL order dates for ProductID 101 LowestOn, and for ProductID 123 HighestOn
SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) OVER win,
  HighestOn = LAST_VALUE(OrderDate)  OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY OrderDate		-- switch to ProductID to sort results the same as the internal window order

-- With IGNORE NULLS, we get meaningful (non-NULL) order dates for each product
SELECT
  OrderDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(OrderDate) IGNORE NULLS OVER win,
  HighestOn = LAST_VALUE(OrderDate)  IGNORE NULLS OVER win
 FROM [Order]
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY ProductID --OrderDate		-- switch to ProductID to sort results the same as the internal window order

GO

-- Cleanup
DROP TABLE IF EXISTS TxnData
DROP TABLE IF EXISTS [Order]
DROP TABLE IF EXISTS Sales
GO

/* Step */

