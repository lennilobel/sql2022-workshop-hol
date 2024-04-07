# Ledger Tables

Ledger is a new feature in SQL Server 2022 designed to provide a secure and immutable record of database transactions, leveraging blockchain technology to enhance data integrity and auditability. This innovative approach provides unprecedented levels of verification and security. By leveraging this feature, organizations can enhance data governance, meet stringent compliance requirements, and secure data against unauthorized alterations, all while maintaining high performance and operational efficiency.

This section includes two labs for working with the two different types of ledger tables. The labs are designed to be followed in sequence:

- **Append-Only Ledger Tables**: Learn how to implement append-only Ledger tables, where data once written is immutable, mirroring the principles of blockchain to prevent modifications or deletions. This lab will guide you through scenarios where maintaining an untampered historical record is paramount.
  
- **Updatable Ledger Tables**: Discover the capabilities of updatable Ledger tables, which allow for data modifications and deletions but preserve an indelible history of these changes. This lab offers practical experience in managing dynamic data sets that change over time, while ensuring the audit trail remains secure and transparent.

When you open a query window in SSMS to start working on the first lab, leave it open to continue working through the second lab.

___

[Lab: Ledger - Append-Only Ledger Tables ▶](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/3.%20Security%20Features/1.%20Ledger%20Tables/1.%20Append-Only%20Ledger%20Tables.md)
