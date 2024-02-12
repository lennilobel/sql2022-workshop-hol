### LAB: Setup

#### Goal:
The goal of this lab is to set up the necessary tables and views for performing subsequent SQL queries.

#### Steps:
1. Create tables `SalesUser`, `Customer`, and `SalesOrder`.
2. Populate the tables with sample data.
3. Create a view named `SalesOrderView` that retrieves information from the `SalesOrder`, `SalesUser`, and `Customer` tables.

```sql
USE HolDb
GO

CREATE TABLE SalesUser(
    SalesUserId int IDENTITY,
    Username varchar(50),
    FirstName varchar(50),
    LastName varchar(50),
    Phone varchar(12),
    Email varchar(100),
    DateOfBirth date,
    CONSTRAINT PK_SalesUser PRIMARY KEY (SalesUserId)
)

SET IDENTITY_INSERT SalesUser ON
INSERT INTO SalesUser (SalesUserId, Username, FirstName, LastName, Phone, Email, DateOfBirth) VALUES 
 (1, 'jadams', 'Jay', 'Adams', '473-555-0117', 'jay.adams@corp.com', DATEFROMPARTS(1986, 6, 13)),
 (2, 'jgalvin', 'Janice', 'Galvin', '465-555-0156', 'janice.galvin@corp.com.co', DATEFROMPARTS(1964, 8, 30)),
 (3, 'dmu', 'Dan', 'Mu', '970-555-0138', 'dan.mu@corp.net', DATEFROMPARTS(1969, 9, 26)),
 (4, 'jsmith', 'Jane', 'Smith', '913-555-0172', 'jane.smith@hotmail.com', DATEFROMPARTS(1989, 3, 13)),
 (5, 'djones', 'Danny', 'Jones', '150-555-0189', 'danny.jones@hotmail.com', DATEFROMPARTS(1992, 5, 27))
SET IDENTITY_INSERT SalesUser OFF

CREATE TABLE Customer(
    CustomerId int IDENTITY,
    FirstName varchar(50),
    LastName varchar(50),
    Phone varchar(12),
    Email varchar(100),
    SocialSecurityNumber varchar(11),
    Balance money,
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
)

SET IDENTITY_INSERT Customer ON
INSERT INTO Customer (CustomerId, FirstName, LastName, Phone, Email, SocialSecurityNumber, Balance) VALUES
 (1, 'Ken', 'Sanchez', '697-555-0142', 'ksanchez@hotmail.com', '068453678', 327.5),
 (2, 'Terri', 'Duffy', '819-555-0175', 'tduff@gmail.com', '257001369', 102.95),
 (3, 'Gail', 'Erickson', '212-555-0187', 'gerickson@outlook.com', '981554877', 811.41),
 (4, 'Jossef', 'Goldberg', '612-555-0100', 'jgoldberg@hotmail.com', '068453678', 0),
 (5, 'Dylan', 'Miller', '849-555-0139', 'dmiller@gmail.com', '257001369', 24.95),
 (6, 'Diane', 'Margheim', '122-555-0189', 'dmargheim@outlook.com', '981554877', 896.6),
 (7, 'Gigi', 'Matthew', '181-555-0156', 'gmatthew@hotmail.com', '068453678', 30),
 (8, 'Michael', 'Raheem', '815-555-0138', 'mraheem@gmail.com', '257001369', 35.36),
 (9, 'Sharon', 'Salavaria', '185-555-0186', 'ssalavaria@outlook.com', '981554877', 93.1),
 (10, 'Kevin', 'Brown', '330-555-2568', 'kbrown@hotmail.com', '068453678', 45.6),
 (11, 'Mary', 'Dempsey', '719-555-0181', 'mdempsey@gmail.com', '257001369', 100),
 (12, 'Jill', 'Williams', '168-555-0183', 'jwilliams@outlook.com', '981554877', 1102.6)
SET IDENTITY_INSERT Customer OFF

CREATE TABLE SalesOrder(
    SalesOrderId int IDENTITY,
    SalesUserId int,
    CustomerId int,
    Product varchar(10),
    Qty int,
    CreatedAt datetime2 CONSTRAINT DF_SalesOrder_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_SalesOrder PRIMARY KEY (SalesOrderId),
    CONSTRAINT FK_SalesOrder_SalesUser FOREIGN KEY (SalesUserId) REFERENCES SalesUser(SalesUserId),
    CONSTRAINT FK_SalesOrder_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(CustomerId)
)

SET IDENTITY_INSERT SalesOrder ON
INSERT INTO SalesOrder

 (SalesOrderId, SalesUserId, CustomerId, Product, Qty, CreatedAt) VALUES
 (1, 1, 2, 'Axe', 2, '2022-01-01 10:05:00'),
 (2, 2, 3, 'Hammer', 5, '2022-01-02 09:15:00'),
 (3, 3, 4, 'Saw', 1, '2022-01-03 08:25:00'),
 (4, 4, 5, 'Drill', 3, '2022-01-04 12:45:00'),
 (5, 5, 6, 'Wrench', 2, '2022-01-05 14:35:00'),
 (6, 1, 7, 'Pliers', 1, '2022-01-06 13:25:00'),
 (7, 2, 8, 'Screwdriver', 3, '2022-01-07 11:15:00'),
 (8, 3, 9, 'Screwdriver', 2, '2022-01-08 10:05:00'),
 (9, 4, 10, 'Wrench', 4, '2022-01-09 09:55:00'),
 (10, 5, 11, 'Pliers', 1, '2022-01-10 08:45:00'),
 (11, 1, 12, 'Drill', 2, '2022-01-11 07:35:00'),
 (12, 2, 2, 'Saw', 1, '2022-01-12 06:25:00'),
 (13, 3, 3, 'Wrench', 3, '2022-01-13 05:15:00'),
 (14, 4, 4, 'Screwdriver', 1, '2022-01-14 04:05:00'),
 (15, 5, 5, 'Hammer', 2, '2022-01-15 03:55:00')
SET IDENTITY_INSERT SalesOrder OFF

-- Creating the view SalesOrderView
CREATE VIEW SalesOrderView AS
SELECT 
    so.SalesOrderId,
    su.Username AS SalesUsername,
    su.FirstName AS SalesFirstName,
    su.LastName AS SalesLastName,
    su.Phone AS SalesPhone,
    su.Email AS SalesEmail,
    su.DateOfBirth AS SalesDateOfBirth,
    c.FirstName AS CustomerFirstName,
    c.LastName AS CustomerLastName,
    c.Phone AS CustomerPhone,
    c.Email AS CustomerEmail,
    c.SocialSecurityNumber AS CustomerSSN,
    c.Balance AS CustomerBalance,
    so.Product,
    so.Qty,
    so.CreatedAt
FROM 
    SalesOrder so
INNER JOIN 
    SalesUser su ON so.SalesUserId = su.SalesUserId
INNER JOIN 
    Customer c ON so.CustomerId = c.CustomerId
```
