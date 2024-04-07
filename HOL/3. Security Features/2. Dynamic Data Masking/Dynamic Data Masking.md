## Dynamic Data Masking

Start by pressing `CTRL+N` to open a new query window for this lab. Then switch to the AdventureWorks2019 database:

```sql
USE AdventureWorks2019
```

### Create the Membership Table

Let's start by creating a `Membership` table with various columns, each employing a different pre-defined DDM function to mask data:

```sql
-- Create table with a few masked columns
CREATE TABLE Membership(
    MemberId      int IDENTITY PRIMARY KEY,
    FirstName     varchar(100)  MASKED WITH (FUNCTION = 'partial(2, "...", 2)'),
    LastName      varchar(100),
    Phone         varchar(12)   MASKED WITH (FUNCTION = 'default()'),
    Email         varchar(100)  MASKED WITH (FUNCTION = 'email()'),
    DiscountCode  smallint      MASKED WITH (FUNCTION = 'random(1, 100)'))
```

1. **Partial Masking**: The `partial()` function reveals the first two and the last two characters of the `FirstName`, masking the middle part with dots. This function supports string data types only.

2. **Default Masking**: The `default()` function completely masks the `Phone` number. The term "default" may be somewhat misleading; "full" might have been a more descriptive name since it fully masks the value, unlike the `partial()` function which only partially masks values. This function supports every data type to hide the original data behind a generic mask.

3. **Email Masking**: The `email()` function is applied to the `Email` column. This function only reveals the first character and masks the rest as XXX@XXX.COM. In fact, this specific function is redundant, as the same effect can be achieved with the `partial()` function by specifying `partial(1, 'XXX@XXX.COM', 0)`. This makes the email function effectively useless, and highlights that there are practially only three distinctively useful masking functions.

4. **Random Masking**: The `random()` function generates a random number within a specified range for the `DiscountCode`. This function works with numeric data types only, and can be used as an alternative to using `default()`, which works with all data types and would always fully mask numbers as 0. Using `random()` also fully masks numbers but by generating random numbers within a range that might depict some real scenario (like the range of numbers 1 through 7 to indicate the day of the week, for example), thus providing more useful sample obfuscated data.

Note that while DDM provides these predefined functions, SQL Server does not allow the creation of custom masking functions, which somewhat limits the feature's flexibility.

### Discover Masked Columns

To explore the masked columns within the database and understand how data masking is applied to each, run the following query:

```sql
-- Discover all masked column in the database
SELECT
    t.name AS TableName,
    mc.name AS ColumnName,
    mc.masking_function AS MaskingFunction
FROM
    sys.masked_columns AS mc
    INNER JOIN sys.tables AS t ON mc.[object_id] = t.[object_id]
```

This query joins `sys.masked_columns` with `sys.tables` on each table's `object_id`, and allows us to view the table name, column name, and the specific masking function applied to each column.

### Populate the Table

Next, populate the `Membership` table with several rows of sample data:

```sql
INSERT INTO Membership
 (FirstName,  LastName,      Phone,           Email,                      DiscountCode) VALUES
 ('Roberto',  'Tamburello',  '555.123.4567',  'RTamburello@contoso.com',  10),
 ('Janice',   'Galvin',      '555.123.4568',  'JGalvin@contoso.com.co',   20),
 ('Dan',      'Mu',          '555.123.4569',  'ZMu@contoso.net',          30),
 ('Jane',     'Smith',       '454.222.5920',  'Jane.Smith@hotmail.com',   40),
 ('Danny',    'Jones',       '674.295.7950',  'Danny.Jones@hotmail.com',  50)
```

Now query the `Membership` table to view the sample data we just inserted:

```sql
SELECT * FROM Membership
```

The results fully reveal all the data, including the columns we designed as masked. This is because we are connected as user `dbo`, the special built-in user that is implicitly granted all permissions. Thus, we possess the `UNMASK` permission required to reveals masked columns.

Let's explore this further by testing with different users and permissions.

### Discover Users and Permissions

To aid our understanding of DDM in this lab, let's create a view named `vwShowUsers` that joins several security-related catalog views together to report each database user's name, the login name they're associated with, their login type, the state and name of their permissions, and (where applicable) the names of tables and columns those permissions apply to. The view's `WHERE` clause focuses on users 'dbo', 'RegularUser', and 'ContactUser', which we'll be experimenting with in this lab:

```sql
CREATE VIEW vwShowUsers AS
SELECT
    UserName        = pr.name,
    LoginName       = l.loginname,
    LoginType       = pr.type_desc,
    PermissionState = pe.state_desc,
    PermissionName  = pe.permission_name,
    PermissionClass = pe.class_desc,
    TableName       = o.name,
    ColumnName      = c.name
FROM
    sys.database_principals AS pr
    INNER JOIN sys.database_permissions AS pe ON pe.grantee_principal_id = pr.principal_id
    INNER JOIN sys.sysusers AS u ON u.uid = pr.principal_id
    LEFT OUTER JOIN sys.objects AS o ON o.object_id = pe.major_id
    LEFT OUTER JOIN sys.columns AS c ON c.object_id = pe.major_id AND c.column_id = pe.minor_id
    LEFT OUTER JOIN master..syslogins AS l ON u.sid = l.sid
WHERE
    pr.name in ('dbo', 'RegularUser', 'ContactUser')
```

This view will be instrumental in understanding how permissions are distributed among users within the database, particularly as it pertains to this lab.

Now query the view:

```sql
-- The currently connected login is mapped to user dbo, with full permissions implied, including UNMASK
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

From the results returned by this view, it becomes apparent that there is only one explicitly listed permission for the `dbo` user, which is the ability to connect to the database. However, as already mentioned, the `dbo` user inherently possesses all permissions within the database, and that of course includes the `UNMASK` permission. Thus, connected as the `dbo` user, we can see the actual data in columns that have been masked using Dynamic Data Masking (DDM), without the masking being applied.

### Create New User 'RegularUser'

So let's create a new "ordinary" user named `RegularUser`:

```sql
CREATE USER RegularUser WITHOUT LOGIN
```

And now, query the view again:

```sql
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

Now we see `RegularUser` that, like `dbo` has permission to connect to the database. But unlike `dbo`, this is the only permission that `RegularUser` possesses. Thus, `RegularUser` not only lacks the `UNMASK` permission, it is not even granted `SELECT` permission on the `Membership` table. And without that `SELECT` permission, this user can't even view unmasked data in the table.

So now, let's granting `SELECT` permissions on the `Membership` table to `RegularUser`, so that this user can query the table and view its contents. But we won't yet also grant this user the `UNMASK` permission, and so they will only see masked versions of the data in columns protected by Dynamic Data Masking (DDM):

```sql
GRANT SELECT ON Membership TO RegularUser
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```
And now the view reveals that `RegularUser` now has the ability to `SELECT` from the `Membership` table.

## Impersonating 'RegularUser'

By utilizing the `EXECUTE AS USER` command, we can temporarily impersonate the `RegularUser` within our current connection. This allows us to query the `Membership` table and observe how data masking affects the visibility of its data from the perspective of `RegularUser` instead of `dbo`. After running the query, we can use `REVERT` to return to our original `dbo` user context. This practice is particularly useful for testing how different users experience data access and visibility.

Here's the code snippet to do this:

```sql
EXECUTE AS USER = 'RegularUser'
SELECT * FROM Membership	-- DiscountCode is randomized each time
REVERT
```

**Key Observations in the Output:**
- **FirstName Field:** The `partial(2, "...", 2)` function is applied, revealing the first two and the last two characters for names longer than four characters. Names with four or fewer characters, such as "Dan" and "Jane", are fully masked to prevent revealing the entire first name.
- **Phone Column:** Completely masked with 'xxxx', consistent with the `default()` function, ensuring complete data obfuscation.
- **Email Addresses:** The `email()` function masks real email addresses by showing only the first character followed by XXX@XXXX.com, effectively masking the true email using a standardized placeholder.
- **DiscountCode Column:** Generates random numbers between 1 and 100 for each query execution, as specified by the `random(1, 100)` function. This results in varying, unpredictable numbers that mask the actual discount codes. Run the snippet multiple times to observe that different values are produced for the discount code each time, demonstrating the dynamic nature of this type of data masking.

### Granting and Revoking the UNMASK Permission

Now let's explicitly grant the `UNMASK` permission to `RegularUser`, and allow this user to see data in its unmasked form, just like the `dbo` user that is implicitly granted the `UNMASK` permission:

```sql
-- Let RegularUser see unmasked data
GRANT UNMASK TO RegularUser
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

Now the view reveals that `RegularUser` possesses both `SELECT` permission on the `Membership` table, as well as the database-wide `UNMASK` permission:

> Note that, typically, you would assign the `UNMASK` permission to a role rather than to each individual user. Then, every user added as a member of that role would inherit the `UNMASK` permission. We're only granting permission at the user level in this demo to keep things simple without detracting from the way Dynamic Data Masking (DDM) works.

By granting the `UNMASK` permission to `RegularUser`, they are now able to see all the data without the masking applied. Let's impersonate them once more to confirm that this is the case:

```sql
EXECUTE AS USER = 'RegularUser'
SELECT * FROM Membership
REVERT 
```

The output shows that masked data will is now revealed for `RegularUser`.

Let's now revoke the `UNMASK` permission from `RegularUser`, which effectively re-applies the masking functions to the data for `RegularUser`:

```sql
REVOKE UNMASK FROM RegularUser
EXECUTE AS USER = 'RegularUser'
SELECT * FROM Membership
REVERT 
```

Now when `RegularUser` queries the `Membership` table, the data once again appears masked according to the masking rules defined on the columns.

### Granular DDM Permissions (new in SQL Server 2022)

The granular DDM permissions feature introduced in SQL Server 2022 is a significant enhancement that addresses a major limitation in earlier versions. Previously, SQL Server allowed granting or revoking the `UNMASK` permission only as a database-wide permission. This meant that a user with the `UNMASK` permission can see the value of every masked column in every table in the database, and this behavior has significantly limited its flexibility and adoption.

But now, SQL Server 2022 offers this much-needed granularity. The `UNMASK` permission can now be granted or revoked at various levels, providing tailored access control that matches specific security requirements. 

Specifically, this granular control can be applied at the:

- **Database Level**: As before, affecting all masked columns across the entire database.
- **Schema Level**: Unmasks all tables within a specific schema.
- **Table Level**: Unmasks all columns within a specific table.
- **Column Level**: The most granular level, which unmasks individual columns within a table.

This flexibility greatly enhances the practical use of Dynamic Data Masking by allowing precise control over who can see unmasked data, ensuring that only authorized users can access sensitive information at the level of detail appropriate to their role or needs. Our next exercise demonstrates this important new capability:

Let's create another new user named `ContactUser`, who is tasked with reaching out to members. Thus, they'll need access to some columns that are normally masked, specifically the `FirstName`, `Phone`, and `Email` columns in the `Membership` table. However, they don't require access to the `DiscountCode`, which should remain masked. Run the following code to achieve this:

```sql
-- Create a new user called ContactUser with no login
CREATE USER ContactUser WITHOUT LOGIN

-- Grant SELECT permissions on the Membership table to ContactUser
GRANT SELECT ON Membership TO ContactUser

-- Grant UNMASK permission on specific columns to ContactUser
GRANT UNMASK ON Membership(FirstName) TO ContactUser
GRANT UNMASK ON Membership(Phone) TO ContactUser
GRANT UNMASK ON Membership(Email) TO ContactUser
```

Now query `vwShowUsers` once more to verify the permissions granted:

```sql
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

You can now see that `ContactUser` has the `UNMASK` permission for just the designated columns.

Now let's see what happens when `ContactUser` queries the `Membership` table, by running the following code snippet:

```sql
-- Impersonate ContactUser to query the Membership table
EXECUTE AS USER = 'ContactUser'
SELECT * FROM Membership
REVERT 
```

By executing the code above, you'll notice that `ContactUser` can view the `FirstName`, `Phone`, and `Email` columns without any masking, thanks to the granular `UNMASK` permissions that have been explicitly granted for these columns. However, the `DiscountCode` remains masked, with its values randomized between 1 and 100, demonstrating the effect of the `random()` masking function (run the code snippet multiple times to observe that the `DiscountCode` column is still masked while the other contact-related columns are revealed).

This behavior aligns perfectly with our intent for `ContactUser`, allowing them access to the necessary contact information while keeping other sensitive data, like discount codes, masked.

## Masking All Data Types

In this final DDM exercise, let's demonstrate DDM capabilities beyond the common string and number data types, we've been working with thus far:

```sql
CREATE TABLE MaskingSample(
    Label varchar(32) NOT NULL,
    -- "default" provides full masking of all data types
    default_varchar         varchar(100)    MASKED WITH (FUNCTION = 'default()') DEFAULT('varchar string'),
    default_char            char(20)        MASKED WITH (FUNCTION = 'default()') DEFAULT('char string'),
    default_text            text            MASKED WITH (FUNCTION = 'default()') DEFAULT('text string'),
    default_bit             bit             MASKED WITH (FUNCTION = 'default()') DEFAULT(0),
    default_int             int             MASKED WITH (FUNCTION = 'default()') DEFAULT(256),
    default_bigint          bigint          MASKED WITH (FUNCTION = 'default()') DEFAULT(2560),
    default_decimal         decimal         MASKED WITH (FUNCTION = 'default()') DEFAULT(5.5),
    default_date            date            MASKED WITH (FUNCTION = 'default()') DEFAULT(SYSDATETIME()),
    default_time            time            MASKED WITH (FUNCTION = 'default()') DEFAULT(SYSDATETIME()),
    default_datetime2       datetime2       MASKED WITH (FUNCTION = 'default()') DEFAULT(SYSDATETIME()),
    default_datetimeoffset  datetimeoffset  MASKED WITH (FUNCTION = 'default()') DEFAULT(SYSDATETIME()),
    default_varbinary       varbinary(max)  MASKED WITH (FUNCTION = 'default()') DEFAULT(0x424F),
    default_xml             xml             MASKED WITH (FUNCTION = 'default()') DEFAULT('<sample>hello</sample>'),
    default_hierarchyid     hierarchyid     MASKED WITH (FUNCTION = 'default()') DEFAULT('/1/2/3/'),
    default_geography       geography       MASKED WITH (FUNCTION = 'default()') DEFAULT('POINT(0 0)'),
    default_geometry        geometry        MASKED WITH (FUNCTION = 'default()') DEFAULT('LINESTRING(0 0, 5 5)'),
    -- "partial" provides partial masking of string data types
    partial_varchar         varchar(100)    MASKED WITH (FUNCTION = 'partial(2, "...", 2)') DEFAULT('varchar string'),
    partial_char            char(20)        MASKED WITH (FUNCTION = 'partial(2, "...", 2)') DEFAULT('char string'),
    partial_text            text            MASKED WITH (FUNCTION = 'partial(2, "...", 2)') DEFAULT('text string'),
    -- "email" provides email-format masking of string data types
    email_varchar           varchar(100)    MASKED WITH (FUNCTION = 'email()') DEFAULT('varchar string'),
    email_char              char(20)        MASKED WITH (FUNCTION = 'email()') DEFAULT('char string'),
    email_text              text            MASKED WITH (FUNCTION = 'email()') DEFAULT('text string'),
    -- "partial" can simulate "email"
    partial_email_varchar   varchar(100)    MASKED WITH (FUNCTION = 'partial(1, "XXX@XXXX.com", 0)') DEFAULT('varchar email string'),
    -- "random" provides random masking of numeric data types
    random_bit              bit             MASKED WITH (FUNCTION = 'random(0, 1)') DEFAULT(0),
    random_int              int             MASKED WITH (FUNCTION = 'random(1, 12)') DEFAULT(256),
    random_bigint           bigint          MASKED WITH (FUNCTION = 'random(1001, 999999)') DEFAULT(2560),
    random_decimal          decimal         MASKED WITH (FUNCTION = 'random(100, 200)') DEFAULT(5.5)
)
```

This query shows how the `default()` function can fully mask a wide variety of data types, including dates, times, binary data, and even specialized CLR types like `xml`, `hierarchyid`, and spatial types like `geometry` and `geography`.

**Key Points:**
- The `default()` function is a bit of a misnomer and could have been more aptly named `full()` for clarity, as it fully masks the data, contrary to what the name might suggest.
- The `default()` function's universality across all data types illustrates its versatility in masking sensitive data, regardless of the data type.
- The `DEFAULT` constraint in SQL statements is distinct from the DDM `default()` function. The former sets a default value for a column if no specific value is provided when we insert rows into the table.
- DDM is able to mask complex data types, such as `xml`, `hierarchyid`, `geography`, and `geometry`, extending the usefulness of DDM beyond the more primitive data types.
- The bit data type is considered numeric and can thus use the `random()` function to mask values within the range of 0 to 1.

Now populate the `MaskingSample` table with six rows, each labeled from 'Row1' to 'Row6':

```sql
INSERT INTO MaskingSample (Label) VALUES
 ('Row1'), ('Row2'), ('Row3'), ('Row4'), ('Row5'), ('Row6')
```

This `INSERT` statement only specifies values for the `Label` column, relying on the table's `DEFAULT` constraints to populate all the other columns that are defined as masked columns.

Next, observe the results of querying the `MaskingSample` table as the `dbo` user:

```sql
SELECT * FROM MaskingSample
```

In the results, you can see all the data in the `MaskingSample` table unmasked, due to the implicit `UNMASK` permission associated with the `dbo` role. This includes seeing the actual values for all columns, regardless of the mask defined. For example, `varchar`, `char`, and `text` columns masked with the `default()` function show their actual data rather than being fully masked, and numeric columns such as `int`, `bigint`, and `decimal` display their true values instead of random numbers or zero. Similarly, complex types like `xml`, `hierarchyid`, `geography`, and `geometry` are also be fully visible.

Now, let's grant `SELECT` permission on the `MaskingSample` table to `RegularUser`, but we won't also grant them the `UNMASK` permission:

```sql
-- View masked data
GRANT SELECT ON MaskingSample TO RegularUser
```

Next, impersonate `RegularUser` and query the `MaskingSample` table again:

```sql
-- As RegularUser, the data is masked
EXECUTE AS USER = 'RegularUser'
SELECT * FROM MaskingSample
REVERT
```

This time, all the masked columns are obfuscated due to the lack of `UNMASK` permission. As you scroll horizontally through the columns in the result set, take special note of how the `default()` function fully masks columns of different data types, like `datetime2` and `xml`, replacing them with their masked equivalents. Also, observe the `random()` function in action; run the code snippet multiple times to see random numbers generated for numeric columns, including random 0 and 1 values for the bit column. This demonstrates the versatility of the default() function in fully masking a wide variety of data types and the random() function in providing obfuscated yet plausible numeric data.

### Cleanup

To conclude, let's clean up the objects we've created during this lab:

```sql
-- Cleanup
DROP VIEW vwShowUsers
DROP USER RegularUser
DROP USER ContactUser
DROP TABLE Membership
DROP TABLE MaskingSample
```

This cleanup ensures that all demo-related objects are removed, restoring your AdventureWorks2019 database to its original state.

___

[Row-Level Security (RLS) ▶](https://github.com/lennilobel/sql2022-workshop-hol/tree/main/HOL/3.%20Security%20Features/3.%20Row%20Level%20Security)

