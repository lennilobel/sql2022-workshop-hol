/* =================== Ledger =================== */

-- https://www.mssqltips.com/sqlservertip/6889/azure-sql-database-ledger-data-tampering-protection/
-- https://www.mssqltips.com/sqlservertip/6890/azure-sql-database-ledger-getting-started-and-examples/

CREATE DATABASE LedgerDemo
GO

USE LedgerDemo
GO

-- Generate digest: NULL
EXEC sys.sp_generate_database_ledger_digest

--------------------------------------------------------------------------------------------------------------
-- Append-only ledger tables
--  https://docs.microsoft.com/en-us/sql/relational-databases/security/ledger/ledger-how-to-append-only-ledger-tables

-- Create an append-only ledger table (requires the ENABLE LEDGER permission)
CREATE TABLE KeyCardEvent (
	EmployeeId int NOT NULL,
	Operation varchar(1024) NOT NULL,
	CreatedAt datetime2 NOT NULL
)
WITH (
	LEDGER = ON (
		APPEND_ONLY = ON
	)
)

-- {"database_name":"LedgerDemo","block_id":0,"hash":"0xBC18215864D0856CB02C56013ACE53773847D4D8362878EC7D642C1BB33E685F","last_transaction_commit_time":"2022-06-03T14:12:19.6533333","digest_time":"2022-06-03T14:12:21.5261698"}
EXEC sys.sp_generate_database_ledger_digest

-- Create a row
INSERT INTO KeyCardEvent VALUES
 (43869, 'Building42', '2022-06-02T18:55:22')

-- {"database_name":"LedgerDemo","block_id":1,"hash":"0x62B06967C1E8F96B750286DF41D8FCAE05A9039A8F32DC725CA6155D32EDB4A5","last_transaction_commit_time":"2022-06-03T14:12:31.3533333","digest_time":"2022-06-03T14:12:35.6923517"}
EXEC sys.sp_generate_database_ledger_digest

-- Create two more rows
INSERT INTO KeyCardEvent VALUES
 (43869, 'Building49', '2022-06-02T19:58:47'),
 (19557, 'Building97', '2022-06-02T20:01:56')

-- {"database_name":"LedgerDemo","block_id":2,"hash":"0xD8212991C3B40AAAABF3F5106308CE093F871C4DDED21FBF7B16646DED025857","last_transaction_commit_time":"2022-06-03T14:12:45.9700000","digest_time":"2022-06-03T14:12:48.0325560"}
EXEC sys.sp_generate_database_ledger_digest

-- View the new rows
SELECT * FROM KeyCardEvent

-- Include START HIDDEN columns (transaction ID and sequence number)
SELECT
	*,
	ledger_start_transaction_id,
	ledger_start_sequence_number
FROM
	KeyCardEvent

-- Actual table that was created includes default START HIDDEN columns and ledger view definition
/*
	CREATE TABLE KeyCardEvent (
		EmployeeId int NOT NULL,
		Operation varchar(1024) NOT NULL,
		CreatedAt datetime2(7) NOT NULL,
		ledger_start_transaction_id bigint GENERATED ALWAYS AS transaction_id START HIDDEN NOT NULL,
		ledger_start_sequence_number bigint GENERATED ALWAYS AS sequence_number START HIDDEN NOT NULL
	)
	WITH (
		LEDGER = ON (
			APPEND_ONLY = ON,
			LEDGER_VIEW = dbo.KeyCardEvent_Ledger (
				TRANSACTION_ID_COLUMN_NAME = ledger_transaction_id,
				SEQUENCE_NUMBER_COLUMN_NAME = ledger_sequence_number,
				OPERATION_TYPE_COLUMN_NAME = ledger_operation_type,
				OPERATION_TYPE_DESC_COLUMN_NAME = ledger_operation_type_desc
			)
		)
	)
*/
GO

-- The ledger view shows the INSERTs (will always align with append-only ledger tables)
SELECT * FROM KeyCardEvent_Ledger

-- The sys.database_ledger_transactions system view shows each transaction (e.g., block ID, commit time, user principal)
SELECT * FROM sys.database_ledger_transactions 

-- Join to view transactions with data
--  block 0 = no key card event rows
--  block 1 = one new key card event row (INSERT)
--  block 2 = two new key card event rows (INSERT)
SELECT
	lt.*,
	lv.*
FROM
	sys.database_ledger_transactions AS lt
	LEFT JOIN KeyCardEvent_Ledger AS lv ON lv.ledger_transaction_id = lt.transaction_id
ORDER BY
	lt.commit_time,
	lv.ledger_sequence_number

-- Try to update rows in the table; fails for append-only ledger table
/*
	UPDATE KeyCardEvent
		SET EmployeeId = 34184
		WHERE EmployeeId = 43869
*/

-- Try to delete rows in the table; fails for append-only ledger table
/*
	DELETE KeyCardEvent
		WHERE EmployeeId = 43869
*/

GO


--------------------------------------------------------------------------------------------------------------
-- Updateable ledger tables
--  https://docs.microsoft.com/en-us/sql/relational-databases/security/ledger/ledger-how-to-updatable-ledger-tables

CREATE TABLE Balance (
    CustomerId int NOT NULL PRIMARY KEY CLUSTERED,
    LastName varchar(50) NOT NULL,
    FirstName varchar(50) NOT NULL,
    Balance decimal(10,2) NOT NULL
)
WITH (
	LEDGER = ON,
	SYSTEM_VERSIONING = ON (
		HISTORY_TABLE = dbo.Balance_History
	)
)

-- {"database_name":"LedgerDemo","block_id":3,"hash":"0x77DE3C69C8FDC86DC32CC6188322DD1A1B66147BA6404D52987069A36D6EC1FD","last_transaction_commit_time":"2022-06-03T14:14:42.3033333","digest_time":"2022-06-03T14:14:43.8818956"}
EXEC sys.sp_generate_database_ledger_digest

-- Actual table that was created includes default START/END HIDDEN columns and ledger view definition
/*
	CREATE TABLE Balance (
		CustomerId int NOT NULL PRIMARY KEY CLUSTERED,
		LastName varchar(50) NOT NULL,
		FirstName varchar(50) NOT NULL,
		Balance decimal(10,2) NOT NULL,
		ledger_start_transaction_id bigint GENERATED ALWAYS AS transaction_id START HIDDEN NOT NULL,
		ledger_end_transaction_id bigint GENERATED ALWAYS AS transaction_id END HIDDEN NULL,
		ledger_start_sequence_number bigint GENERATED ALWAYS AS sequence_number START HIDDEN NOT NULL,
		ledger_end_sequence_number bigint GENERATED ALWAYS AS sequence_number END HIDDEN NULL
	)
	WITH (
		LEDGER = ON (
			LEDGER_VIEW = dbo.Balance_Ledger (
				TRANSACTION_ID_COLUMN_NAME = ledger_transaction_id,
				SEQUENCE_NUMBER_COLUMN_NAME = ledger_sequence_number,
				OPERATION_TYPE_COLUMN_NAME = ledger_operation_type,
				OPERATION_TYPE_DESC_COLUMN_NAME = ledger_operation_type_desc)
		),
		SYSTEM_VERSIONING = ON (
			HISTORY_TABLE = dbo.Balance_History
		)
	)
*/
GO

-- Show all ledger tables (those that have ledger views); append-only ledger tables don't have/need a history table
SELECT 
	ts.name + '.' + t.name AS LedgerTableName,
	vs.name + '.' + v.name AS LedgerViewName,
	hs.name + '.' + h.name AS HistoryTableName
FROM
	sys.tables AS t
	INNER JOIN sys.schemas ts ON (ts.schema_id = t.schema_id)
	INNER JOIN sys.views v ON (v.object_id = t.ledger_view_id)
	INNER JOIN sys.schemas vs ON (vs.schema_id = v.schema_id)
	LEFT JOIN sys.tables AS h ON (h.object_id = t.history_table_id)
	LEFT JOIN sys.schemas hs ON (hs.schema_id = h.schema_id)
WHERE
	t.ledger_view_id IS NOT NULL

-- Create a row
INSERT INTO Balance VALUES
 (1, 'Jones', 'Nick', 50)

-- {"database_name":"LedgerDemo","block_id":4,"hash":"0x3FFAEC703AF66D8C04A7ECFC37895C8EF311F561B7B0A09F0487A50E9C7BAA98","last_transaction_commit_time":"2022-06-03T14:15:16.5133333","digest_time":"2022-06-03T14:15:21.2682202"}
EXEC sys.sp_generate_database_ledger_digest

-- Create three more rows
INSERT INTO Balance VALUES
 (2, 'Smith', 'John', 500),
 (3, 'Smith', 'Joe', 30),
 (4, 'Michaels', 'Mary', 200)

-- {"database_name":"LedgerDemo","block_id":5,"hash":"0x0CCCD575CE2902DD38D82ECE3C113BF441609BD31E1A6ACD1BEEF904D14070C0","last_transaction_commit_time":"2022-06-03T14:16:23.4300000","digest_time":"2022-06-03T14:16:25.1812430"}
EXEC sys.sp_generate_database_ledger_digest

-- Hidden ledger table columns ledger_start_transaction_id and ledger_start_sequence_number groups each transaction (note Nick's values 1041/0)
SELECT 
	*,
	ledger_start_transaction_id,
	ledger_end_transaction_id,
	ledger_start_sequence_number,
	ledger_end_sequence_number
FROM
	Balance

-- Change Nick's balance from 50 to 100
UPDATE Balance SET Balance = 100
	WHERE CustomerId = 1

-- {"database_name":"LedgerDemo","block_id":6,"hash":"0x2628CAA7BFE536EFFD49EA5CE4E69D5A345EB88A8E9F7E158FCBAEB496874169","last_transaction_commit_time":"2022-06-03T14:17:18.8566667","digest_time":"2022-06-03T14:17:21.1946204"}
EXEC sys.sp_generate_database_ledger_digest

-- Note Nick's ledger_start_transaction_id changed
SELECT 
	*,
	ledger_start_transaction_id,
	ledger_end_transaction_id,
	ledger_start_sequence_number,
	ledger_end_sequence_number
FROM
	Balance

-- Ledger history table has a previous row for Nick
SELECT * FROM Balance_History

-- Change Nick's balance from 100 to 150
UPDATE Balance SET Balance = 150
	WHERE CustomerId = 1

-- {"database_name":"LedgerDemo","block_id":7,"hash":"0xA961C3DC781CCA04EC92B1F5CF1374000614F37C89D2EA241ADDAE9638F692F5","last_transaction_commit_time":"2022-06-03T14:18:51.1033333","digest_time":"2022-06-03T14:18:52.8176210"}
EXEC sys.sp_generate_database_ledger_digest

-- Note Nick's ledger_start_transaction_id changed again
SELECT 
	*,
	ledger_start_transaction_id,
	ledger_end_transaction_id,
	ledger_start_sequence_number,
	ledger_end_sequence_number
FROM
	Balance

-- Ledger history table has two previous rows for Nick
SELECT * FROM Balance_History

-- Ledger view
SELECT * FROM Balance_Ledger
ORDER BY ledger_transaction_id, ledger_sequence_number

-- Show transactions starting from block ID 3 (our first transaction on the Balance table)
SELECT * FROM sys.database_ledger_transactions WHERE block_id >= 3

-- Join to view transactions with data
--  block 3 = no balance rows
--  block 4 = one new balance row (INSERT)
--  block 5 = three new balance rows (INSERT)
--  block 6 = one updated (INSERT + DELETE) balance row
--  block 7 = one updated (INSERT + DELETE) balance row
SELECT
	lt.*,
	lv.*
FROM
	sys.database_ledger_transactions AS lt
	LEFT JOIN Balance_Ledger AS lv ON lv.ledger_transaction_id = lt.transaction_id
WHERE
	lt.block_id >= 3
ORDER BY
	lt.commit_time,
	lv.ledger_sequence_number

-- View ledger transactions across both KeyCard and Balance ledger views
SELECT
	lt.*,
	kcelv.*,
	blv.*
FROM
	sys.database_ledger_transactions AS lt
	LEFT JOIN KeyCardEvent_Ledger AS kcelv ON kcelv.ledger_transaction_id = lt.transaction_id
	LEFT JOIN Balance_Ledger AS blv ON blv.ledger_transaction_id = lt.transaction_id
ORDER BY
	lt.commit_time,
	kcelv.ledger_sequence_number,
	blv.ledger_sequence_number

GO


--------------------------------------------------------------------------------------------------------------
-- Run ledger verification for the database
--  https://docs.microsoft.com/en-us/sql/relational-databases/security/ledger/ledger-verify-database

-- Using a manual generated digest

-- Needs snapshot isolation to verify the database ledger
EXEC sp_verify_database_ledger N'The digest JSON'

-- Enable snapshot isolation
ALTER DATABASE LedgerDemo SET ALLOW_SNAPSHOT_ISOLATION ON

-- Needs valid digest JSON to verify the database ledger
EXEC sp_verify_database_ledger N'The digest JSON'

EXEC sp_generate_database_ledger_digest

EXEC sp_verify_database_ledger N'{"database_name":"LedgerDemo","block_id":7,"hash":"0xDE38671E7EE8F0E4E9056FA7D7754555102EF811F798825F0EB82B5A62926850","last_transaction_commit_time":"2024-03-06T08:20:35.9100000","digest_time":"2024-03-06T13:24:03.4176322"}'

-- Tamper with the data using the HxD disk editor
USE master
GO
ALTER DATABASE LedgerDemo SET OFFLINE
GO

-- https://mh-nexus.de/en/downloads.php?product=HxD20

ALTER DATABASE LedgerDemo SET ONLINE
GO
USE LedgerDemo
GO

-- Using automatic digest storage (Azure SQL Database only)

SELECT * FROM sys.database_ledger_digest_locations
SELECT * FROM sys.database_ledger_digest_locations FOR JSON AUTO, INCLUDE_NULL_VALUES

DECLARE @digest_locations nvarchar(max) =
 (SELECT * FROM sys.database_ledger_digest_locations FOR JSON AUTO, INCLUDE_NULL_VALUES)

SELECT @digest_locations as digest_locations

BEGIN TRY
    EXEC sys.sp_verify_database_ledger_from_digest_storage @digest_locations
    SELECT 'Ledger verification succeeded.' AS Result
END TRY
BEGIN CATCH
    THROW;
END CATCH


--------------------------------------------------------------------------------------------------------------
-- Dropping ledger tables

DROP TABLE KeyCardEvent		-- Append-only ledger table is renamed and moved to "Dropped Ledger Tables"
DROP TABLE Balance			-- Updateable ledger table and its history table are renamed and moved to "Dropped Ledger Tables"


--------------------------------------------------------------------------------------------------------------
-- Combining updateable ledger with temporal... yes you can!

CREATE TABLE Balance (
    CustomerId	int NOT NULL PRIMARY KEY CLUSTERED,
    LastName	varchar(50) NOT NULL,
    FirstName	varchar(50) NOT NULL,
    Balance		decimal(10,2) NOT NULL,
	ValidFrom	datetime2 GENERATED ALWAYS AS ROW START NOT NULL, 
	ValidTo		datetime2 GENERATED ALWAYS AS ROW END NOT NULL,   
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (
	LEDGER = ON,
	SYSTEM_VERSIONING = ON (
		HISTORY_TABLE = dbo.Balance_History
	)
)
GO

DROP TABLE Balance
GO

--------------------------------------------------------------------------------------------------------------
-- Cleanup

USE master
GO
DROP DATABASE LedgerDemo
GO
