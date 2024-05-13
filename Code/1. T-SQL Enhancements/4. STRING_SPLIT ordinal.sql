-- STRING_SPLIT Function with Ordinal

USE AdventureWorks2019

-- *** Basic Usage of STRING_SPLIT

-- **SQL Server 2016 and later:**

SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/')

-- **Enhancement in SQL Server 2022:**

SELECT *
FROM STRING_SPLIT('Bravo/Alpha/Tango/Delta', '/', 1)

-- *** Deduplicating Items While Preserving Order

SELECT
    value,
    ordinal
FROM
    STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)

-- Use `MIN(ordinal)` with `GROUP BY` to dedupe while maintaining original sequence:

SELECT
    value,
    ordinal = MIN(ordinal)
FROM 
    STRING_SPLIT('Bravo/Alpha/Bravo/Tango/Delta/Bravo/Alpha/Delta', '/', 1)
GROUP BY
    value
ORDER BY
    ordinal

-- Use `STRING_AGG` to reconstruct the string from the deduplicated elements, while preserving their original order.

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

-- *** Bulk Processing with Preserved Ordinal

-- First, note the three rows in the `Person.Person` table with IDs 6, 12, and 18, for Jossef, Thierry, and John:

-- Here are three person rows with IDs 6, 12, and 18
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE BusinessEntityID IN (6, 12, 18)

-- Next, let's perform a bulk operation on these three rows. We'll use a `SELECT` in this case, but it could also be a bulk DML operation like `UPDATE`, `DELETE`, or `MERGE`, with an `OUTPUT` clause that returns results about the bulk update.

-- Bulk processing with preserved order
DECLARE @BusinessEntityIDs varchar(max) = '6,12,18'

;WITH BusinessEntityIDsCte AS (
    SELECT
        CONVERT(int, value) AS BusinessEntityID,
        ordinal
    FROM
        STRING_SPLIT(@BusinessEntityIDs, ',', 1)
)
SELECT
    ids.Ordinal,    -- Use ordinal for original sequence correlation
    p.FirstName,
    p.LastName,
    e.JobTitle
FROM
    Person.Person AS p
    INNER JOIN HumanResources.Employee AS e ON e.BusinessEntityID = p.BusinessEntityID
    INNER JOIN BusinessEntityIDsCte AS ids ON ids.BusinessEntityID = p.BusinessEntityID
ORDER BY
    LastName
