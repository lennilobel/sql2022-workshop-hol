--TRIM Function Enhancements

-- SQL Server 2017: Introduced the `TRIM` function, allowing for the removal of spaces or specified characters from a string.
  
  SELECT TRIM('   text with extra leading and trailing spaces   ') AS TrimmedText

-- SQL Server 2022: Enhances the `TRIM` function with `BOTH`, `LEADING`, and `TRAILING` keywords

-- TRIM spaces by default (as in SQL Server 2017)
SELECT TRIM('    Hello, World!    ') AS DefaultTrim

-- TRIM with specific noise characters
SELECT TRIM('.,! ' FROM '...Hello, World!!!') AS NoiseCharTrim

-- Using LEADING to remove leading characters
SELECT TRIM(LEADING '.,! ' FROM '...Hello, World!!!') AS LeadingTrim

-- Using TRAILING to remove trailing characters
SELECT TRIM(TRAILING '.,! ' FROM '...Hello, World!!!') AS TrailingTrim

-- Emulating LTRIM
SELECT TRIM(LEADING ' ' FROM '    Hello, World!    ') AS EmulateLTRIM

-- Emulating RTRIM
SELECT TRIM(TRAILING ' ' FROM '    Hello, World!    ') AS EmulateRTRIM
