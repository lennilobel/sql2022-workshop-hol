-- DATE_BUCKET Function

-- SQL Server 2022 introduces the `DATE_BUCKET` function, enhancing the way we can aggregate and analyze data over time. Below, we'll explore how to use this function to create various day-level buckets.

USE AdventureWorks2019

-- *** Two-day Bucket

-- Group data into two-day intervals, starting from a specified "origin" date. This approach helps in analyzing data trends over every two days. Copy and paste the following code into the new query window in SSMS:

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

-- This code demonstrates grouping dates into two-day buckets. The bucket number alternates between '1/2d' and '2/2d', indicating the division of days into two-day periods based on the provided origin date.

GO
-- *** Adjusting the Origin Date

-- Now run the same code with a different origin date. Change the `@Origin` variable assignment as follows, and the re-run the code snippet:

DECLARE @Origin date = '2021-12-31'
SELECT
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-01'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-02'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-03'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-04'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-05'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-06'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-07'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-08'), @Origin)

-- Shifting the origin date backwards by a day changes how dates are allocated into two-day buckets. You can observe this from the output, where the first row now actually represents the second day of a two day bucket that starts on the last day of the previous year. This flexibility allows for tailored data analysis based on the starting point of the bucketing interval.

-- *** Three-day Bucket

-- Extend the bucketing concept to three-day intervals for more extensive data aggregation, as demonstrated by running the following code snippet:

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

-- By grouping dates into three-day intervals, we can observe patterns or trends over slightly longer periods, providing a broader analysis window than two-day buckets. This method could be particularly useful for datasets where changes occur over several days rather than from one day to the next.

-- *** One-week Bucket

-- Now let's group dates into one-week intervals, demonstrating the use of `DATE_BUCKET` for weekly data analysis:

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

-- This example shows how `DATE_BUCKET` can effectively group dates by week, providing a clear way to analyze data on a weekly basis. The output demonstrates the assignment of each day to its respective week number relative to the `@Origin`.

-- *** One-month Bucket

-- Now group dates into one-month intervals using `DATE_BUCKET`, ideal for monthly data aggregation and trend analysis.

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

-- This snippet demonstrates the utility of `DATE_BUCKET` in monthly data grouping. By specifying a month interval, it aligns each date within its respective month bucket (that is, it returns the first date of each month), helpful for monthly reporting or analysis.

-- *** Three-month Bucket

-- Now we'll use `DATE_BUCKET` to group dates into three-month (quarterly) intervals, aiding in quarterly data analysis.

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

-- Let's proceed with additional `DATE_BUCKET` examples, to simplify week boundary calculations and analyze data with quarter-width buckets.

-- *** Simplify Week Boundary Calculations

-- Using `DATE_BUCKET` to find the beginning of the current or previous week, anchored to a known Saturday (for example, 2/24/2024).

SELECT DATE_BUCKET
(
    WEEK,                       -- week-sized buckets
    1,                          -- where each bucket is one week
    CAST(GETDATE() AS date),    -- get the start of today's bucket
    DATEFROMPARTS(2024, 2, 24)  -- where the origin (e.g., 2024-02-24) is any Saturday
)

-- *** Querying with Quarter-width Buckets

-- Now let's leverage `DATE_BUCKET` for more granular analysis within a dataset, particularly focusing on quarterly data aggregation. Here we use `DATE_BUCKET` to segment sales order due dates into quarters, facilitating analysis of sales patterns over quarterly periods:

-- Get the DueDate bucket based on quarter-width buckets
SELECT
    SalesOrderID,
    OrderDate,
    DueDate,
    DueDateQuarterNumber = DATEPART(QUARTER, DueDate),                                          -- The quarter without the year
    DueDateQuarterBucketDate = DATE_BUCKET(QUARTER, 1, DueDate),                                -- The quarter of each year
    DueDateQuarterBucketDayIndex = DATEDIFF(DAY, DATE_BUCKET(QUARTER, 1, DueDate), DueDate),    -- How many days into the quarter
    SalesOrderNumber,
    PurchaseOrderNumber,
    AccountNumber
FROM
    Sales.SalesOrderHeader
ORDER BY
    DueDate
