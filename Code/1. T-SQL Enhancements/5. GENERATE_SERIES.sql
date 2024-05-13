-- GENERATE_SERIES Function

USE AdventureWorks2019
GO

-- *** Transition from Recursive CTEs to GENERATE_SERIES

WITH GenerateSeriesCte(value) AS 
(
    SELECT 1 UNION ALL 
    SELECT value + 1 FROM GenerateSeriesCte WHERE value < 1000
)
SELECT value = value FROM GenerateSeriesCte
OPTION (MAXRECURSION 1000)

-- Now we can use the new `GENERATE_SERIES` function to easily generate a simple range of numbers. For example, from 1 to 10:

SELECT value
FROM GENERATE_SERIES(1, 10)

-- Or, create a series with a step value, from 1 to 50, stepping by 5:

SELECT value
FROM GENERATE_SERIES(1, 50, 5)

-- Or, generating a decimal series from 0.0 to 1.0 with a step of 0.1, using parameterized values:

DECLARE @start decimal(2, 1) = 0.0
DECLARE @stop decimal(2, 1) = 1.0
DECLARE @step decimal(2, 1) = 0.1
    
SELECT value
FROM GENERATE_SERIES(@start, @stop, @step)

-- *** Creating a Date Series

DECLARE @StartOn date = '2023-02-05'
DECLARE @EndOn date = '2023-11-15'
    
DECLARE @DayCount int = DATEDIFF(DAY, @StartOn, @EndOn)
    
SELECT
  TheDate = DATEADD(DAY, value, @StartOn)
FROM
  GENERATE_SERIES(0, @DayCount)

GO

-- *** Scenario: Reporting on Sales Data with Unpopulated Intervals

CREATE TABLE Sales
(
    OrderDateTime    datetime,
    Total            decimal(12,2)
)

INSERT Sales
 (OrderDateTime,        Total) VALUES
 ('2022-05-01 09:35',   21000),
 ('2022-05-01 09:47',   30000),
 ('2022-05-01 11:35',   23000),
 ('2022-05-01 12:55',   32500),
 ('2022-05-01 12:57',   16000),
 ('2022-05-01 13:42',   17900),
 ('2022-05-01 15:05',   20950),
 ('2022-05-01 15:45',   24700),
 ('2022-05-01 15:49',   18750),
 ('2022-05-01 15:51',   21800)

-- Notice how this data has shows no sales during the business hours of 10am, 2pm, and 4pm.

-- Using GROUP BY omits hours with no sales

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

-- Using GENERATE_SERIES for comprehensive coverage

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

DROP TABLE Sales
