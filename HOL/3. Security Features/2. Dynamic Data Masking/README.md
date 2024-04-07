# Dynamic Data Masking (DDM)

Dynamic Data Masking, first introduced in SQL Server 2016, is a security feature that safeguards sensitive information from unauthorized access by masking such information in query results. This protects private data such as personal identification numbers, financial details, and other confidential information without altering the actual data stored in the database. Unlike encryption, which secures data by transforming it into an unreadable format until it is decrypted with the proper key, Dynamic Data Masking works by obfuscating specific data within the database query results. This means the underlying data remains unchanged and fully accessible to authorized users, but when a query is run by someone without adequate permissions, the sensitive data appears masked or hidden.

SQL Server 2022 enhances this feature by introducing granular permissions capabilities, allowing for more precise control over who can bypass the data masking rules. This means administrators can now designate specific roles or users with the permissions to view unmasked data, offering a flexible approach to data access that balances security with the need for transparency in certain contexts. This enhancement makes Dynamic Data Masking an even more viable tool in the protection of sensitive information.

This section includes a single lab designed to familiarize you with both the foundational concepts of Dynamic Data Masking and the new granular permission capabilities introduced in SQL Server 2022.

___

[Lab: Dynamic Data Masking (DDM) ▶](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/3.%20Security%20Features/2.%20Dynamic%20Data%20Masking/Dynamic%20Data%20Masking.md)
