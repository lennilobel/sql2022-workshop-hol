/* =================== DATE_BUCKET =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/functions/date-bucket-transact-sql
-- https://database.guide/about-the-date_bucket-function-in-azure-sql-edge/
-- https://sqlperformance.com/2021/08/t-sql-queries/bucketizing-date-and-time-data

-- DATE_BUCKET eliminates the need to round datetime values, extract date parts, perform wild conversions
-- to and from other types like float, or make elaborate and unintuitive dateadd/datediff calculations

GO
-- One-day buckets make no sense
DECLARE @Origin date = '2022-01-01'
SELECT
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-01'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-02'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-03'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-04'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-05'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-06'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-07'), @Origin),
	'1/1d' = DATE_BUCKET(DAY, 1, CONVERT(date, '2022-01-08'), @Origin)

GO
-- Two-day bucket
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
-- Same, with an origin date one day earlier
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
-- Three-day bucket
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
-- Four-day bucket
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
-- One-week bucket
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
-- One-month bucket
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
-- Three-month bucket
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

-- Simplify week boundary calculations

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

