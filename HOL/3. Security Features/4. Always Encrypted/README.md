# Always Encrypted

Always Encrypted is a SQL Server security feature designed to safeguard sensitive data such as financial details and personal identification numbers. It enforces encryption directly within the client application, ensuring that sensitive data never appears as plain text inside the database system.

Encryption keys are accessible only by authorized client applications, which means that even database administrators do not have access to the unencrypted data, providing a strong level of protection against unauthorized access. Always Encrypted is particularly valuable in scenarios where sensitive data, such as personal identification numbers or financial information, needs to be safeguarded, making it an essential tool for developers and database administrators concerned with data privacy and compliance.

Let's explore the power and utility of Always Encrypted through two labs. This first lab will guide you through the process of encrypting several columns within a SQL Server table, using the Always Encrypted functionality. This will provide practical experience in handling encrypted data, encompassing querying and updating operations within SQL Server Management Studio (SSMS). The aim is to not only familiarize students with the encryption process but also to equip them with the skills needed to interact with encrypted data efficiently.

___

▶ [Lab: Always Encrypted - Encrypt a Table](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/3.%20Security%20Features/4.%20Always%20Encrypted/1.%20Encrypt%20a%20Table.md)
