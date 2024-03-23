/* =================== Row-Level Security (RLS) =================== */

USE MyDB
GO

/*
------------------------------------------------------------
RLS Demo #1: Read-only sales policy, multiple database users
------------------------------------------------------------

Implement RLS to enable each sales user to read their data privately from all
other sales users, while the manager user can read and write data from all other
sales users. Each row in the database contains the sales username that must match
the corresponding DATABASE_PRINCIPAL_ID for that sales user; all other rows are
filtered out. No rows are filtered when connected as the manager user.
*/

DROP TABLE IF EXISTS Sales
GO

-- Create the sales data table
CREATE TABLE Sales(
    OrderID int,
    SalesUsername varchar(50),
    Product varchar(10),
    Qty int
)

-- Populate the table with 6 rows of data, 3 for SalesUser1 and 3 for SalesUser2
INSERT Sales VALUES 
	(1, 'SalesUser1', 'Valve', 5), 
	(2, 'SalesUser1', 'Wheel', 2), 
	(3, 'SalesUser1', 'Valve', 4),
	(4, 'SalesUser2', 'Bracket', 2), 
	(5, 'SalesUser2', 'Wheel', 5), 
	(6, 'SalesUser2', 'Seat', 5)

-- View the 6 rows in the table
SELECT * FROM Sales

-- Create the manager user and two sales users
CREATE USER ManagerUser WITHOUT LOGIN
CREATE USER SalesUser1 WITHOUT LOGIN
CREATE USER SalesUser2 WITHOUT LOGIN

-- Grant full access to the manager user, and read-only access to the sales users
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO ManagerUser
GRANT SELECT ON Sales TO SalesUser1
GRANT SELECT ON Sales TO SalesUser2
GO

-- Create a new schema for the predicate function
CREATE SCHEMA sec
GO

-- Create the predicate function
CREATE FUNCTION sec.SalesUserPredicate(@Username AS varchar(50))
    RETURNS TABLE
	WITH SCHEMABINDING
AS
    RETURN
		-- Return 1 if the connection username matches the @Username parameter,
		-- or if the connection username is ManagerUser
		SELECT
			1 AS result 
		WHERE
			DATABASE_PRINCIPAL_ID() = DATABASE_PRINCIPAL_ID(@Username) OR
			DATABASE_PRINCIPAL_ID() = DATABASE_PRINCIPAL_ID('ManagerUser')
GO

-- Create and enable a security policy adding the function as a filter predicate
CREATE SECURITY POLICY sec.SalesUserPolicy
	ADD FILTER PREDICATE sec.SalesUserPredicate(SalesUsername) 
	ON dbo.Sales
	WITH (STATE = ON)
GO

-- As user dbo, we get no rows (there are no rows where SalesUsername = 'dbo')
SELECT * FROM Sales 
SELECT COUNT(*) FROM Sales

-- As SalesUser1, we get just the rows we own
EXECUTE AS USER = 'SalesUser1'
SELECT * FROM Sales 
SELECT COUNT(*) FROM Sales
REVERT

-- As SalesUser2, we get just the rows we own
EXECUTE AS USER = 'SalesUser2'
SELECT * FROM Sales 
SELECT COUNT(*) FROM Sales
REVERT

-- As ManagerUser, we get all rows
EXECUTE AS USER = 'ManagerUser'
SELECT * FROM Sales 
REVERT

-- As SalesUser1, we can't insert/update/delete
EXECUTE AS USER = 'SalesUser1'
INSERT Sales VALUES (7, 'SalesUser1', 'Valve', 2)
UPDATE Sales SET Product = 'Screw' WHERE OrderId = 3
DELETE Sales WHERE OrderId = 2
REVERT

-- As Manager, we have full access
EXECUTE AS USER = 'ManagerUser'
INSERT Sales VALUES (7, 'SalesUser2', 'Valve', 1)		-- New item for order id 7 (SalesUser2)
UPDATE Sales SET Product = 'Screw' WHERE OrderId = 3	-- Changed product name for order id 3 (SalesUser1)
UPDATE Sales SET SalesUsername = 'SalesUser1' WHERE SalesUsername = 'SalesUser2' AND Qty > 3	-- reassign SalesUser1 items with Qty > 3 (order ids 5 & 6) to SalesUser2
DELETE Sales WHERE OrderId = 2							-- Delete item for order id 2 (SalesUser1)
SELECT * FROM Sales
REVERT

EXECUTE AS USER = 'SalesUser1'
SELECT * FROM Sales	-- 2 is gone, 3 is changed, 5 & 6 were transfered from SalesUser2 
SELECT COUNT(*) FROM Sales
REVERT

EXECUTE AS USER = 'SalesUser2'
SELECT * FROM Sales	-- 7 is added, 5 & 6 were transferred to SalesUser1
SELECT COUNT(*) FROM Sales
REVERT

-- Can toggle the security policy on and off
SELECT * FROM Sales		-- no rows for dbo with policy on
ALTER SECURITY POLICY sec.SalesUserPolicy WITH (STATE = OFF)
SELECT * FROM Sales		-- unfiltered rows for everyone with policy off
ALTER SECURITY POLICY sec.SalesUserPolicy WITH (STATE = ON)

-- Cleanup
DROP SECURITY POLICY IF EXISTS sec.SalesUserPolicy
DROP FUNCTION IF EXISTS sec.SalesUserPredicate
DROP SCHEMA IF EXISTS sec
DROP USER IF EXISTS ManagerUser
DROP USER IF EXISTS SalesUser1
DROP USER IF EXISTS SalesUser2
DROP TABLE IF EXISTS Sales


/*
--------------------------------------------------------------------------------------
RLS Demo #2: Updateable sales policy, single database user, multiple application users
--------------------------------------------------------------------------------------

This example shows how a client application can implement connection filtering,
where application users (or tenants) share the same database user (AppUser). All
clients connect as AppUser, while the application sets the user ID in SESSION_CONTEXT
when connecting to the database. Then, the security policy transparently filters
rows that shouldn't be visible to this user, and also blocks the user from inserting
rows with another user's ID.
*/

-- Create a simple table to hold data
CREATE TABLE Sales(
    OrderID int,
    SalesUsername varchar(50),
    Product varchar(10),
    Qty int
)

-- Populate the table with 6 rows of data, 3 for SalesUser1 and 3 for SalesUser2
INSERT Sales VALUES 
	(1, 'SalesUser1', 'Valve', 5), 
	(2, 'SalesUser1', 'Wheel', 2), 
	(3, 'SalesUser1', 'Valve', 4),
	(4, 'SalesUser2', 'Bracket', 2), 
	(5, 'SalesUser2', 'Wheel', 5), 
	(6, 'SalesUser2', 'Seat', 5)

-- Create the shared database user
CREATE LOGIN AppLogin WITH PASSWORD = 'Big$ecret123';
GO 
CREATE USER AppUser FOR LOGIN AppLogin
GO

-- Grant full access on the table to any AppUser
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO AppUser
GO

-- Create a new schema for the predicate function
CREATE SCHEMA sec
GO

-- Create the predicate function
CREATE FUNCTION sec.SalesUserPredicate(@Username varchar(max))
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN
		-- Return 1 only if the connection username matches "AppUser", and if the AppUsername
		-- passed in from the application via SESSION_CONTEXT matches the @Username
		-- parameter which will get bound to the AppUsername column of the Sales table. The
		-- only exception is ManageUser, who bypasses RLS completely

		SELECT
			1 AS result
		WHERE
			DATABASE_PRINCIPAL_ID() = DATABASE_PRINCIPAL_ID('AppUser') AND (
				CONVERT(varchar, SESSION_CONTEXT(N'AppUsername')) = @Username OR
				CONVERT(varchar, SESSION_CONTEXT(N'AppUsername')) = 'ManagerUser')
GO

-- Create and enable a security policy that adds the function as a filter predicate and a
-- two block predicates on the table. Only AFTER INSERT and AFTER UPDATE block predicates
-- are needed, because BEFORE UPDATE and BEFORE DELETE are already blocked by the filter
-- predicate.
CREATE SECURITY POLICY sec.SalesUserPolicy
    ADD FILTER PREDICATE sec.SalesUserPredicate(SalesUsername) ON dbo.Sales,
    ADD BLOCK PREDICATE sec.SalesUserPredicate(SalesUsername) ON dbo.Sales AFTER INSERT,
    ADD BLOCK PREDICATE sec.SalesUserPredicate(SalesUsername) ON dbo.Sales AFTER UPDATE
    WITH (STATE = ON)

-- As AppUser with AppUsername 'SalesUser1', we get just the rows we own
EXECUTE AS USER = 'AppUser'
EXEC sp_set_session_context @key = N'AppUsername', @value = 'SalesUser1'
SELECT * FROM Sales
SELECT COUNT(*) FROM Sales
GO

-- As AppUser with AppUsername 'SalesUser2', we get just the rows we own
EXEC sp_set_session_context @key = N'AppUsername', @value = 'SalesUser2'
SELECT * FROM Sales
SELECT COUNT(*) FROM Sales

-- We can insert new rows for ourselves
INSERT INTO Sales VALUES (7, 'SalesUser2', 'Seat', 12)
SELECT * FROM Sales
SELECT COUNT(*) FROM Sales

-- But we can't insert new rows for other users
INSERT INTO Sales VALUES (8, 'SalesUser1', 'Table', 8)

-- And we can't transfer rows we own to other users
UPDATE Sales SET SalesUsername = 'SalesUser1' WHERE OrderId = 5

-- As AppUser with AppUsername 'ManagerUser', RLS is effectively bypassed
EXEC sp_set_session_context @key = N'AppUsername', @value = 'ManagerUser', @read_only = 1	-- can't change user again this connection

-- Manager can see all
SELECT * FROM Sales
SELECT COUNT(*) FROM Sales

-- Manager can insert new rows for any user
INSERT INTO Sales VALUES (8, 'SalesUser1', 'Table', 2)
INSERT INTO Sales VALUES (9, 'SalesUser2', 'Lamp', 4)

-- Manager can transfer rows across different users
UPDATE Sales SET SalesUsername = 'SalesUser1' WHERE OrderId = 5

-- View the changes
SELECT * FROM Sales

-- AppUsername in session context cannot be changed because it was set with the read_only option
EXEC sp_set_session_context @key = N'AppUsername', @value = 'SalesUser1'


/* Client demo */
GO


/* Breaking RLS */
USE MyDB
GO
SELECT * FROM Sales
EXECUTE AS USER = 'AppUser'
GO
EXEC sp_set_session_context @key = N'AppUsername', @value = 'ManagerUser'
SELECT * FROM Sales

DECLARE @QtyTest int = 4
DECLARE @ProductTest varchar(max) = 'Lamp'
SELECT
	*,
	(Qty - @QtyTest) AS QtyTest,
	(SUBSTRING(Product, 1, 1)) AS ProductTest1,
	(SUBSTRING(@ProductTest, 1, 1)) AS Product1,
	(ASCII(SUBSTRING(Product, 1, 1))) AS ProductTest1a,
	(ASCII(SUBSTRING(@ProductTest, 1, 1))) AS Product1a,
	(ASCII(SUBSTRING(Product, 1, 1)) - ASCII(SUBSTRING(@ProductTest, 1, 1))) AS ProductTest
FROM Sales

EXEC sp_set_session_context @key = N'AppUsername', @value = 'SalesUser1'
GO

-- Thank the query optimizer for providing the information protected by RLS 

-- Does SalesUser2 have any rows with Qty=4?
DECLARE @QtyTest int = 3
SELECT * FROM Sales
WHERE
	SalesUsername = 'SalesUser2'
	AND 0 / (Qty - @QtyTest) = 0
GO

-- Does SalesUser2 have Product=Lamp?
DECLARE @ProductTest varchar(max) = 'Clamp'
SELECT * FROM Sales
WHERE
	SalesUsername = 'SalesUser2'
	AND Product = @ProductTest
	AND 0 / (ASCII(SUBSTRING(Product, 1, 1)) - ASCII(SUBSTRING(@ProductTest, 1, 1))) = 0
GO

REVERT



-- Cleanup
REVERT
GO

DROP SECURITY POLICY IF EXISTS sec.SalesUserPolicy
DROP FUNCTION IF EXISTS sec.SalesUserPredicate
DROP SCHEMA IF EXISTS sec
DROP USER IF EXISTS AppUser
DROP LOGIN AppLogin
DROP TABLE IF EXISTS Sales
