## Dynamic Data Masking

Dynamic Data Masking (DDM) is a security feature in SQL Server that automatically hides sensitive data in the result set of a query over designated database fields, without changing the actual data in the database. DDM can be used to restrict unauthorized access to sensitive data by masking it to non-privileged users, making it a powerful tool for enhancing data privacy and compliance. This enables developers and database administrators to define how much of the sensitive data to reveal with minimal impact on the application layer.

### Create the Membership Table

Dynamic Data Masking (DDM) is a security feature in SQL Server that obscures sensitive data in the result set of a query, ensuring that unauthorized users can't see the data they shouldn't access. In this example, we create a `Membership` table with various columns, each employing a different pre-defined DDM function to mask data:

```sql
CREATE DATABASE MyMaskedDB
GO

USE MyMaskedDB
GO

-- Create table with a few masked columns
CREATE TABLE Membership(
    MemberId int IDENTITY PRIMARY KEY,
    FirstName varchar(100) MASKED WITH (FUNCTION = 'partial(2, "...", 2)') NULL,
    LastName varchar(100) NOT NULL,
    Phone varchar(12) MASKED WITH (FUNCTION = 'default()') NULL,
    Email varchar(100) MASKED WITH (FUNCTION = 'email()') NULL,
    DiscountCode smallint MASKED WITH (FUNCTION = 'random(1, 100)') NULL)
```

1. **Partial Masking (`partial()`)**: Reveals the first two and the last two characters of the `FirstName`, masking the middle part with dots. This function offers flexibility for masking string data.

2. **Default Masking (`default()`)**: Completely masks the `Phone` number. The term "default" may be somewhat misleading; "full" might have been a more descriptive name since it fully masks the value, unlike the `partial()` function which only partially masks values. This function is suitable for any data type to hide the original data behind a generic mask.

3. **Email Masking (`email()`)**: Applied to the `Email` column, this function only reveals the first character and masks the rest as XXX@XXX.COM. Interestingly, this specific function is somewhat redundant since the same effect can be achieved with the `partial()` function by specifying `partial(1, 'XXX@XXX.COM', 0)`, making the email function effectively useless and highlighting that there are essentially only three distinctively useful masking functions.

4. **Random Masking (`random()`)**: Generates a random number within a specified range for the `DiscountCode`, an alternative to using `default()`, which works with all data types and would always fully mask numbers as 0. Using `random()` also fully masks numbers but by generating random numbers within a range that might depict some real scenario (like the range of numbers 1 through 7 to indicate the day of the week), thus providing more useful sample obfuscated data.

It's important to note that while DDM provides these predefined functions, SQL Server does not allow the creation of custom masking functions, limiting the flexibility to these three core masking approaches (with the email mask being a specialized but replaceable use case of partial masking).



### Discover Masked Columns
To explore the masked columns within the database and understand how data masking is applied to each, you can utilize the following query. This query joins `sys.masked_columns` with `sys.tables`, allowing you to view details such as the table name, column name, and the specific masking function applied to each column. Here's how you can perform this discovery:

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

The results fully reveal all the data, including the columns we designed as masked. This is because we are connected as user `dbo`, and so we possess the `UNMASK` permission that reveals all masked columns. Let's explore this further by testing with different users and permissions.

### Discover Users and Permissions

To provide a comprehensive overview of database users, their associated logins, and their permissions within the database, the following view named `vwShowUsers` is created. This view joins several catalog views to produce a detailed report that includes each database user's name, the login name they're associated with, their login type, the state and name of their permissions, and, where applicable, the names of tables and columns those permissions apply to. This view focuses on users 'dbo', 'RegularUser', and 'ContactUser', giving insights into their access levels and permissions across the database. Here's how to create this useful view:

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
GO
```

This view will be instrumental in understanding how permissions are distributed among users within the database, particularly as it pertains to the demos that follow.










When querying the `vwShowUsers` view, it becomes apparent that there is only one explicitly listed permission for the `dbo` user, which is the ability to connect to the database. However, it's crucial to understand that the `dbo` user inherently possesses a comprehensive set of permissions within the database, including the `UNMASK` permission. This extensive access allows the `dbo` user to see the actual data in columns that have been masked using Dynamic Data Masking (DDM), without the masking being applied.

```sql
-- The currently connected login is mapped to user dbo, with full permissions implied, including UNMASK
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

### Create New User `RegularUser`

By creating a new user named `RegularUser` without an associated login, you're establishing a user within the database that starts with minimal permissions. Initially, this user has only the basic ability to connect to the database and lacks more extensive permissions such as `UNMASK` or even `SELECT` permissions on tables like `Membership`. This starkly contrasts with the `dbo` user, who implicitly inherits all permissions within the database, including `UNMASK`. The creation of `RegularUser` and the subsequent query of the `vwShowUsers` view illustrates the default permissions state for new users and highlights the necessity of explicitly granting further permissions to access and interact with database objects. Here's the code to create the user and review their permissions:

```sql
CREATE USER RegularUser WITHOUT LOGIN
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

Upon querying `vwShowUsers` following the creation of `RegularUser`, you'll observe that, aside from the ability to connect to the database, no additional permissions are listed for this user. This absence of permissions, including the lack of `UNMASK`, means that `RegularUser` cannot view the unmasked data in the `Membership` table, nor can they perform basic `SELECT` queries on it without further permission grants. This delineates a clear boundary between the inherent permissions of the `dbo` user and the restricted, default permissions state of newly created users in SQL Server.

### Grant Permissions to `RegularUser`

Granting `SELECT` permissions on the `Membership` table to `RegularUser` enables this user to query the table and view its contents. However, since `RegularUser` does not have the `UNMASK` permission, they will only see masked versions of the data in columns protected by Dynamic Data Masking (DDM). This ensures that sensitive information remains obscured to users without explicit permission to view it unmasked. Here's how you can grant `SELECT` permissions and verify the updated permissions setup:

```sql
GRANT SELECT ON Membership TO RegularUser
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

After executing the above commands, querying the `vwShowUsers` view will confirm that `RegularUser` now has the ability to `SELECT` from the `Membership` table, signifying they can query the table but will encounter masked data for protected columns. This illustrates SQL Server's capability to secure sensitive data at the column level, allowing for fine-grained control over data access and privacy.

## Impersonating `RegularUser`

By utilizing the `EXECUTE AS USER` command, we temporarily impersonate the `RegularUser` within our current connection. This allows us to query the `Membership` table and observe how data masking affects the visibility of its data from the perspective of `RegularUser` instead of `dbo`. After running the query, we use `REVERT` to return to our original user context, which is typically a user with more privileges, like `dbo`. This practice is particularly useful for testing how different users experience data access and visibility. Here's the applicable T-SQL:

```sql
EXECUTE AS USER = 'RegularUser';
SELECT * FROM Membership;	-- DiscountCode is randomized each time
REVERT;
```

**Key Observations in the Output:**
- **FirstName Field:** The `partial(2, "...", 2)` function is applied, revealing the first two and the last two characters for names longer than four characters. Names with four or fewer characters, such as "Dan" and "Jane", are fully masked to preserve privacy.
- **Phone Column:** Completely masked with 'xxxx', consistent with the `default()` function, ensuring complete data obfuscation.
- **Email Addresses:** The `email()` function masks real email addresses by showing only the first character followed by XXX@XXXX.com, effectively masking the true email while providing a standardized placeholder.
- **DiscountCode Column:** Generates random numbers between 1 and 100 for each query execution, as specified by the `random(1, 100)` function. This results in varying, unpredictable numbers that mask the actual discount codes. It's recommended to run this code multiple times to see the different values produced for the discount code each time, illustrating the dynamic nature of this type of data masking.

This exercise demonstrates Dynamic Data Masking's ability to protect sensitive information from unauthorized access in SQL Server, tailoring data visibility based on user permissions and roles.







### Granting and Revoking the UNMASK Permission

By granting the `UNMASK` permission to `RegularUser`, we are now allowing this user to see data in its unmasked form, similar to how the `dbo` user can view all data without the masks applied. Here's how we grant the permission and then verify it:

```sql
-- Let RegularUser see unmasked data
GRANT UNMASK TO RegularUser
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

This change in permissions means that when `RegularUser` accesses the `Membership` table, they will see actual data values for columns like `FirstName`, `Phone`, `Email`, and `DiscountCode`, rather than the masked versions. It's a significant permission grant that should be carefully considered in the context of data privacy and security policies within your organization.

Typically, you would assign the `UNMASK` permission to a role rather than to each individual user. Then, every user that is a member of that role would inherit the `UNMASK` permission. We're only granting permission at the user level in this demo to keep things simple without detracting from the way Dynamic Data Masking (DDM) works.

By granting the `UNMASK` permission to `RegularUser`, they are now able to see all the data without the masking applied. Here's how you can see the effect:

```sql
EXECUTE AS USER = 'RegularUser'
SELECT * FROM Membership
REVERT 
```

Running the query as `RegularUser` will now reveal all the data in its original, unmasked state, showcasing how the `UNMASK` permission enables specific users to view the true data behind the masks. This demonstrates Dynamic Data Masking's role in selectively obscuring data, and how permissions can be used to control access to the underlying information.





By revoking the `UNMASK` permission from `RegularUser`, we enforce the data masking rules again, restricting their access to the original, unmasked data. This operation effectively re-applies the masking functions to the data for `RegularUser`. Here's how to revoke the permission and observe the effect:

```sql
REVOKE UNMASK FROM RegularUser
EXECUTE AS USER = 'RegularUser'
SELECT * FROM Membership
REVERT 
```

After revoking the permission, when `RegularUser` queries the `Membership` table, the data appears masked according to the masking rules defined on the columns. This reinforces the Dynamic Data Masking's capability to protect sensitive information from unauthorized access, ensuring that only users with the `UNMASK` permission can view data in its unmasked form.


### Granular DDM Permissions (new in SQL Server 2022)

The granular DDM permissions feature introduced in SQL Server 2022 is a significant enhancement that addresses a major limitation in previous versions. Previously, SQL Server allowed granting or revoking the `UNMASK` permission only at the database level, which limited its flexibility and adoption. However, SQL Server 2022 expands this capability, offering much-needed granularity. Now, administrators can grant or revoke `UNMASK` permissions at various levels, providing tailored access control that matches specific security requirements. 

This granular control can be applied:

- **Database Level**: As before, affecting all masked columns across the entire database.
- **Schema Level**: Affecting all tables within a specific schema.
- **Table Level**: Applying to all columns within a specific table.
- **Column Level**: The most granular level, targeting individual columns within a table.

This flexibility greatly enhances the practical use of Dynamic Data Masking by allowing precise control over who can see unmasked data, ensuring that only authorized users can access sensitive information at the level of detail appropriate to their role or needs. Our next demo will focus on showcasing this functionality by granting `UNMASK` permissions at the individual column level.


Now we're going to set up a scenario where a specific user, named `ContactUser`, has been tasked with reaching out to members. To facilitate this, they'll need access to certain information that's normally masked, specifically the `FirstName`, `Phone`, and `Email` columns within the `Membership` table. However, they don't require access to the `DiscountCode`, which remains masked. Here's how you can achieve this with granular Dynamic Data Masking permissions in SQL Server 2022:

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

By running the above code, we've created `ContactUser` and granted them the `SELECT` permission on the `Membership` table. We've then gone a step further by granting the `UNMASK` permission, but specifically and only for the `FirstName`, `Phone`, and `Email` columns. This allows `ContactUser` to view these normally masked columns in their unmasked state, while the `DiscountCode` remains masked, adhering to the principle of least privilege.

To verify the permissions granted:

```sql
SELECT * FROM vwShowUsers ORDER BY Username, PermissionName, TableName, ColumnName
```

Querying our permissions view now, you'll see that `ContactUser` has the `UNMASK` permission for just the designated columns, showcasing SQL Server 2022's capability for granular Dynamic Data Masking permissions. This feature significantly enhances the flexibility and practicality of DDM by allowing for more nuanced control over who can see specific pieces of data.

Let's see what happens when `ContactUser` accesses the `Membership` table, particularly focusing on the columns for which they've been granted `UNMASK` permissions:

```sql
-- Impersonate ContactUser to query the Membership table
EXECUTE AS USER = 'ContactUser'
SELECT * FROM Membership
REVERT 
```

By executing the code above, you'll notice that `ContactUser` can view the `FirstName`, `Phone`, and `Email` columns without any masking, thanks to the granular `UNMASK` permissions that have been explicitly granted for these columns. However, the `DiscountCode` remains masked, with its values randomized between 1 and 100, demonstrating the effect of the `random()` masking function. This behavior aligns perfectly with our intent for `ContactUser`, allowing them access to the necessary contact information while keeping other sensitive data, like discount codes, masked. Go ahead and run the code multiple times to observe the dynamic masking in action for the `DiscountCode` column, showcasing the effectiveness of SQL Server 2022's granular DDM permissions.

## Masking All Data Types

In this demo, we're showcasing Dynamic Data Masking (DDM) capabilities beyond the common string and number data types, illustrating how DDM's `default()` function can fully mask a wide variety of data types, including dates, times, binary data, and even complex CLR types like `XML`, `hierarchyid`, and spatial types like `geometry` and `geography`.

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

**Key Points:**
- The `default()` function is a bit of a misnomer and could have been more aptly named `full()` for clarity, as it fully masks the data, contrary to what the name might suggest.
- The `default()` function's universality across all data types illustrates its versatility in masking sensitive data, regardless of the data type.
- The `DEFAULT` constraint in SQL statements is distinct from the DDM `default()` function. The former sets a default value for a column when no specific value is provided when we insert rows into the table.
- The demonstration highlights DDM's capacity to handle complex data types, such as `XML`, `hierarchyid`, `geography`, and `geometry`, extending the usefulness of DDM beyond basic data types.
- The bit data type is considered numeric and can thus use the `random()` function to mask values within the range of 0 to 1.
- While DDM offers predefined functions for masking, there's no support for custom

To demonstrate Dynamic Data Masking on a variety of data types, we populate the `MaskingSample` table with rows, each labeled from 'Row1' to 'Row6'. The `INSERT` statement only specifies values for the `Label` column, relying on the table's `DEFAULT` constraints to populate the other columns. This approach allows us to observe how DDM behaves with default values across different data types under a variety of masking functions.

```sql
INSERT INTO MaskingSample (Label) VALUES
 ('Row1'), ('Row2'), ('Row3'), ('Row4'), ('Row5'), ('Row6')
```

By only supplying values for the `Label` column, the table leverages its `DEFAULT` constraints to fill in the other columns, demonstrating the effects of the masking functions on each data type. This setup serves as an illustrative example of DDM's capabilities and limitations with different data types, without requiring explicit values for each column during the insert operation.


```sql
SELECT * FROM MaskingSample
```




Running as the `dbo` user, you'll see all the data in the `MaskingSample` table unmasked, due to the implicit `UNMASK` permission associated with the `dbo` role. This includes seeing the actual values for all columns, regardless of the mask defined. For example, `varchar`, `char`, and `text` columns masked with the `default()` function will show their actual data rather than being fully masked, and numeric columns such as `int`, `bigint`, and `decimal` will display their true values instead of random numbers or zero. Similarly, complex types like `xml`, `hierarchyid`, `geography`, and `geometry` will also be fully visible.

This behavior emphasizes the importance of the `UNMASK` permission in controlling access to sensitive data. Without it, users see masked data according to the rules defined in the column definitions, effectively obfuscating the information based on the type of masking function applied.

When running this query as `dbo`, all data appears as originally inserted or defined by the `DEFAULT` constraints, demonstrating the unmasking effect of having the appropriate permissions.





Now, let's grant `SELECT` permission on the `MaskingSample` table to `RegularUser`, but we won't also grant them the `UNMASK` permission. Then we'll impersonate `RegularUser` and query the `MaskingSample` table again. This time, all the masked columns are obfuscated due to the lack of `UNMASK` permission. As you scroll horizontally through the columns in the result set, take special note of how the `default()` function fully masks columns of different data types, like `datetime2` and `xml`, replacing them with their masked equivalents. Also, observe the `random()` function in action; run the code multiple times to see random numbers generated for numeric columns, including random 0 and 1 values for the bit column. This demonstrates the versatility of the default() function in fully masking a wide variety of data types and the random() function in providing obfuscated yet plausible numeric data.

```sql
-- View masked data
GRANT SELECT ON MaskingSample TO RegularUser

-- As RegularUser, the data is masked
EXECUTE AS USER = 'RegularUser'
SELECT * FROM MaskingSample
REVERT
```

### Cleanup

Let's clean up the objects we've created during this Dynamic Data Masking (DDM) demo:

1. **vwShowUsers**: This view was created to help us list database user names, their associated login names, along with their permissions. Deleting this view cleans up our utility objects.
2. **RegularUser**: This user was created to demonstrate how data masking works for users without the `UNMASK` permission. Deleting this user cleans up our test users.
3. **ContactUser**: Similar to RegularUser, this user was created to show granular `UNMASK` permissions on specific columns. Deleting this user further cleans up our test setup.
4. **Membership**: This table was used to demonstrate the four pre-defined DDM functions. Dropping this table removes our primary example for data masking.
5. **MaskingSample**: This table was created to demonstrate that the `default()` function can fully mask various data types. Dropping this table cleans up our extended examples for data masking.

Additionally, you might want to delete the entire `MyMaskedDB` database to clean up all resources related to this DDM demo in one go.

Here's the code to perform the cleanup:

```sql
-- Cleanup
DROP VIEW IF EXISTS vwShowUsers
DROP USER IF EXISTS RegularUser
DROP USER IF EXISTS ContactUser
DROP TABLE IF EXISTS Membership
DROP TABLE IF EXISTS MaskingSample
```

This cleanup ensures that all demo-related objects are removed, leaving your environment clean and ready for further exploration or other demos.

___

[Row-Level Security (RLS) ▶](https://github.com/lennilobel/sql2022-workshop-hol/tree/main/HOL/3.%20Security%20Features/3.%20Row%20Level%20Security)
