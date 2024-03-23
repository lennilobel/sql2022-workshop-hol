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
Let's create a comprehensive guide for these examples.

---

### DATE_BUCKET Function Exploration

SQL Server 2022 introduces the `DATE_BUCKET` function, enhancing the way we can aggregate and analyze data over time. Below, we'll explore how to use this function to create various day-level buckets.

#### Two-day Bucket

**Objective:** Group data into two-day intervals, starting from a specified "origin" date. This approach helps in analyzing data trends over every two days.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-01'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-02'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-03'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-04'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-05'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-06'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-07'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-08'), @Origin);
GO
```
**Insight:** This code demonstrates grouping dates into two-day buckets. The bucket number alternates between '1/2d' and '2/2d', indicating the division of days into two-day periods based on the provided origin date.

#### Adjusting the Origin Date

**Objective:** Understand the impact of changing the origin date on the bucketing outcome.

```sql
DECLARE @Origin date = '2021-12-31';
SELECT
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-01'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-02'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-03'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-04'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-05'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-06'), @Origin),
    '2/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-07'), @Origin),
    '1/2d' = DATE_BUCKET(DAY, 2, CONVERT(date, '2022-01-08'), @Origin);
GO
```
**Insight:** Shifting the origin date backwards by a day changes how dates are allocated into two-day buckets. This flexibility allows for tailored data analysis based on the starting point of the bucketing interval.

#### Three-day Bucket

**Objective:** Extend the bucketing concept to three-day intervals for more extensive data aggregation.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    '1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-01'), @Origin),
    '2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-02'), @Origin),
    '3/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-03'), @Origin),
    '1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-04'), @Origin),
    '2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-05'), @Origin),
    '3/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-06'), @Origin),
    '1/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-07'), @Origin),
    '2/3d' = DATE_BUCKET(DAY, 3, CONVERT(date, '2022-01-08'), @Origin);
GO
```
**Insight:** By grouping dates into three-day intervals, we can observe patterns or trends over slightly longer periods, providing a broader analysis window than daily or two-day buckets. This method could be particularly useful for datasets where changes occur over several days rather than from one day to the next.

#### Four-day Bucket

**Objective:** Further explore the flexibility of `DATE_BUCKET` by creating four-day intervals, offering an even wider lens for data aggregation and analysis.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    '1/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-01'), @Origin),
    '2/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-02'), @Origin),
    '3/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-03'), @Origin),
    '4/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-04'), @Origin),
    '1/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-05'), @Origin),
    '2/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-06'), @Origin),
    '3/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-07'), @Origin),
    '4/4d' = DATE_BUCKET(DAY, 4, CONVERT(date, '2022-01-08'), @Origin);
GO
```

**Insight:** This setup demonstrates how to segment data into four-day buckets, showcasing `DATE_BUCKET`'s utility in grouping dates over various intervals. It's particularly helpful for analyzing data trends that unfold over an extended period, providing a comprehensive view of week-long trends or activities.

By utilizing the `DATE_BUCKET` function across different day-level intervals, we gain a powerful tool for temporal data analysis, allowing us to customize our approach based on the specific needs of the analysis or the inherent patterns within the data.

Let's continue with this approach if you have more specific intervals or examples you'd like to explore.

Let's continue with the detailed breakdown, starting with the one-week bucket example and moving through to the three-month bucket example.

---

#### One-week Bucket

**Objective:** Understand how to group dates into one-week intervals, demonstrating the use of `DATE_BUCKET` for weekly data analysis.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    '1/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-01'), @Origin),
    '2/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-02'), @Origin),
    '3/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-03'), @Origin),
    '4/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-04'), @Origin),
    '5/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-05'), @Origin),
    '6/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-06'), @Origin),
    '7/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-07'), @Origin),
    '1/1w' = DATE_BUCKET(WEEK, 1, CONVERT(date, '2022-01-08'), @Origin);
GO
```
**Insight:** This example showcases how `DATE_BUCKET` can effectively group dates by week, providing a clear way to analyze data on a weekly basis. The output demonstrates the assignment of each day to its respective week number relative to the `@Origin`.

#### One-month Bucket

**Objective:** Learn to group dates into one-month intervals using `DATE_BUCKET`, ideal for monthly data aggregation and trend analysis.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    'Jan/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-01-15'), @Origin),
    'Feb/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-02-20'), @Origin),
    'Mar/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-03-13'), @Origin),
    'Apr/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-04-01'), @Origin),
    'May/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-05-23'), @Origin),
    'Jun/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-06-30'), @Origin),
    'Jul/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-07-15'), @Origin),
    'Aug/1m' = DATE_BUCKET(MONTH, 1, CONVERT(date, '2022-08-30'), @Origin);
GO
```
**Insight:** This snippet demonstrates the utility of `DATE_BUCKET` in monthly data grouping. By specifying a month interval, it aligns each date within its respective month bucket, offering a streamlined approach for monthly reporting or analysis.

#### Three-month Bucket

**Objective:** Explore the capability of `DATE_BUCKET` to group dates into three-month (quarterly) intervals, aiding in quarterly data comparison and trend identification.

```sql
DECLARE @Origin date = '2022-01-01';
SELECT
    'Jan/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-01-15'), @Origin),
    'Feb/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-02-20'), @Origin),
    'Mar/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-03-13'), @Origin),
    'Apr/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-04-01'), @Origin),
    'May/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-05-23'), @Origin),
    'Jun/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-06-30'), @Origin),
    'Jul/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-07-15'), @Origin),
    'Aug/3m' = DATE_BUCKET(MONTH, 3, CONVERT(date, '2022-08-30'), @Origin);
GO
```
