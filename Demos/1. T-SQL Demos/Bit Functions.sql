/* =================== Bit functions =================== */

-- Color flags:
--			Pos	Dec		Hex		Binary
--	Red		0	  1		  1		00000001
--	Green	1	  2		  2		00000010
--	Blue	2	  4		  4		00000100
--	Yellow	3	  8		  8		00001000
--	Cyan	4	 16		 10		00010000
--	Purple	5	 32		 20		00100000
--	Brown	6	 64		 40		01000000
--	Black	7	128		 80		10000000

-- How many colors (set bits) are in the value?
DECLARE @Colors tinyint				-- A tinyint is an 8-bit unsigned byte

SET @Colors = 0x09					-- 00001001 (red and yellow)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Add in brown and black with a bitwise OR
SET @Colors = @Colors | 0xC0		--    00001001 (red and yellow)
									--  | 11000000 (brown and black)
									--  = 11001001 (red, yellow, brown, and black)
SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Remove yellow, blue, green, and red with a bitwise AND
SET @Colors = @Colors & 0xF0		--    11001001 (red, yellow, brown, and black)
									--	& 11110000 (yellow, blue, green, and red)
									--  = 11000000 (brown and black)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red

-- Flip color selections with a bitwise NOT
SET @Colors = ~ @Colors				--    11000000 (brown and black)
									--	~ 
									--  = 00111111 (red, green, blue, yellow, cyan, and purple)

SELECT
	@Colors,
	CONVERT(varbinary(1), @Colors),
	BIT_COUNT(@Colors) AS ColorCount,
	GET_BIT(@Colors, 7) AS Black,
	GET_BIT(@Colors, 6) AS Brown,
	GET_BIT(@Colors, 5) AS Purple,
	GET_BIT(@Colors, 4) AS Cyan,
	GET_BIT(@Colors, 3) AS Yellow,
	GET_BIT(@Colors, 2) AS Blue,
	GET_BIT(@Colors, 1) AS Green,
	GET_BIT(@Colors, 0) AS Red


SELECT
	@Colors & 0x10 AS IsCyan	-- 00010000

-- Shift bits using LEFT_SHIFT (<<) and RIGHT_SHIFT (>>) to pack and unpack bits within a byte
DECLARE @MinMax tinyint
DECLARE @Min tinyint = 14		-- 1110		0x0E
DECLARE @Max tinyint = 9		-- 1001		0x09

-- Pack @Min and @Max (two 4-bit values in range 0-15) into @MinMax (a single 8-bit value in range 0-255)
SELECT @MinMax = LEFT_SHIFT(@Min, 4) + @Max		-- Shift @Min by four bits, then add @Max
SELECT @MinMax = (@Min << 4 ) + @Max			-- Use << as shorthand for LEFT_SHIFT
SELECT
	Min			= @Min,
	Max			= @Max,
	MinMax		= @MinMax,
	MinHex		= CONVERT(binary(1), @Min),
	MaxHex		= CONVERT(binary(1), @Max),
	MinMaxHex	= CONVERT(binary(1), @MinMax)

-- Unpack @Min from the upper four bits
SELECT @Min = RIGHT_SHIFT(@MinMax, 4)
SELECT @Min = @MinMax >> 4
SELECT
	Min			= @Min,
	MinHex		= CONVERT(binary(1), @Min)

-- Unpack @Max from the lower four bits using a bitwise AND to clear the upper four bits
SELECT @Max = @MinMax & 0x0F
SELECT
	Max			= @Max,
	MaxHex		= CONVERT(binary(1), @Max)

-- You can also individually clear the upper four bits using SET_BIT
SELECT @Max = @MinMax
SELECT @Max = SET_BIT(@Max, 4, 0)
SELECT @Max = SET_BIT(@Max, 5, 0)
SELECT @Max = SET_BIT(@Max, 6, 0)
SELECT @Max = SET_BIT(@Max, 7, 0)
SELECT
	Max			= @Max,
	MaxHex		= CONVERT(binary(1), @Max)


-- Bit manipulation on table data

USE MyDB
GO

DROP TABLE IF EXISTS Customer

CREATE TABLE Customer (
	CustomerId int IDENTITY PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	ColorSelections tinyint NOT NULL,		-- Pack eight single-bit values (0 or 1) in a single byte (0-255)
	MinMax tinyint NOT NULL					-- Pack two four-bit values (0-15) in a single byte (0-255)
)

INSERT INTO Customer
 (FirstName,	LastName,		ColorSelections,	MinMax) VALUES
 ('Ken',		'Sanchez',		0,					0),
 ('Terri',		'Duffy',		18,					18),
 ('Roberto',	'Tamburello',	96,					96),
 ('Rob',		'Walters',		158,				158),
 ('Gail',		'Erickson',		255,				255)

SELECT
	FirstName,
	ColorSelections,
	CONVERT(binary(1), ColorSelections) AS ColorSelectionsHex,
	BIT_COUNT(ColorSelections) AS ColorCount,
	GET_BIT(ColorSelections, 7) AS Black,
	GET_BIT(ColorSelections, 6) AS Brown,
	GET_BIT(ColorSelections, 5) AS Purple,
	GET_BIT(ColorSelections, 4) AS Cyan,
	GET_BIT(ColorSelections, 3) AS Yellow,
	GET_BIT(ColorSelections, 2) AS Blue,
	GET_BIT(ColorSelections, 1) AS Green,
	GET_BIT(ColorSelections, 0) AS Red,
	MinMax,
	CONVERT(binary(1), MinMax) AS MinMaxHex,
	RIGHT_SHIFT(MinMax, 4) AS Min,
	MinMax & 0x0F AS Max
FROM
	Customer

-- Cleanup
DROP TABLE IF EXISTS Customer
