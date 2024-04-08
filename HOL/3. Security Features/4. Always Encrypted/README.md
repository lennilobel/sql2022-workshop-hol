# Always Encrypted

Always Encrypted is a SQL Server security feature designed to safeguard sensitive data such as financial details and personal identification numbers. It enforces encryption directly within the client application, ensuring that sensitive data never appears as plain text inside the database system.

Encryption keys are accessible only by authorized client applications, which means that even database administrators do not have access to the unencrypted data, providing a strong level of protection against unauthorized access. Always Encrypted is particularly valuable in scenarios where sensitive data, such as personal identification numbers or financial information, needs to be safeguarded, making it an essential tool for developers and database administrators concerned with data privacy and compliance.

This section includes three labs that are designed to be followed in sequence:

- Encrypting a table with the Always Encrypted Wizard
- Creating an Always Encrypted client application
- Using Always Encrypted with Secure Enclaves

When you open a query window in SSMS to start working on the first lab, leave it open to continue working through the remaining labs in this section.

___

▶ [Lab: Encrypt a Table using Always Encrypted](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/3.%20Security%20Features/4.%20Always%20Encrypted/1.%20Encrypt%20a%20Table.md)
