## Temporal Tables

**Creating a Temporal Table with a Custom History Table Name in SQL Server**

Temporal tables, introduced in SQL Server 2016, enable SQL Server to automatically manage historical data. These tables include two specifically defined columns, the `ValidFrom` and `ValidTo` fields, which SQL Server populates to track when each row is valid in time. This feature is particularly useful for maintaining an auditable history of data changes over time.

In this demonstration, we will create a new temporal table named `Employee` and define a custom history table called `EmployeeHistory`. The `WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))` clause specifies that system versioning is enabled for the table and designates `EmployeeHistory` as the history table.

### Creating the Temporal Table

```sql
CREATE TABLE Employee
(
    EmployeeId      int PRIMARY KEY,
    FirstName       varchar(20) NOT NULL,
    LastName        varchar(20) NOT NULL,
    DepartmentName  varchar(50) NOT NULL,
    ValidFrom       datetime2 GENERATED ALWAYS AS ROW START NOT NULL, 
    ValidTo         datetime2 GENERATED ALWAYS AS ROW END NOT NULL,   
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))
GO
```

In this code, the `PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)` clause identifies the `ValidFrom` and `ValidTo` columns as special columns used by SQL Server to manage the row's validity period. The `SYSTEM_VERSIONING = ON` option enables versioning for the table, with changes being tracked in the specified history table `EmployeeHistory`.

### Discovering Temporal and History Tables

To view the temporal table and its associated history table, you can query the `sys.tables` system view:

```sql
SELECT
    object_id,
    name,
    temporal_type,
    temporal_type_desc,
    history_table_id
FROM
    sys.tables
WHERE
    object_id = OBJECT_ID('dbo.Employee', 'U') OR
    object_id = ( 
        SELECT history_table_id 
        FROM sys.tables
        WHERE object_id = OBJECT_ID('dbo.Employee', 'U')
)
GO
```

This query returns information about the temporal table and its history table, including the `object_id` and the `name` of each table, as well as their `temporal_type_desc` which indicates whether the table is a history table or the current table.

### Cleanup

To clean up and remove the temporal table and its history table, it's necessary to first "decouple" them by turning off system versioning:

```sql
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
DROP TABLE Employee
DROP TABLE EmployeeHistory
GO
```

The `ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)` statement disables system versioning for the `Employee` table, effectively decoupling it from its history table. This allows both the current and history tables to be treated as ordinary (non-temporal) tables, making it possible to delete them. This step is required because direct deletion of a system-versioned temporal table without first disabling system versioning would result in an error.



### Convert an Existing Table to Temporal


In this demonstration, we start by creating and populating the `Employee` table with initial employee records. This step is foundational for transforming the existing table into a temporal table later on. It's important to note that at this stage, the table is an ordinary table, and SQL Server is not tracking changes. Therefore, there is no previous change history recorded for these employees.

#### Step 1: Create and Populate the Employee Table

```sql
CREATE TABLE Employee
(
    EmployeeId      int PRIMARY KEY,
    FirstName       varchar(20) NOT NULL,
    LastName        varchar(20) NOT NULL,
    DepartmentName  varchar(50) NOT NULL
)
GO

INSERT INTO Employee VALUES
 (1, 'Ken',     'Sanchez',       'Executive'),
 (2, 'Terri',   'Duffy',         'Engineering'),
 (3, 'Roberto', 'Tamburello',    'Engineering'),
 (4, 'Rob',     'Walters',       'Engineering'),
 (5, 'Gail',    'Erickson',      'Engineering'),
 (6, 'Jossef',  'Goldberg',      'Engineering')
GO

SELECT * FROM Employee
```

This step focuses on establishing the `Employee` table and inserting six records into it. These records represent the employees at their current state. Given that the table is not yet a temporal table, any changes made to the employee records up to this point have not been recorded, meaning there is no historical data available for these records. This absence of historical data will change once we convert this table into a temporal table, allowing us to track all future modifications to the employee records.

#### Step 1: Execute two ALTER TABLE Statements





When converting an existing table to a temporal table, specific steps must be followed to adhere to SQL Server's requirements for temporal tables. The process involves adding system-time period columns and enabling system versioning. Here's how it's done:

1. **Adding System-Time Period Columns**: Temporal tables require two datetime2 columns to record the row's valid time period. These columns are added to the existing table with default constraints. Since the table already contains rows, a default value must be provided for these new columns. In this context, the `ValidFrom` column is set to the earliest possible time (`1900-01-01 00:00:00.0000000`), and the `ValidTo` column is set to the latest possible time (`9999-12-31 23:59:59.9999999`). These extremes represent the valid period for the existing rows from the beginning to the end of time, essentially marking them as always valid until a change occurs.

```sql
ALTER TABLE Employee ADD
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT CAST('1900-01-01 00:00:00.0000000' AS datetime2),
    ValidTo   datetime2 GENERATED ALWAYS AS ROW END   NOT NULL DEFAULT CAST('9999-12-31 23:59:59.9999999' AS datetime2),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
GO
```

2. **Enabling System Versioning**: The next step involves enabling system versioning on the table, which turns it into a temporal table. This action automatically creates a history table (in this case, `dbo.EmployeeHistory`) with an identical schema to store the historical data. The history table's name can be specified explicitly. This step requires the table to have a primary key and defined system-time period columns.

```sql
ALTER TABLE Employee 
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.EmployeeHistory))
GO
```

At this point, the history table (`EmployeeHistory`) starts out empty because no changes have been made to the `Employee` table yet. Here are two queries to demonstrate this:

```sql
-- Show current state of the Employee table
SELECT * FROM Employee

-- Show that the EmployeeHistory table is initially empty
SELECT * FROM EmployeeHistory
```

These steps illustrate how SQL Server facilitates the transformation of a standard table into a temporal one, allowing for the automatic tracking of historical data changes without loss of existing data.





### Tracking History in Temporal Tables

In this demo, we explore how temporal tables track changes over time by updating and deleting records from an existing temporal table, and then examining the generated history. Temporal tables maintain a history of data changes in a separate history table, enabling us to view data as it existed at any point in time.

Here's the SQL code that simulates updates and deletions:

```sql
-- Update employee ID 5 three times (change the FirstName, then change the DepartmentName twice, two seconds apart)
UPDATE Employee SET FirstName = 'Gabriel' WHERE EmployeeId = 5
WAITFOR DELAY '00:00:02'
UPDATE Employee SET DepartmentName = 'Support' WHERE EmployeeId = 5
WAITFOR DELAY '00:00:02'
UPDATE Employee SET DepartmentName = 'Executive' WHERE EmployeeId = 5
WAITFOR DELAY '00:00:02'
-- Now delete employee ID 2
DELETE Employee WHERE EmployeeId = 2
GO

-- History table shows the changes
SELECT * FROM Employee
SELECT * FROM EmployeeHistory ORDER BY EmployeeId, ValidFrom
GO
```

In the history table, we observe the following for Employee ID 5:

- Three previous versions of the employee record are preserved, each reflecting the changes made with each update statement. These versions showcase changes to both the `FirstName` and `DepartmentName` attributes.
- The `ValidFrom` and `ValidTo` columns demarcate the exact time frame for which each version of the record was valid. Importantly, these time frames align seamlessly, ensuring there are no gaps or overlaps between consecutive versions. This seamless alignment is critical for accurately representing the history of data changes.
- The deleted record for Employee ID 2 is also preserved in the history table. This ensures that even though the record has been removed from the current table, its existence and the period it was valid for are still traceable in the history table.

This demonstrates the power of temporal tables in SQL Server 2022 for maintaining comprehensive historical records of data changes, allowing for accurate back-in-time queries and audits.

Now let's cleanup once more, and delete the Employee table along with the history table.


```sql
-- Disable SYSTEM_VERSIONING before cleanup
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
GO

-- Cleanup: drop the tables
DROP TABLE Employee
DROP TABLE EmployeeHistory
GO
```

Remember, disabling `SYSTEM_VERSIONING` decouples the temporal table from its history table, allowing you to manage them as separate, ordinary tables. This step is crucial before deleting temporal tables and their associated history tables, as SQL Server enforces the relationship between them while `SYSTEM_VERSIONING` is enabled.





### Pre-populating Temporal History

This demonstration showcases the transformation of ordinary tables into a temporal system, uniquely pre-populating the history with time-spaced changes for a more realistic temporal table functionality.

First, we establish two standard tables:

- **Employee**: Acts as the current state table.
- **EmployeeHistory**: Serves as the historical changes record.

```sql
CREATE TABLE Employee
(
    EmployeeId      int PRIMARY KEY,
    FirstName       varchar(20) NOT NULL,
    LastName        varchar(20) NOT NULL,
    DepartmentName  varchar(50) NOT NULL,
    ValidFrom       datetime2 NOT NULL, 
    ValidTo         datetime2 NOT NULL
)

CREATE TABLE EmployeeHistory
(
    EmployeeId      int NOT NULL,
    FirstName       varchar(20) NOT NULL,
    LastName        varchar(20) NOT NULL,
    DepartmentName  varchar(50) NOT NULL,
    ValidFrom       datetime2 NOT NULL, 
    ValidTo         datetime2 NOT NULL
)
```

Both tables are then populated:

```sql
INSERT INTO Employee VALUES
 (1, 'Ken',        'Sanchez',       'Executive',    '2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (3, 'Roberto',    'Tamburello',    'Engineering',  '2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (4, 'Rob',        'Walters',       'Engineering',  '2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999'),
 (5, 'Gabriel',    'Erickson',      'Executive',    '2018-12-03 09:00:00', '9999-12-31 23:59:59.9999999'),
 (6, 'Jossef',     'Goldberg',      'Engineering',  '2018-10-07 08:33:00', '9999-12-31 23:59:59.9999999')

INSERT INTO EmployeeHistory VALUES
 (2, 'Terri',      'Duffy',         'Engineering',  '2018-10-07 08:33:00', '2018-11-16 00:00:00'),  -- deleted 11/16
 (5, 'Gabriel',    'Erickson',      'Support',      '2018-11-18 04:26:00', '2018-12-03 09:00:00'),
 (5, 'Gabriel',    'Erickson',      'Engineering',  '2018-11-01 11:59:00', '2018-11-18 04:26:00'),
 (5, 'Gail',       'Erickson',      'Engineering',  '2018-10-07 08:33:00', '2018-11-01 11:59:00')
```

Noticeably, Employee ID 2 is absent from the **Employee** table because it was deleted, and its record exists only within the **EmployeeHistory** table, marking its removal from the active data set.

Conversion to a temporal table is then performed:

```sql
ALTER TABLE Employee
 ADD PERIOD FOR SYSTEM_TIME (ValidFrom,ValidTo)

ALTER TABLE Employee SET (SYSTEM_VERSIONING = ON (
    HISTORY_TABLE = dbo.EmployeeHistory,
    DATA_CONSISTENCY_CHECK = ON)
)
```

Subsequent examination shows the **Employee** table reflecting the current data state, while **EmployeeHistory** encapsulates the comprehensive change history:

```sql
-- History table shows the changes
SELECT * FROM Employee
SELECT * FROM EmployeeHistory ORDER BY EmployeeId, ValidFrom
```

This detailed process underscores SQL Server's potent temporal table capabilities, ensuring each data record's life span is meticulously recorded. Through period columns `ValidFrom` and `ValidTo`, SQL Server affords a robust framework for managing and analyzing data changes over extended durations, highlighting its strengths in maintaining historical data integrity and traceability.





### Running Point-In-Time Queries

Temporal queries in SQL Server enable us to navigate through time, showcasing a table's state at various historical points. These queries can be particularly insightful for auditing, data recovery, and historical analysis. Here's a breakdown of each query and its implications:

1. **Current Data Query**:
   - Retrieves the present state of the **Employee** table, showing current entries.
   ```sql
   SELECT * FROM Employee ORDER BY EmployeeId
   ```
   This displays the latest information, such as "Gabriel Erickson" in the "Executive" department.

2. **Point-in-Time Query as of December 1, 2018**:
   - Fetches data as it existed on December 1, 2018, by merging current and historical data to reflect the table's state at that point.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-12-01' ORDER BY EmployeeId
   ```
   This reveals "Gabriel Erickson" in the "Support" department, showcasing the department change before the latest update.

3. **Point-in-Time Query as of November 15, 2018**:
   - Retrieves the table's state on November 15, 2018, including previously deleted or updated records.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-15' ORDER BY EmployeeId
   ```
   At this time, "Gabriel Erickson" was in "Engineering", and "Terri Duffy" (Employee ID 2) is still present, having been deleted after this date.

4. **Point-in-Time Query as of October 10, 2018**:
   - Shows the table's state on October 10, 2018, revealing earlier states of current records.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-10-10' ORDER BY EmployeeId
   ```
   This query unveils "Gail Erickson" in "Engineering", indicating the initial name and department before subsequent changes.

5. **Point-in-Time Query as of October 1, 2018**:
   - Attempts to access the table's state before any records were entered.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-10-01' ORDER BY EmployeeId
   ```
   Results in no data, signifying that the table was empty or the records had not yet been created.

Each query uses `FOR SYSTEM_TIME AS OF` to perform a temporal query, which SQL Server executes by combining the current table with its history table. This mechanism allows for an integrated view of the data at specified historical points, effectively making the database a time machine. By specifying different dates, we can observe the evolution of data, including updates, deletions, and the initial state before any modifications. This capability is invaluable for applications requiring an audit trail, historical data analysis, or undoing unintended changes.




### Matching on Exact Point-In-Time Boundaries

This demo delves into the behavior of temporal queries when the specified point in time (`AS OF`) exactly matches the boundary between two historical states of a row. Here's how SQL Server processes these temporal queries, particularly focusing on the `ValidFrom` and `ValidTo` timestamps:

1. **Identifying Boundary Cases**:
   - First, we examine the history table to identify rows with `ValidFrom` or `ValidTo` timestamps that precisely match a boundary condition. In this case, we're looking at '2018-11-18 04:26:00'.
   ```sql
   SELECT * FROM EmployeeHistory WHERE ValidFrom = '2018-11-18 04:26:00' OR ValidTo = '2018-11-18 04:26:00' ORDER BY EmployeeId, ValidFrom
   ```
   This query finds two rows in the history table for Employee ID 5, where one row ends and another begins at the exact time of '2018-11-18 04:26:00'.

2. **Querying at the Boundary Time**:
   - Running a point-in-time query exactly at the boundary (`'2018-11-18 04:26:00'`) demonstrates that SQL Server matches on the `ValidFrom` time, not `ValidTo`.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:26:00' ORDER BY EmployeeId
   ```
   The result is the version of Employee ID 5 with the department name "Support", indicating the state of the data as it became valid exactly at '2018-11-18 04:26:00'.

3. **Querying Just Before the Boundary**:
   - Adjusting the point-in-time query to one second before the boundary (`'2018-11-18 04:25:59'`) retrieves the earlier version of the data.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME AS OF '2018-11-18 04:25:59' ORDER BY EmployeeId
   ```
   This time, the query returns the earlier version of Employee ID 5, where the department name was "Engineering". This version was valid up until '2018-11-18 04:26:00', illustrating the inclusive nature of `ValidFrom` and the exclusive nature of `ValidTo`.

These demonstrations clarify that the `FOR SYSTEM_TIME AS OF` temporal query condition inclusively matches rows based on the `ValidFrom` timestamp. When a query's specified point in time aligns exactly with the boundary between two historical states of a row, SQL Server opts to return the row that just became valid at that timestamp, effectively favoring `ValidFrom` over `ValidTo`. This behavior ensures precise and predictable outcomes when exploring data history, particularly at the precise moments of transition between historical states.





### FROM vs. BETWEEN

Exploring temporal tables in SQL Server further, we delve into the nuances between using `FOR SYSTEM_TIME FROM A TO B` versus `FOR SYSTEM_TIME BETWEEN A AND B`. These clauses are integral for querying historical data within a specified time range, offering insights into data's evolution over time. Specifically, we'll examine their behavior with respect to exact boundary matches using Employee ID 5 as our focus.

1. **Equivalent Queries with FROM and BETWEEN**:
   When querying without hitting the exact boundary of `ValidFrom`, both `FROM ... TO` and `BETWEEN ... AND` return identical results.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME FROM    '2018-11-02' TO  '2018-12-03 08:59:59' WHERE EmployeeId = 5
   SELECT * FROM Employee FOR SYSTEM_TIME BETWEEN '2018-11-02' AND '2018-12-03 08:59:59' WHERE EmployeeId = 5
   ```
   These queries retrieve versions of Employee ID 5 valid at any time between November 2, 2018, and one second before December 3, 2018, 09:00:00.

2. **Behavior Difference on Exact Boundary**:
   When the upper bound of the time range exactly matches a `ValidFrom` value, `FOR SYSTEM_TIME BETWEEN` includes an additional row that represents the state of the data at the boundary.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME FROM    '2018-11-02' TO  '2018-12-03 09:00:00' WHERE EmployeeId = 5
   SELECT * FROM Employee FOR SYSTEM_TIME BETWEEN '2018-11-02' AND '2018-12-03 09:00:00' WHERE EmployeeId = 5
   ```
   The first query, using `FROM ... TO`, does not include the version of Employee ID 5 that became valid exactly at '2018-12-03 09:00:00'. In contrast, the second query, using `BETWEEN`, includes this version, demonstrating `BETWEEN`'s inclusivity of the upper boundary.

This distinction is pivotal for scenarios requiring precision in temporal data analysis. While both clauses offer powerful means to explore historical data, understanding their differences ensures the accuracy of temporal queries, especially when boundary conditions are of interest. The `BETWEEN` clause's inclusivity on the upper boundary can be particularly useful when it's essential to capture every possible change within the specified range, including the exact start of a new version.




### CONTAINED IN

In SQL Server's exploration of temporal tables, the `FOR SYSTEM_TIME CONTAINED IN (A, B)` clause introduces a nuanced approach to querying historical data, distinct from the `FOR SYSTEM_TIME FROM A TO B` syntax. This difference hinges on the inclusivity of the specified time boundaries A and B, affecting the rows returned based on their period of validity within the temporal table. Here, we focus on Employee ID 5 to illustrate these nuances.

1. **FOR SYSTEM_TIME FROM A TO B**:
   This query returns rows if their valid period overlaps with any part of the time range specified by A and B. It includes rows where either `ValidFrom` or `ValidTo` falls within the specified range, thus capturing rows that partially overlap with the time frame.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME FROM '2018-11-02' TO '2018-12-04' WHERE EmployeeId = 5
   ```
   This retrieves all versions of Employee ID 5 that have any part of their valid period within November 2, 2018, to December 4, 2018.

2. **FOR SYSTEM_TIME CONTAINED IN (A, B)**:
   Contrary to `FROM A TO B`, the `CONTAINED IN (A, B)` variant returns rows only if their entire valid period is within the time boundaries A and B. This means both `ValidFrom` and `ValidTo` must fall within the specified range for a row to be included.
   ```sql
   SELECT * FROM Employee FOR SYSTEM_TIME CONTAINED IN ('2018-11-02', '2018-12-04') WHERE EmployeeId = 5
   ```
   This query will return versions of Employee ID 5 where the entire valid period is encompassed between November 2, 2018, and December 4, 2018, excluding any versions that only partially overlap with this range.

The `CONTAINED IN` clause is particularly useful when the requirement is to isolate records that existed entirely within a specific timeframe, without including records that were valid only partially within that range. This is critical for analyses focused on data states that were consistently present through an entire period, offering a more stringent criterion than `FROM A TO B`, which accommodates any degree of overlap with the specified timeframe.







### Schema Changes

Schema changes within SQL Server temporal tables, especially the addition or deletion of columns, illustrate the seamless synchronization between the primary table and its history table. This synchronization ensures the history table mirrors the schema of the primary table, preserving the integrity and consistency of temporal queries over time. This example demonstrates how adding or removing a column from the primary table (`Employee`) is automatically replicated in the history table (`EmployeeHistory`), under normal circumstances.

1. **Adding a Column:**
   When a new column, `RegionID`, is added to the `Employee` table, SQL Server automatically updates the `EmployeeHistory` table to include this new column. This action maintains schema consistency across the primary and history tables, enabling the history table to continue capturing the complete state of each row over time, including the newly added column.
   ```sql
   -- Add a column (gets added to history table automatically)
   ALTER TABLE Employee ADD RegionID int NULL
   
   SELECT * FROM Employee
   SELECT * FROM EmployeeHistory
   ```

2. **Deleting a Column:**
   Similarly, when the `RegionID` column is removed from the `Employee` table, SQL Server ensures the column is also dropped from the `EmployeeHistory` table. This synchronization prevents schema mismatches that could complicate temporal queries and analyses. By automatically applying schema changes made to the primary table to the history table, SQL Server simplifies the management of temporal tables.
   ```sql
   -- Drop a column (gets dropped from history table automatically)
   ALTER TABLE Employee DROP COLUMN RegionID
   
   SELECT * FROM Employee
   SELECT * FROM EmployeeHistory
   ```

It's important to note the exceptions to this automatic synchronization. Certain column types, such as IDENTITY and computed columns, cannot be directly added to the history table due to their nature. For these cases, the system versioning must be temporarily disabled, changes applied manually to both tables to ensure consistency, and then system versioning re-enabled. This process ensures both tables maintain equivalent schemas, except for the necessary deviations, and continues to support the temporal querying capabilities of SQL Server.








### Hidden Period Columns

The concept of hidden period columns in SQL Server's temporal tables is a nuanced feature designed to maintain the cleanliness of query results while still providing access to crucial temporal data when needed. When defining a temporal table, specifying period columns as `HIDDEN` instructs SQL Server to exclude these columns from the results of a `SELECT *` query. This ensures that queries return only the business data without the system-managed temporal information, keeping the results succinct and focused. However, these hidden columns remain accessible and can be explicitly included in a `SELECT` statement, offering flexibility based on the query's requirements.

In the provided demo, we first create an `Employee2` table with `ValidFrom` and `ValidTo` period columns marked as `HIDDEN`. This table is system-versioned, indicating it's a temporal table with an associated history table named `Employee2History`.

```sql
-- Create and populate a system-versioned table with hidden period columns
CREATE TABLE Employee2(
    EmployeeId int PRIMARY KEY,
    FirstName varchar(20) NOT NULL,
    LastName varchar(20) NOT NULL,
    DepartmentName varchar(50) NOT NULL,
    ValidFrom datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo   datetime2 GENERATED ALWAYS AS ROW END HIDDEN   NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Employee2History))
```

After populating the table with sample data:

```sql
INSERT INTO Employee2 (EmployeeId, FirstName, LastName, DepartmentName) VALUES
 (1, 'Ken', 'Sanchez', 'Executive'),
 (2, 'Terri', 'Duffy', 'Engineering'),
 (3, 'Roberto', 'Tamburello', 'Engineering')
```

A `SELECT *` query on `Employee2` will return all columns except for `ValidFrom` and `ValidTo`:

```sql
-- Hidden period columns are not returned with SELECT *
SELECT * FROM Employee2
```

To retrieve these period columns, they must be explicitly specified in the `SELECT` statement:

```sql
-- Hidden period columns can be returned explicitly
SELECT EmployeeId, LastName, ValidFrom, ValidTo FROM Employee2
```

This approach allows for the streamlined presentation of data by default, with the option to delve into the temporal specifics as needed, ensuring that the temporal framework operates seamlessly in the background without cluttering query results, unless specifically requested.



### Cleanup

To clean up and remove the temporal tables created during the previous demos, it's necessary to first disable system versioning for each table. This step decouples the primary table from its associated history table, allowing both to be treated as standard, non-temporal tables. Once system versioning is turned off, both the primary table and its history table can be deleted without any constraints imposed by the temporal setup.

Here’s how to properly clean up the `Employee2` table, followed by the `Employee` table:

1. Disable system versioning on the `Employee2` table:

```sql
ALTER TABLE Employee2 SET (SYSTEM_VERSIONING = OFF)
```

2. Delete the `Employee2` table and its history table:

```sql
DROP TABLE Employee2
DROP TABLE Employee2History
```

3. Disable system versioning on the `Employee` table:

```sql
ALTER TABLE Employee SET (SYSTEM_VERSIONING = OFF)
```

4. Delete the `Employee` table and its history table:

```sql
DROP TABLE Employee
DROP TABLE EmployeeHistory
```

By following these steps, you remove the temporal tables and their history tables, ensuring a clean environment. This cleanup process highlights the importance of disabling system versioning before attempting to delete a temporal table, ensuring the integrity and manageability of the database schema.
