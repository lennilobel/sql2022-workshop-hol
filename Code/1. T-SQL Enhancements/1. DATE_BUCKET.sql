-- DATE_BUCKET Function

USE AdventureWorks2019

-- *** Two-day Bucket

-- Group data into two-day intervals, starting from a specified "origin" date. This approach helps in analyzing data trends over every two days.

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

-- Now run the same code with a different origin date.

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
GO

-- *** Three-day Bucket

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

-- *** One-week Bucket

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

-- *** One-month Bucket

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

-- *** Three-month Bucket

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
