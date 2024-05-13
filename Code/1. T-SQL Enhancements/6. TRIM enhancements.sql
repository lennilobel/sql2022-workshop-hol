--TRIM Function Enhancements

-- SQL Server 2022 brings minor enhancements to the `TRIM` function, expanding its utility beyond its initial capabilities introduced in SQL Server 2017.

-- Originally, the `TRIM` function provided a way to remove spaces or specified characters from both ends of a string. SQL Server 2022 provides additional flexibility with the introduction of keywords `BOTH`, `LEADING`, and `TRAILING`, aligning with the functionality of `LTRIM` and `RTRIM` but extending it to handle any noise characters.

-- *** Evolution of TRIM Function

-- - **SQL Server 2017:** Introduced the `TRIM` function, allowing for the removal of spaces or specified characters from a string.
  
  SELECT TRIM('   text with extra leading and trailing spaces   ') AS TrimmedText

-- - **SQL Server 2022:** Enhances the `TRIM` function with `BOTH`, `LEADING`, and `TRAILING` keywords, offering precise control over the trimming operation and making `LTRIM` and `RTRIM` effectively redundant.

-- *** Examples Demonstrating the Extended Functionality

-- Run each of these queries one at a time, to observe the applied use of the `TRIM` function in each case:

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
