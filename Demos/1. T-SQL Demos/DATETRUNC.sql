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
