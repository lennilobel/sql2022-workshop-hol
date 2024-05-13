# Windowing Enhancements

-- Now let's explore two windowing enhancements introduced in SQL Server 2022: the `WINDOW` clause, and the `IGNORE NULLS` syntax added to the `FIRST_VALUE` and `LAST_VALUE` window functions.

USE AdventureWorks2019

-- *** The WINDOW Clause

-- Let's start with the new `WINDOW` clause. First, we'll populate some sample data. The following code creates a table named `TxnData` and populates it with transaction data for three different accounts. This dataset will be useful for exploring the use of window functions and their enhancements in SQL Server 2022.

CREATE TABLE TxnData (
  AcctId int,
  TxnDate date,
  Amount decimal
)

INSERT INTO TxnData (AcctId, TxnDate, Amount) VALUES
  (1, DATEFROMPARTS(2021, 8, 10), 500),  -- 5 transactions for account 1
  (1, DATEFROMPARTS(2021, 8, 22), 250),
  (1, DATEFROMPARTS(2021, 8, 24), 75),
  (1, DATEFROMPARTS(2021, 8, 26), 125),
  (1, DATEFROMPARTS(2021, 8, 28), 175),
  (2, DATEFROMPARTS(2021, 8, 11), 500),  -- 8 transactions for account 2
  (2, DATEFROMPARTS(2021, 8, 15), 50),
  (2, DATEFROMPARTS(2021, 8, 22), 5000),
  (2, DATEFROMPARTS(2021, 8, 25), 550),
  (2, DATEFROMPARTS(2021, 8, 27), 105),
  (2, DATEFROMPARTS(2021, 8, 27), 95),
  (2, DATEFROMPARTS(2021, 8, 29), 100),
  (2, DATEFROMPARTS(2021, 8, 30), 2500),
  (3, DATEFROMPARTS(2021, 8, 14), 500),  -- 4 transactions for account 3
  (3, DATEFROMPARTS(2021, 8, 15), 600),
  (3, DATEFROMPARTS(2021, 8, 22), 25),
  (3, DATEFROMPARTS(2021, 8, 23), 125)

-- ***# Purpose of the Script:

-- - **Educational Foundation**: This script serves as a foundation for practicing and understanding windowing functions.
-- - **Window Functions Analysis**: By analyzing transactions across different accounts and dates, you can learn how window functions operate over a set of rows, providing insights into running totals, moving averages, and other analytical operations.
-- - **Exploring SQL Server 2022 Enhancements**: The dataset is specifically designed to explore the new `WINDOW` clause for more readable and maintainable SQL queries.

-- ***# Exploring Running and Sliding Aggregations in SQL Server with Note on Code Duplication

-- The following SQL query leverages window functions for conducting running and sliding aggregations on our dataset of transactions across different accounts. These operations are made possible by the `OVER` clause paired with `PARTITION BY` and `ORDER BY` subclauses, facilitating the calculation of averages, counts, minimums, maximums, and sums, relative to the rows in the specified window.

-- OVER with ORDER BY for aggregate functions (SQL 2012+) enables running/sliding aggregations
SELECT AcctId, TxnDate, Amount,
  -- Running aggregations at the account level, all account rows per window
  RAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  RSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate),
  -- Sliding aggregations at the account level, max three account rows per window
  SAvg = AVG(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (PARTITION BY AcctId ORDER BY TxnDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM TxnData
ORDER BY AcctId, TxnDate

-- *** Note on Code Duplication

-- A notable aspect of this query is the duplication within the `OVER` clauses across multiple lines. Each aggregation function (`AVG`, `COUNT`, `MIN`, `MAX`, `SUM`) repeats the same `OVER` clause setup, specifying `PARTITION BY` and `ORDER BY` for both running and sliding aggregations. This redundancy can lead to longer, less maintainable SQL scripts, particularly as the complexity of the queries and windowing logic increases.

-- SQL Server 2022 addresses this concern by introducing the `WINDOW` clause, allowing for the definition of reusable named window frames. This enhancement significantly reduces code duplication and improves both readability and maintainability by enabling the specification of common windowing elements (like partitioning and ordering criteria) in a single, centralized location within the query.

-- ***# Leveraging SQL Server 2022 WINDOW Clause for Enhanced Readability

-- SQL Server 2022 introduces the `WINDOW` clause, a feature for defining reusable window frames in windowing functions. This enhancement facilitates a cleaner and more maintainable approach for running and sliding aggregations, as demonstrated in the following examples.

-- ***-- *** Query Using the WINDOW Clause

-- This query is functionally equivalent to the previous one, but uses the new `WINDOW` clause to reduce code duplication for the running and sliding aggregations.

SELECT AcctId, TxnDate, Amount,
  -- Running aggregations at the account level, all account rows per window
  RAvg = AVG(Amount) OVER win,
  RCnt = COUNT(*)    OVER win,
  RMin = MIN(Amount) OVER win,
  RMax = MAX(Amount) OVER win,
  RSum = SUM(Amount) OVER win,
  -- Sliding aggregations at the account level, max three account rows per window
  SAvg = AVG(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SCnt = COUNT(*)    OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMin = MIN(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SMax = MAX(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
  SSum = SUM(Amount) OVER (win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM TxnData
WINDOW
  win AS (PARTITION BY AcctId ORDER BY TxnDate)
ORDER BY AcctId, TxnDate

-- In this query, a single `WINDOW` clause named `win` is defined to partition data by `AcctId` and order it by `TxnDate`, applicable to both running (R) and sliding (S) aggregations. This already reduces the repetition seen in the pre-2022 version. However, for sliding aggregations, the clause `(win ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` is still repeated.

-- ***-- *** Using Two Named Windows

-- This next query uses the `WINDOW` clause to define to named windows and eliminate all the duplication in both the running and sliding aggregation columns:

SELECT AcctId, TxnDate, Amount,
  -- Running aggregations at the account level, all account rows per window
  RAvg = AVG(Amount) OVER winRunning,
  RCnt = COUNT(*)    OVER winRunning,
  RMin = MIN(Amount) OVER winRunning,
  RMax = MAX(Amount) OVER winRunning,
  RSum = SUM(Amount) OVER winRunning,
  -- Sliding aggregations at the account level, max three account rows per window
  SAvg = AVG(Amount) OVER winSliding,
  SCnt = COUNT(*)    OVER winSliding,
  SMin = MIN(Amount) OVER winSliding,
  SMax = MAX(Amount) OVER winSliding,
  SSum = SUM(Amount) OVER winSliding
FROM TxnData
WINDOW
  winRunning AS (PARTITION BY AcctId ORDER BY TxnDate),
  winSliding AS (winRunning ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
ORDER BY AcctId, TxnDate

-- This version further improves the query's readability and maintainability by defining two named `WINDOW` clauses: `winRunning` for running aggregations and `winSliding` for sliding aggregations based on `winRunning`. This approach entirely eliminates the need to repeat the `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` clause for each sliding aggregation.


-- *** IGNORE VALUES on FIRST_VALUE and LAST_VALUE

-- `FIRST_VALUE` and `LAST_VALUE` are windowing functions in SQL that return the first and last values in a specified range according to the order defined in the `OVER` clause. These functions can be very useful for analytics, allowing you to easily retrieve the earliest or latest value among a group of rows in an ordered window.

-- A common issue with these functions arises when dealing with NULLs in the data. By default, `FIRST_VALUE` and `LAST_VALUE` respect NULLs, meaning that if the first or last value in the window according to the specified order is NULL, then NULL is returned. This can be problematic when you're interested in the first or last non-NULL value in the window.

-- Let's demonstrate this with an example. The `StockByDate` table stores one row for each product/date combination, with a quantity column for each product's stock on any given date:

CREATE TABLE StockByDate (
  StockDate date,
  ProductID int,
  Quantity int
)

INSERT INTO StockByDate
 (StockDate,     ProductID,   Quantity) VALUES
 ('2021-03-18',  142,         74),
 ('2021-04-11',  123,         95),	-- Product 123's highest quantity (95) stock date is 4/11/2021
 ('2021-04-12',  101,         38),
 ('2021-05-21',  130,         12),
 ('2021-05-30',  101,         28),
 ('2021-07-25',  123,         57),
 ('2021-07-28',  101,         12)	-- Product 101's lowest quantity (12) stock date is 7/28/2021

-- This table has one row for each combination of stock date and product, showing the available stock of each product on each date. Now run this query with `FIRST_VALUE` and `LAST_VALUE` windowing functions:

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) OVER win,
  HighestOn = LAST_VALUE(StockDate)  OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate

-- The results show `LowestOn` and `HighestOn` columns respectively, with the stock dates for the smallest and largest quantities for each product.

-- Now, introduce NULLs into the stock date. This column should normally never contain NULL, so any rows with a NULL stock date are considered invalid, and should be excluded from each product window in the query. Note how these are the same products and quantities as the previous query, only now notice how product 123's highest quantity is 95, but has a NULL stock date. Also notice how product 101's lowest quantity is 12, and it also has a NULL stock date.:

DELETE FROM StockByDate

INSERT INTO StockByDate
 (StockDate,     ProductID,   Quantity) VALUES
 ('2021-03-18',  142,         74),
 (NULL,          123,         95),	-- Product 123's highest quantity (95) stock date is NULL
 ('2021-04-12',  101,         38),
 ('2021-05-30',  101,         28),
 ('2021-05-21',  130,         12),
 ('2021-07-25',  123,         57),
 (NULL,          101,         12)	-- Product 101's lowest quantity (12) stock date is NULL

-- Now run the same query again:

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) OVER win,
  HighestOn = LAST_VALUE(StockDate)  OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate

-- This time, for products 101 and 123, the `LowestOn` and `HighestOn` values respectively will be NULL due to the presence of NULLs in `StockDate` for the smallest and largest quantities of those products.

-- To address this issue, SQL Server 2022 introduces the `IGNORE NULLS` syntax for these windowing functions. The following query simply adds `IGNORE NULLS` to the windowing syntax for the `LowestOn` and `HighestOn` columns:

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) IGNORE NULLS OVER win,
  HighestOn = LAST_VALUE(StockDate)  IGNORE NULLS OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate

-- Using `IGNORE NULLS`, the functions now skip over NULL values and return the first or last non-NULL value in the specified range. This can significantly improve the utility of `FIRST_VALUE` and `LAST_VALUE` in analyses where NULLs are present but you're interested in actual data values.

-- Also note the use of the new `WINDOW` clause we learned about at the start of this lab to define the window as `win`, which is then applied to both the `FIRST_VALUE` and `LAST_VALUE` functions with `OVER win`.

-- Make sure you understand the tradeoff here; without `IGNORE NULLS`, these values may return NULL for the truly lowest and highest stock dates. Using `IGNORE NULLS`, these values will never return NULL, but they will also ignore the lowest and highest stock dates in the event that they contain NULL.

-- *** Cleanup

DROP TABLE TxnData
DROP TABLE StockByDate
