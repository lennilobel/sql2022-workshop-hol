/* =================== STRING_SPLIT Ordinal =================== */

-- STRING_SPLIT (SQL 2016+)
SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/')

-- SQL 2022 supports "enable ordinal" bit parameter to report each item's ordinal position
SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/', 1)

-----------------------------------------------------------------------------------------------------------------------
-- Deduping items using MIN and GROUP BY changes their order
SELECT
	value,
	ordinal
FROM
	STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)

-- The new ordinal is useful for deduping delimited items while preserving their order
SELECT
	value,
	ordinal = MIN(ordinal)
FROM 
	STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)
GROUP BY
	value
ORDER BY
	ordinal

-- Combined with STRING_AGG, we can rebuild the delimited string with dupes eliminated and order preserved
;WITH SplitCte AS (
	SELECT
		value,
		ordinal = MIN(ordinal)
	FROM
		STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)
	GROUP BY
		value
)
SELECT
	Deduped = STRING_AGG(value, '/') WITHIN GROUP (ORDER BY ordinal)
FROM
	SplitCte

-----------------------------------------------------------------------------------------------------------------------
-- Useful if the ordinal is needed when bulk processing rows against IDs supplied as CSV
USE AdventureWorks2019
GO

-- Here are three person rows with IDs 6, 12, and 18
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE BusinessEntityID IN (6, 12, 18)

-- Bulk process the three rows by passing in a CSV string
DECLARE @BusinessEntityIDs varchar(max) = '6,12,18'

-- Process the rows, return an enriched resultset in a different order
;WITH BusinessEntityIDsCte AS (
	SELECT
		CONVERT(int, value) AS BusinessEntityID,
		ordinal
	FROM
		STRING_SPLIT(@BusinessEntityIDs, ',', 1)
)
SELECT
	ids.Ordinal,	-- Returning the ordinal allows the caller to correlate the out-of-sequence results with the original input sequence
	p.FirstName,
	p.LastName,
	e.JobTitle
FROM
	Person.Person AS p
	INNER JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
	INNER JOIN BusinessEntityIDsCte AS ids ON ids.BusinessEntityID = p.BusinessEntityID
ORDER BY
	LastName
