-- DATETRUNC Function

USE AdventureWorks2019

-- *** Truncating Date Values to Quarter and Year

DECLARE @d date = '2023-05-17'
SELECT
    @d AS FullDate,
    DATETRUNC(QUARTER, @d) AS TruncateToQuarter,
    DATETRUNC(YEAR, @d) AS TruncateToYear

-- *** Truncating DateTime Values to Hour and Day

DECLARE @dt datetime2 = '2023-05-17T02:04:23.1234567'
SELECT
    @dt AS FullDateTime,
    DATETRUNC(HOUR, @dt) AS TruncateToHour,
    DATETRUNC(DAY, @dt) AS TruncateToDay

-- *** Comprehensive DateTime Truncation

DECLARE @dt datetime2 = '2023-05-17T11:30:15.1234567' -- Wednesday
SELECT 'FullDateTime',          @dt                          UNION ALL
SELECT 'TruncateToMicrosecond', DATETRUNC(MICROSECOND, @dt)  UNION ALL
SELECT 'TruncateToMillisecond', DATETRUNC(MILLISECOND, @dt)  UNION ALL
SELECT 'TruncateToSecond',      DATETRUNC(SECOND, @dt)       UNION ALL
SELECT 'TruncateToMinute',      DATETRUNC(MINUTE, @dt)       UNION ALL
SELECT 'TruncateToHour',        DATETRUNC(HOUR, @dt)         UNION ALL
SELECT 'TruncateToDay',         DATETRUNC(DAY, @dt)          UNION ALL
SELECT 'TruncateToDayOfYear',   DATETRUNC(DAYOFYEAR, @dt)    UNION ALL
SELECT 'TruncateToIsoWeek',     DATETRUNC(ISO_WEEK, @dt)     UNION ALL	-- Week starts on Monday
SELECT 'TruncateToWeek',        DATETRUNC(WEEK, @dt)         UNION ALL	-- Week starts on Sunday by default; can override with SET DATEFIRST
SELECT 'TruncateToMonth',       DATETRUNC(MONTH, @dt)        UNION ALL
SELECT 'TruncateToQuarter',     DATETRUNC(QUARTER, @dt)      UNION ALL
SELECT 'TruncateToYear',        DATETRUNC(YEAR, @dt)

-- Also note that, in the context of weeks, the function provides two options: `ISO_WEEK` and `WEEK`. Here's the distinction between them:

-- - **TruncateToIsoWeek**: Using the `ISO_WEEK` parameter with `DATETRUNC` truncates the datetime to the start of the ISO week, which is always Monday.

-- - **TruncateToWeek**: The `WEEK` parameter, on the other hand, truncates the datetime to the start of the week based on the SQL Server's default setting, which is usually Sunday in the United States. However, this starting day of the week can be altered using the `SET DATEFIRST` statement.

-- This distinction is important for accurately performing weekly data analysis and ensuring that the week boundaries align with the intended standard or operational definition of a week. In this case, our `@dt` parameter is set to 5/17/2023, which is a Wednesday. Thus, `ISO_WEEK` returns 5/15 (the prior Monday), while `WEEK` returns 5/14 (the prior Sunday).
