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

-- Four different previous ways of using MIN and MAX to achieve finding the lowest and highest column values across all three:

-- Previous way #1 (column subquery with row constructors)
SELECT 
	CompanyId, 
	CompanyName,
	FirstUpdateDate = (
		SELECT
			MIN(LastUpdateDate)
		FROM (VALUES
			(UpdateByApp1Date),
			(UpdateByApp2Date),
			(UpdateByApp3Date)
		) AS UpdateDate(LastUpdateDate)
	),
	LastUpdateDate = (
		SELECT
			MAX(LastUpdateDate)
		FROM (VALUES
			(UpdateByApp1Date),
			(UpdateByApp2Date),
			(UpdateByApp3Date)
		) AS UpdateDate(LastUpdateDate)
	)
FROM
	Company

-- Previous way #2 (UNPIVOT with GROUP BY)
SELECT
	CompanyId,
	CompanyName,
	FirstUpdateDate = MIN(UpdateDate),
	LastUpdateDate = MAX(UpdateDate)
FROM
	Company
	UNPIVOT (UpdateDate FOR DateVal IN (UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date)) AS u
GROUP BY
	CompanyId,
	CompanyName

-- Previous way #3 (CTE subquery with UNION and GROUP BY)
;WITH Cte AS (
	SELECT CompanyId, CompanyName, UpdateByApp1Date AS UpdateDate FROM Company UNION 
	SELECT CompanyId, CompanyName, UpdateByApp2Date AS UpdateDate FROM Company UNION 
	SELECT CompanyId, CompanyName, UpdateByApp3Date AS UpdateDate FROM Company
)
SELECT
	CompanyId,
	CompanyName,
	FirstUpdateDate = MIN(UpdateDate),
	LastUpdateDate = MAX(UpdateDate)
FROM
	Cte AS ud
GROUP BY
	CompanyId,
	CompanyName

-- Previous way #4 (column subquery with UNION)
SELECT
	CompanyId,
	CompanyName,
	FirstUpdateDate  = (
		SELECT
			MIN(UpdateDate) AS LastUpdateDate
		FROM (
			SELECT c.UpdateByApp1Date AS UpdateDate UNION
			SELECT c.UpdateByApp2Date AS UpdateDate UNION
			SELECT c.UpdateByApp3Date AS UpdateDate
		) AS ud
	),
	LastUpdateDate  = (
		SELECT
			MAX(UpdateDate) AS LastUpdateDate
		FROM (
			SELECT c.UpdateByApp1Date AS UpdateDate UNION
			SELECT c.UpdateByApp2Date AS UpdateDate UNION
			SELECT c.UpdateByApp3Date AS UpdateDate
		) AS ud
	)
FROM Company AS c

-- New way - with LEAST and GREATEST
SELECT
	CompanyId,
	CompanyName,
	FirstUpdateDate = LEAST(UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date),
	LastUpdateDate = GREATEST(UpdateByApp1Date, UpdateByApp2Date, UpdateByApp3Date)
FROM
	Company
