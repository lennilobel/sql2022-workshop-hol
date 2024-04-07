# Temporal Tables (System-Versioning)

In this section, you will explore temporal tables (officially referred to as *system-versioned tables*), a powerful feature in SQL Server that simplifies the tracking and management of data changes over time. The key mechanism that enables temporal abilities are two special columns, the "period" columns, which SQL Server populates to track when each row is valid in time.

You'll learn how to create and configure temporal tables to automatically capture historical data, without complex coding or external tools. This capability is invaluable for tasks such as auditing, analyzing past trends, or restoring data after accidental changes. The focus will be on managing these tables effectively and executing point-in-time queries to view data at any specific moment in its history. By mastering temporal tables, you'll be able to effectively maintain a detailed and accessible record of your data's evolution over time.

This section includes three labs that are designed to be followed in sequence:

- Creating Temporal Tables
- Tracking History
- Point-in-Time Queries

When you open a query window in SSMS to start working on the first lab, leave it open for the remaining labs in this section.

___

[Lab: Temporal Tables - Creating a Temporal Table ▶](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/2.%20Temporal%20Tables/1.%20Creating%20Temporal%20Tables.md)
