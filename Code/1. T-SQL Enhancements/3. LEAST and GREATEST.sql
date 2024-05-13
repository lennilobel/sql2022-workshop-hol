-- LEAST and GREATEST Functions

USE AdventureWorks2019

-- *** Simple Example

DECLARE @NumericValue1 varchar(max) = '6.62'
DECLARE @NumericValue2 decimal(18, 4) = 3.1415
DECLARE @NumericValue3 varchar(max) = '7'

DECLARE @StringValue1 varchar(max) = 'Glacier'
DECLARE @StringValue2 varchar(max) = 'Mount Ranier'
DECLARE @StringValue3 varchar(max) = 'Joshua Tree'

-- Like MIN and MAX, but across columns within a single row
SELECT
    LeastNumeric    = LEAST(@NumericValue1, @NumericValue2, @NumericValue3),
    LeastString     = LEAST(@StringValue1, @StringValue2, @StringValue3),
    GreatestNumeric = GREATEST(@NumericValue1, @NumericValue2, @NumericValue3),
    GreatestString  = GREATEST(@StringValue1, @StringValue2, @StringValue3)

-- *** Comparison with Pre-2022 Approach Using CASE Statements

DECLARE @NumericValue1 varchar(max) = '6.62'
DECLARE @NumericValue2 decimal(18, 4) = 3.1415
DECLARE @NumericValue3 varchar(max) = '25'

DECLARE @StringValue1 varchar(max) = 'Glacier'
DECLARE @StringValue2 varchar(max) = 'Mount Ranier'
DECLARE @StringValue3 varchar(max) = 'Joshua Tree'

-- Before LEAST and GREATEST, we had to use ugly CASE statements
SELECT
    LeastNumeric =
     CASE
      WHEN @NumericValue1 < @NumericValue2 AND @NumericValue1 < @NumericValue3 THEN @NumericValue1
      WHEN @NumericValue2 < @NumericValue1 AND @NumericValue2 < @NumericValue3 THEN @NumericValue2
      WHEN @NumericValue3 < @NumericValue1 AND @NumericValue3 < @NumericValue2 THEN @NumericValue3
     END,
    LeastString =
     CASE
      WHEN @StringValue1 < @StringValue2 AND @StringValue1 < @StringValue3 THEN @StringValue1
      WHEN @StringValue2 < @StringValue1 AND @StringValue2 < @StringValue3 THEN @StringValue2
      WHEN @StringValue3 < @StringValue1 AND @StringValue3 < @StringValue2 THEN @StringValue3
     END,
    GreatestNumeric =
     CASE
      WHEN @NumericValue1 > @NumericValue2 AND @NumericValue1 > @NumericValue3 THEN @NumericValue1
      WHEN @NumericValue2 > @NumericValue1 AND @NumericValue2 > @NumericValue3 THEN @NumericValue2
      WHEN @NumericValue3 > @NumericValue1 AND @NumericValue3 > @NumericValue2 THEN @NumericValue3
     END,
    GreatestString =
     CASE
      WHEN @StringValue1 > @StringValue2 AND @StringValue1 > @StringValue3 THEN @StringValue1
      WHEN @StringValue2 > @StringValue1 AND @StringValue2 > @StringValue3 THEN @StringValue2
      WHEN @StringValue3 > @StringValue1 AND @StringValue3 > @StringValue2 THEN @StringValue3
     END

-- *** Scenario: Identifying Earliest and Latest Update Dates

CREATE TABLE Company
(
    CompanyId       int IDENTITY PRIMARY KEY,
    CompanyName     varchar(40),
    UpdateByApp1    date,
    UpdateByApp2    date,
    UpdateByApp3    date
)

INSERT INTO Company
 (CompanyName, UpdateByApp1,  UpdateByApp2,  UpdateByApp3) VALUES
 ('ABC',       '2022-08-05',  '2023-08-04',  '2021-08-06'),
 ('Acme',      '2023-07-05',  '2021-12-09',  '2022-08-14'),
 ('Wonka',     '2021-03-05',  '2022-01-14',  '2023-07-26')

SELECT
    CompanyId,
    CompanyName,
    FirstUpdateDate  = LEAST(UpdateByApp1, UpdateByApp2, UpdateByApp3),
    LastUpdateDate   = GREATEST(UpdateByApp1, UpdateByApp2, UpdateByApp3)
FROM
    Company

DROP TABLE Company
