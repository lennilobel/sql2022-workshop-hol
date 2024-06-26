﻿-- Bit Manipulation Enhancements in SQL Server 2022

-- SQL Server 2022 adds a set of operators dedicated to bit manipulation, significantly easing operations such as bit masking, and bitwise AND, OR, NOT operations, along with shifting bits left or right. This feature is particularly useful in scenarios where data compression (for example, storing two 4-bit values as as single 8-bit byte) or encoding (for example, storing eight boolean values as as single 8-bit byte) is required.

USE AdventureWorks2019
GO

CREATE TABLE Customer (
  CustomerId   int IDENTITY PRIMARY KEY,
  FirstName    varchar(50),
  LastName     varchar(50),
  Colors       tinyint,      -- Pack eight single-bit values (0 or 1) in a single byte (0-255)
  MinMax       tinyint       -- Pack two four-bit values (0-15) in a single byte (0-255)
)

INSERT INTO Customer
  (FirstName,    LastName,     Colors,  MinMax) VALUES
  ('Ken',        'Sanchez',    0x00,    0x00),
  ('Terri',      'Duffy',      0x12,    0x30),
  ('Roberto',    'Tamburello', 0x60,    0x7E),
  ('Rob',        'Walters',    0x9E,    0x9E),
  ('Gail',       'Erickson',   0xFF,    0xFF)

-- *** Bitwise Operations and Aggregations

-- The query demonstrates the extraction and manipulation of bits within the `Colors` and `MinMax` columns:

SELECT
  FirstName,
  Colors,
  ColorsHex  = CONVERT(binary(1), Colors),
  ColorCount = BIT_COUNT(Colors),
  Black      = GET_BIT(Colors, 7),
  Brown      = GET_BIT(Colors, 6),
  Purple     = GET_BIT(Colors, 5),
  Cyan       = GET_BIT(Colors, 4),
  Yellow     = GET_BIT(Colors, 3),
  Blue       = GET_BIT(Colors, 2),
  Green      = GET_BIT(Colors, 1),
  Red        = GET_BIT(Colors, 0),
  MinMax,
  MinMaxHex  = CONVERT(binary(1), MinMax),
  Min        = RIGHT_SHIFT(MinMax, 4),
  Max        = MinMax & 0x0F
FROM
  Customer

-- Cleanup

DROP TABLE Customer
