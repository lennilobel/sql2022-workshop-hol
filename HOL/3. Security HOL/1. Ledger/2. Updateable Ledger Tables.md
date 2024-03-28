## Ledger

### Setup

In this hands-on lab, we're starting by setting up our environment for working with ledger tables in SQL Server. The first step is to create a new database specifically for our ledger table demos. After creating the database, we'll use the `sys.sp_generate_database_ledger_digest` stored procedure to generate the initial database ledger digest. At this initial stage, because the database is new and no transactions have been recorded yet, the digest will be `NULL`. This serves as our baseline; as transactions are executed, the digest will change, reflecting the ledger's tamper-evident nature by showing a JSON payload with the database digest block number and hash.

```sql
-- Create a new database for our ledger table demos
CREATE DATABASE LedgerDemo
GO

USE LedgerDemo
GO

-- Generate the initial database ledger digest
-- At this point, since no transactions have occurred within the ledger-enabled database, 
-- the digest will be NULL, indicating no ledger-based changes or transactions have been recorded.
EXEC sys.sp_generate_database_ledger_digest
```

This setup is crucial for understanding how ledger tables provide a secure and transparent way to track and verify database changes over time.

### Append-Only Ledger Tables

#### Create an Append-Only Ledger Table

With the initial setup complete, we move to the next step in our hands-on lab, focusing on creating an append-only ledger table within our `LedgerDemo` database. This example introduces a table named `KeyCardEvent` to record employee key card swipes, an action synonymous with entering or exiting a building. Given the table's purpose, it's structured to be append-only, reinforcing the idea that once a swipe event is recorded, it should remain unaltered; updates and deletions are not applicable to the nature of this data.

The `CREATE TABLE` statement is enhanced with the `LEDGER = ON (APPEND_ONLY = ON)` option to enforce these constraints, turning our table into an append-only ledger table. This ensures the integrity and immutability of the event records.

Following the table's creation, we invoke the `sys.sp_generate_database_ledger_digest` stored procedure again to observe changes in the database digest. At this juncture, the database digest will reflect the first transaction - the creation of our ledger table. The digest output will include a block ID, starting at 0, and a hash value. This hash represents the current state of the database ledger, encapsulating all transactions up to this point, including our `CREATE TABLE` operation.

This demonstrates how SQL Server's ledger feature provides a verifiable and tamper-evident record of all database transactions. Each transaction alters the database digest, creating an audit trail that enhances data transparency and security.

```sql
-- Create an append-only ledger table named KeyCardEvent
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

-- Retrieve the database digest after the creation of the ledger table
-- This digest will now reflect the first transaction, indicating the immutable record 
-- of the table's creation within the database ledger.
EXEC sys.sp_generate_database_ledger_digest
```






#### Populate the Append-Only Ledger Table

Now, we'll simulate the scenario of an employee swiping their badge to enter a building by inserting a row into our append-only ledger table. This first row records employee ID 43869 entering building 42 on June 2, 2022, at 6:55 PM. After inserting this event, we retrieve the database digest again. The database digest now reflects a block ID of 1, which indicates this is the second transaction (the first one being the creation of the table). Moreover, the updated hash value in the digest is derived from this transaction's hash combined with the hash of the previous block, thus implementing a blockchain structure for the database digest. 

Here's the code to perform the insertion and then retrieve the updated database digest:

```sql
INSERT INTO KeyCardEvent VALUES
 (43869, 'Building42', '2022-06-02T18:55:22')

EXEC sys.sp_generate_database_ledger_digest
```

When inserting multiple rows with a single `INSERT` statement into an append-only ledger table, SQL Server treats the entire operation as a single transaction. This behavior is reflected in the database's ledger digest, where a single block ID represents the transaction, not the individual row insertions. This ensures that the ledger maintains a consistent and tamper-evident record of transactions, providing an auditable history of changes. The block ID increases with each transaction, not with each row, emphasizing the transactional nature of ledger updates. Here's how you insert two rows with one statement and retrieve the updated digest, showing the transaction's blockchain nature:

```sql
INSERT INTO KeyCardEvent VALUES
 (43869, 'Building49', '2022-06-02T19:58:47'),
 (19557, 'Building97', '2022-06-02T20:01:56')

EXEC sys.sp_generate_database_ledger_digest
```


#### Hidden Append-Only Ledger Table Columns

In SQL Server's append-only ledger tables, two hidden ledger columns, `ledger_start_transaction_id` and `ledger_start_sequence_number`, are automatically added to track transactional metadata. These columns are not visible when executing a standard `SELECT *` query, maintaining the simplicity of the table's schema for general use. However, these hidden columns can be explicitly queried to reveal the underlying ledger framework that supports the append-only integrity and auditability of the table. The `ledger_start_transaction_id` and `ledger_start_sequence_number` provide a detailed audit trail, offering insights into the transaction history of each row. Here's how you can query the table normally and then explicitly include the hidden ledger columns:

```sql
-- Appears as a standard table:
SELECT * FROM KeyCardEvent

-- Revealing hidden ledger columns:
SELECT
	*,
	ledger_start_transaction_id,
	ledger_start_sequence_number
FROM
	KeyCardEvent
```

In SQL Server's append-only ledger tables, the hidden columns for the transaction ID and sequence number provide essential details about the transactions that affected each row. Here's how they work:

- **Transaction ID:** This column uniquely identifies the transaction under which the row was inserted. It's crucial for tracing the row back to a specific point in the database's transaction history.

- **Sequence Number:** This column distinguishes between rows inserted by the same transaction. It's especially relevant for transactions that affect multiple rows.

For example, when the first row is inserted into a ledger table, it's recorded with a unique transaction ID and a sequence number of 0, indicating it's the first (and in this case, the only) row inserted by that transaction.

When another transaction inserts multiple rows—like two rows in our example—each row inserted by this transaction shares the same transaction ID, as they're part of the same transactional action. However, to differentiate between these rows, they are assigned incremental sequence numbers starting from 0. Therefore, the first row inserted by this transaction will have a sequence number of 0, and the second row will have a sequence number of 1.

This system allows SQL Server to maintain a detailed and orderly record of all changes made within a transaction, supporting data integrity and auditability by ensuring every individual row affected by a transaction is accounted for and distinguishable.

In SQL Server's ledger tables, while the default hidden columns for tracking transactional metadata are named `ledger_start_transaction_id` and `ledger_start_sequence_number`, you aren't stuck with these names. When creating an append-only ledger table, you have the option to specify custom names for these hidden columns. This customization is achieved by using the `TRANSACTION_ID_COLUMN_NAME` and `SEQUENCE_NUMBER_COLUMN_NAME` parameters within the `WITH LEDGER = ON` clause of the `CREATE TABLE` statement.

This feature allows for greater flexibility in adhering to your organization's naming conventions or in making the column names more descriptive and aligned with the table's context. By customizing these column names, you can ensure consistency across your database schema while benefiting from the robust auditing and data integrity features provided by SQL Server's ledger tables.




In SQL Server's ledger tables, the transaction ID and sequence number columns play a crucial role in tracking changes and ensuring data integrity. By default, these columns are hidden from the result set when executing a `SELECT *` query, due to the `HIDDEN` keyword being applied to them. This behavior is designed to keep the table's presentation clean and focused on the business data, while still maintaining a comprehensive audit trail under the hood.

However, SQL Server provides the flexibility to make these columns visible in your queries. If you prefer the transaction ID and sequence number columns to be directly accessible and not hidden, you can customize the table's creation script. When defining your ledger table, simply include the definitions for the transaction ID and sequence number columns without applying the `HIDDEN` keyword. This customization allows these columns to appear in the results of a `SELECT *` query, making it easier to directly access and analyze the audit trail data.

This capability to toggle the visibility of the transaction ID and sequence number columns provides developers and database administrators with the option to tailor the ledger table's behavior to their specific needs, whether that means keeping the audit trail discreetly in the background or making it a prominent part of the table's data.


#### Querying sys.database_ledger_transactions

In SQL Server 2022's ledger database, the `sys.database_ledger_transactions` catalog view plays a crucial role in providing transparency and traceability for append-only ledger tables. This view stores a record for each transaction that occurs within the ledger database, encompassing both Data Definition Language (DDL) transactions, such as creating a table, and Data Manipulation Language (DML) transactions, like inserting rows.

The `transaction_id` found in the `KeyCardEvent` ledger table acts as a foreign key to the `sys.database_ledger_transactions` catalog view, establishing a direct link between table data and the transaction that affected it. This system ensures that for each operation—whether it's the initial table creation or subsequent data insertions—there's a corresponding row in the catalog view detailing the transaction's specifics.

For instance, the first transaction in block 0 typically represents the `CREATE TABLE` operation, marking the ledger table's inception with a DDL transaction. Following this, block 1's transaction captures the first `INSERT` operation that adds a single row to the ledger table, classified as a DML transaction. The transaction in block 2, meanwhile, logs another `INSERT` operation that introduces two more rows to the table, again a DML action. Notably, even though the latter `INSERT` affects multiple rows, it's recorded as a single transaction, highlighting the system's efficiency in transaction management.

This catalog view also records each transaction's `commit_time` (the exact timestamp when the transaction was finalized), `principal_name` (identifying the user responsible for the transaction), and `table_hashes` (representing the specific hash generated for the transaction). These details further enrich the auditability and integrity of the ledger database, allowing for an exhaustive and transparent record of all database activities.

Here's how you can view the transactions recorded in `sys.database_ledger_transactions`:

```sql
SELECT * FROM sys.database_ledger_transactions
```

This query returns a comprehensive list of transactions, providing a full audit trail from the database's inception to the current state. By examining this catalog view, users gain insight into the history and provenance of data within the ledger database, underpinning the ledger functionality's promise of immutable and verifiable record-keeping.





In this hands-on lab, you'll explore how ledger tables in SQL Server 2022 can enhance data integrity and transparency by providing an immutable record of transactions. We'll delve into the `sys.database_ledger_transactions` system view, which acts as a comprehensive catalog of all ledger transactions in your database. This includes both Data Definition Language (DDL) transactions, like table creations, and Data Manipulation Language (DML) transactions, such as insertions.

For our example, we have a table named `KeyCardEvent` designed to log key card access events. This table includes a `ledger_transaction_id` column, serving as a foreign key to the `transaction_id` column in `sys.database_ledger_transactions`. Each entry in `sys.database_ledger_transactions` is a unique transaction, identified by a `transaction_id`, and it provides valuable details such as the timestamp (`commit_time`), the user responsible (`principal_name`), and a hash representing the transaction (`table_hashes`).

Let's see how transactions are recorded and how we can correlate transactions with the data changes in the `KeyCardEvent` table. The `ledger_transaction_id` links each row in our table to its corresponding transaction, providing a clear audit trail. This allows us to see not only when data was modified but also who modified it, enhancing data governance and compliance.

Below is the SQL code to join the transaction catalog view with the `KeyCardEvent` table, showcasing the relationship between transactions and table data. This demonstrates the blockchain-like chain of custody for data within ledger-enabled databases, ensuring that data history is transparent and tamper-evident.

```sql
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
```

Through this query, we can observe how ledger tables provide an immutable, verifiable history of all data changes, thereby establishing a robust foundation for secure and transparent data management.





#### No Updates or Deletes on Append-Only Ledger Tables

In SQL Server 2022, append-only ledger tables offer a powerful mechanism for preserving the integrity of historical data. These tables are designed to be immutable; once a row is inserted, it cannot be altered or removed. This design principle ensures that the data remains tamper-evident, providing a clear and reliable audit trail for sensitive or regulated information.

The following examples demonstrate what happens when you attempt to update or delete rows in an append-only ledger table named `KeyCardEvent`. These operations are intended to fail because such modifications are not allowed on append-only ledger tables, reinforcing the table's immutability and the integrity of its data.

```sql
-- Try to update rows in the table; fails for append-only ledger table
UPDATE KeyCardEvent
    SET EmployeeId = 34184
    WHERE EmployeeId = 43869
```

Attempting to update any row in this table results in an error because the ledger table is configured to be append-only. This means that once data is written, it is set in stone—figuratively speaking.

```sql
-- Try to delete rows in the table; fails for append-only ledger table
DELETE KeyCardEvent
    WHERE EmployeeId = 43869
```

Similarly, attempting to delete any row from the table will also result in an error. This restriction is a key feature of append-only ledger tables, ensuring that every transaction and event recorded in the table remains intact and unaltered, providing a trustworthy and comprehensive historical record.

These restrictions exemplify the robust data protection mechanisms inherent in SQL Server 2022's ledger tables. By preventing updates and deletions, append-only ledger tables serve as a solid foundation for scenarios requiring strong auditability and data integrity.


### Updateable Ledger Tables

For this part of the hands-on lab, we're shifting our focus to updateable ledger tables, which, unlike append-only ledger tables, allow updates and deletes but still maintain a complete, immutable history of changes. This capability is particularly useful for scenarios where data needs to be updated or corrected, but you still require a full audit trail of all modifications.

#### Create an Updateable Ledger Table

Let's create an `Balance` table as an updateable ledger table. This table will keep track of customer balances. By enabling ledger functionality with `SYSTEM_VERSIONING`, we create a table that allows updates and deletions, with each change recorded in a history table. This ensures data integrity and provides a transparent record of all changes over time.

Here's the SQL code to create the `Balance` table as an updateable ledger table, along with its history table for storing the history of changes:

```sql
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
```

This structure allows the `Balance` table to be modified while keeping an immutable history of all changes in the `Balance_History` table. This approach combines the flexibility of updateable data with the security and transparency benefits of ledger technology.









Creating the `Balance` table as an updateable ledger table has caused the database ledger digest to update. This update is a direct result of the DDL operation (the `CREATE TABLE` statement) for the `Balance` table. Each such operation increments the database digest block ID, reflecting the new state of the database after the table creation. Here's how you can view the updated database digest:

```sql
EXEC sys.sp_generate_database_ledger_digest
```

This procedure call returns the latest database digest, including the new block ID incremented by the creation of the `Balance` table, showcasing how ledger databases maintain a continuous and immutable audit trail of all schema and data changes.





#### Discover Ledger Metadata

To explore the ledger tables in the database along with their associated ledger views and the names of their history tables, you can use a query that joins `sys.tables`, `sys.schemas`, and `sys.views`. This query provides a comprehensive overview of ledger-related tables, neatly associating each ledger table with its ledger view and, if applicable, its history table. Here’s how you run it:

```sql
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
```

This query yields a list of ledger tables within the current database, displaying each table's full name (schema + table name), the full name of its ledger view (schema + view name), and the full name of its history table (schema + table name), if it has one. This comprehensive view is essential for understanding the structure and relationships of ledger tables within your database.

In our demo, the query to view ledger tables, their associated ledger views, and history tables reveals the setup and relationships of ledger tables within the database. Specifically, it shows that `dbo.KeyCardEvent` and `dbo.Balance` are ledger tables. Each of these tables has an associated ledger view, named `dbo.KeyCardEvent_Ledger` and `dbo.Balance_Ledger`, respectively. These ledger views are crucial for interacting with ledger data, providing a read-only, cryptographically verifiable view of the data.

Importantly, the view distinguishes between the types of ledger tables: `dbo.KeyCardEvent` is an append-only ledger table, which means it is designed to prevent updates and deletes to ensure data immutability. Consequently, it does not have an associated history table because its ledger functionality does not require tracking changes over time.

Conversely, `dbo.Balance` is an updateable ledger table, which supports tracking changes through updates and deletions while ensuring the integrity and immutability of historical data. This is facilitated by the history table named `dbo.Balance_History`. This table serves as an archive for previous versions of data rows, capturing the state of data before any modifications. 





#### Populate the Updateable Ledger Table

To insert the first row into the `Balance` table for Nick Jones with an initial balance of 50, you would use the following SQL statement:

```sql
INSERT INTO Balance VALUES
 (1, 'Jones', 'Nick', 50);
```

This operation adds a new row to the `Balance` table, setting `CustomerId` to 1, `LastName` to 'Jones', `FirstName` to 'Nick', and `Balance` to 50. Since `Balance` is an updateable ledger table, this transaction not only affects the primary table but also creates a corresponding entry in the history table (`dbo.Balance_History`) to record this change for audit and verification purposes.




After inserting the first row into the `Balance` table, we observe changes in the ledger's database digest. This addition constitutes another transaction that is recorded in the database ledger.

```sql
EXEC sys.sp_generate_database_ledger_digest
```

Executing this command reveals an updated database digest, signified by an incremented block ID. This increment highlights the addition of a new transaction block to the ledger, linked to the prior block's hash, thereby maintaining the chain's integrity. This process underlines the ledger database's capability to securely log each transaction, ensuring a verifiable and immutable transaction history.





Inserting three more customers into the `Balance` table as a single transaction demonstrates the ledger database's capacity to track and record multiple entries added through a single operation.

```sql
INSERT INTO Balance VALUES
 (2, 'Smith', 'John', 500),
 (3, 'Smith', 'Joe', 30),
 (4, 'Michaels', 'Mary', 200)
```

This addition showcases the ledger's capability to securely log multiple rows added in a single transaction, ensuring that every modification is accurately captured as part of the database's immutable transaction history.





After inserting the first row into the `Balance` table, we observe changes in the ledger's database digest. This addition constitutes another transaction that is recorded in the database ledger.

```sql
EXEC sys.sp_generate_database_ledger_digest
```

Executing this command reveals an updated database digest, signified by an incremented block ID. This increment highlights the addition of a new transaction block to the ledger, linked to the prior block's hash, thereby maintaining the chain's integrity. This process underlines the ledger database's capability to securely log each transaction, ensuring a verifiable and immutable transaction history.






Inserting three more customer rows into the `Balance` table is also captured as a transaction in the ledger database. This operation will cause the block ID to increment once again and the hash to update, reflecting the new state of the database after these rows are added. Running the `sys.sp_generate_database_ledger_digest` command will retrieve the latest digest, showcasing the updated blockchain with the newly added transactions.

```sql
INSERT INTO Balance VALUES
 (2, 'Smith', 'John', 500),
 (3, 'Smith', 'Joe', 30),
 (4, 'Michaels', 'Mary', 200)

EXEC sys.sp_generate_database_ledger_digest
```


#### Hidden Updateable Ledger Table Columns

Run the following query to view all data in the `Balance` table, including the hidden ledger columns:

```sql
SELECT 
	*,
	ledger_start_transaction_id,
	ledger_end_transaction_id,
	ledger_start_sequence_number,
	ledger_end_sequence_number
FROM
	Balance
```

When querying the `Balance` table, we're specifically looking into hidden ledger columns that SQL Server uses to manage ledger tables. Here’s a detailed look at each point from the query:

1. **Nick's Transaction ID:** Focus on the `ledger_start_transaction_id` for Nick Jones. This ID marks the transaction in which Nick's row was initially inserted. We'll see this ID change as we update Nick's row, showcasing a new transaction that modifies this specific row.

2. **Shared Transaction ID:** The unique transaction ID for Nick Jones differs from the shared transaction ID used for John Smith, Joe Smith, and Mary Michaels. This distinction arises because Nick's entry was added in a separate transaction, while the other three were batch-inserted in a different single transaction. This demonstrates SQL Server's handling of transaction IDs based on the DML execution rather than the row count.

3. **Start and End Values in Updateable Ledger Tables:** The `ledger_start_transaction_id`, `ledger_end_transaction_id`, `ledger_start_sequence_number`, and `ledger_end_sequence_number` columns are noteworthy. In updateable ledger tables like `Balance`, both start and end values are present. Unlike append-only ledger tables, which only maintain `ledger_start_transaction_id` and `ledger_start_sequence_number`, updateable ledger tables also track `ledger_end_transaction_id` and `ledger_end_sequence_number` to delineate the end of a row's validity. The end values remain `NULL` in the main table to indicate the row's current version but are populated in the history table upon row updates or deletions, offering a clear audit trail akin to the functionality provided by temporal tables.





#### Updating Data and Saving History

We're going to observe what happens when we update data in an updateable ledger table.

```sql
-- Change Nick's balance from 50 to 100
UPDATE Balance SET Balance = 100
	WHERE CustomerId = 1

-- Observe the incremented digest block ID
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
```

In this sequence, we first update Nick Jones's balance from $50 to $100 in the `Balance` table. Following the update, the `EXEC sys.sp_generate_database_ledger_digest` command reveals an incremented block ID, indicating the inclusion of this update as a new transaction in the database's ledger.

The next query shows us the `Balance` table, where we can note that Nick's `ledger_start_transaction_id` has changed to reflect the transaction of his balance update. This change signifies the immutability and traceability of transactions within an updateable ledger table. Each row's lifecycle, from creation to modifications, is meticulously tracked, ensuring a clear audit trail.

Then, by querying the `Balance_History` table, we observe a history row for Nick, showing his balance as $50 associated with the original transaction ID we noted earlier. This demonstrates how the history table records previous versions of data rows, akin to temporal tables. This ensures that even as data in the primary table is updated, its prior states are preserved and accessible for auditing or historical analysis.




Let's observe another update operation on an updateable ledger table.

```sql
-- Change Nick's balance from 100 to 150
UPDATE Balance SET Balance = 150
	WHERE CustomerId = 1

-- Observe the incremented digest block ID
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
```

In this next step, we proceed to update Nick Jones's balance again, this time from $100 to $150 in the `Balance` table. After executing the update, we run `EXEC sys.sp_generate_database_ledger_digest`, which once more shows an incremented block ID, adding another transaction to the database ledger for this balance change.

Inspecting the `Balance` table thereafter, we find that Nick's `ledger_start_transaction_id` has updated to represent the latest transaction ID of the balance change to $150. This further emphasizes the ledger table's capability to accurately track and reflect each modification as distinct, immutable transactions.

Finally, examining the `Balance_History` table reveals not just one, but two history rows for Nick, corresponding to his previous balances of $50 and $100. Each row is linked to its own unique transaction, providing a comprehensive and auditable history of changes. This layer of data integrity and traceability is essential for applications requiring a transparent audit trail and the safeguarding of data against unauthorized alterations.



#### Ledger View

Let's delve into the significance of ledger views in updateable ledger tables through the `Balance_Ledger` view.

```sql
SELECT * FROM Balance_Ledger
ORDER BY ledger_transaction_id, ledger_sequence_number
```

The ledger view for updateable ledger tables, such as `Balance_Ledger`, plays a crucial role in amalgamating data from the main table with its history, creating a comprehensive and immutable audit trail of changes. This unified view not only showcases each transaction ID and sequence number but also categorizes the nature of each operation conducted on the data.

A notable aspect of updateable ledger tables is their operation types: unlike append-only ledger tables where operation types are limited to INSERT, updateable tables introduce DELETE operations in the ledger view. Moreover, UPDATE operations are ingeniously represented as a combination of INSERT and DELETE, where the INSERT denotes the transaction introducing the new values, and the DELETE encapsulates the prior state of the data.

This dual representation for updates offers a transparent and detailed audit trail, ensuring any changes made are clearly documented and accessible. The `Balance_Ledger` view thus becomes an indispensable tool for auditing and compliance, providing a detailed and indisputable history of all data manipulations within the updateable ledger table.


#### Ledger Verification

To perform ledger verification in SQL Server 2022, you can use the `sp_verify_database_ledger` stored procedure, which ensures the integrity of the database's ledger by confirming that the provided database digest is accurate and untampered. This process is vital for maintaining trust in the ledger's immutability and the integrity of the data within.

Firstly, run the `sp_generate_database_ledger_digest` procedure to generate the current database digest. This digest is a JSON payload that includes information like the database digest block number and hash, representing the state of the ledger up to the most recent transaction.

```sql
-- Get the current database digest
EXEC sp_generate_database_ledger_digest
```

After obtaining the digest, you'll need to copy it for use in the next step. This manual step is particularly necessary for on-premises SQL Server 2022 setups. Azure SQL Database automates this by allowing automatic storage of the digest in Azure Immutable Blob Storage, providing a way for external parties to perform continuous verification and ensure the database's integrity remains uncompromised.

Before proceeding with verification, it's important to enable snapshot isolation for the database. This setting is crucial for ensuring the consistency of the verification process and preventing any blocking issues during the operation.

```sql
-- Enable snapshot isolation
ALTER DATABASE LedgerDemo SET ALLOW_SNAPSHOT_ISOLATION ON
```

Finally, use the `sp_verify_database_ledger` procedure to verify the database's ledger integrity by providing the previously obtained digest as an argument. Replace `<paste-in-the-digest-json-here>` with the actual JSON digest you copied earlier.

```sql
-- Verify the database ledger
EXEC sp_verify_database_ledger N'<paste-in-the-digest-json-here>'
```

This verification step is an essential practice in maintaining the security and integrity of the database, offering peace of mind that the data's historical record remains secure and unaltered.

#### Dropping Ledger Tables

In SQL Server 2022, when you drop ledger tables, they aren't immediately permanently deleted. Instead, they're retained as "deleted ledger tables." This feature ensures that the integrity and auditability of the ledger data are preserved even after the tables are no longer actively used in the database.

After dropping the ledger tables using the `DROP TABLE` statements:

```sql
DROP TABLE KeyCardEvent       -- Append-only ledger table is renamed and moved to "Dropped Ledger Tables" in SSMS
DROP TABLE Balance            -- Updateable ledger table and its history table are renamed and moved to "Dropped Ledger Tables" in SSMS
```

You'll observe that these operations are captured as a single transaction, incrementing the database digest block ID. This behavior underscores the ledger's ability to record every transaction, maintaining a complete and immutable history.

To verify the status of the dropped tables, you can query the `sys.tables` system catalog view:

```sql
SELECT * FROM sys.tables
```

This query will show that the tables still exist in the database, but they have been renamed to indicate their status as dropped tables. This renaming helps in distinguishing active tables from those that have been logically removed from use.

Finally, if you wish to completely remove all traces of the database, including all ledger and deleted ledger tables, you can drop the database itself:

```sql
USE master
GO
DROP DATABASE LedgerDemo
GO
```

Dropping the database is a permanent action that deletes the database and all its contents, including any ledger tables and their associated history. This action should be taken with caution, as it cannot be undone.