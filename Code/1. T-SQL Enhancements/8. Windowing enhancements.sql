-- Windowing Enhancements

USE AdventureWorks2019
GO

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

-- Using the WINDOW clause to eliminate code duplication

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

-- *** IGNORE VALUES on FIRST_VALUE and LAST_VALUE

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

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) OVER win,
  HighestOn = LAST_VALUE(StockDate)  OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate

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

-- Use IGNORE NULLS

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) IGNORE NULLS OVER win,
  HighestOn = LAST_VALUE(StockDate)  IGNORE NULLS OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate

-- Cleanup

DROP TABLE TxnData
DROP TABLE StockByDate
