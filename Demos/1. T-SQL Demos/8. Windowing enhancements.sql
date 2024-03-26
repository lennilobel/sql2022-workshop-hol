/* =================== Windowing =================== */

-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-window-transact-sql

CREATE DATABASE MyDB
GO

USE MyDB
GO

DROP TABLE IF EXISTS TxnData

CREATE TABLE TxnData (AcctId int, TxnDate date, Amount decimal)

INSERT INTO TxnData (AcctId, TxnDate, Amount) VALUES
  (1, DATEFROMPARTS(2021, 8, 10), 500),  -- 5 transactions for acct 1
  (1, DATEFROMPARTS(2021, 8, 22), 250),
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

CREATE TABLE StockByDate (
  StockDate date,
  ProductID int,
  Quantity int
)

INSERT INTO StockByDate
 (StockDate,     ProductID,   Quantity) VALUES
 ('2021-03-18',  142,         74),
 ('2021-04-11',  123,         95),	-- Product 123's highest quantity stock date is 4/11/2021
 ('2021-04-12',  101,         38),
 ('2021-05-30',  101,         28),
 ('2021-05-21',  130,         12),
 ('2021-07-25',  123,         57),
 ('2021-07-28',  101,         12)	-- Product 101's lowest quantity stock date is 7/28/2021

SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) OVER win,
  HighestOn = LAST_VALUE(StockDate)  OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate		-- switch to ProductID to sort results the same as the internal window order

-- But it's a problem if you have NULLs:
DELETE FROM StockByDate
INSERT INTO StockByDate
 (StockDate,     ProductID,   Quantity) VALUES
 ('2021-03-18',  142,         74),
 (NULL,          123,         95),	-- Product 123's highest quantity stock date is NULL
 ('2021-04-12',  101,         38),
 ('2021-05-30',  101,         28),
 ('2021-05-21',  130,         12),
 ('2021-07-25',  123,         57),
 (NULL,          101,         12)	-- Product 101's lowest quantity stock date is NULL

-- Default is RESPECT NULLS, which gives us NULL order dates for ProductID 101 LowestOn, and for ProductID 123 HighestOn
SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) OVER win,
  HighestOn = LAST_VALUE(StockDate)  OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY StockDate		-- switch to ProductID to sort results the same as the internal window order

-- With IGNORE NULLS, we get meaningful (non-NULL) order dates for each product
SELECT
  StockDate,
  ProductID,
  Quantity,
  LowestOn  = FIRST_VALUE(StockDate) IGNORE NULLS OVER win,
  HighestOn = LAST_VALUE(StockDate)  IGNORE NULLS OVER win
 FROM StockByDate
 WINDOW win AS (PARTITION BY ProductID ORDER BY Quantity ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
 ORDER BY ProductID --StockDate		-- switch to ProductID to sort results the same as the internal window order

GO

-- Cleanup
DROP TABLE IF EXISTS TxnData
DROP TABLE IF EXISTS StockByDate
GO
