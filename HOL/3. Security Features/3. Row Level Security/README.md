# Row-Level Security (RLS)

Row-Level Security (RLS) allows for the fine-grained restriction of rows in a table, based on user identities. This security feature lets you create policies that dynamically filter data so that users only see the data that they are authorized to view, directly at the database level. RLS simplifies the design of applications by embedding data access logic within the database itself, thereby enhancing security and reducing the risk of accidental data exposure. It is particularly useful in multi-user environments where users need to access a common database but should only see data relevant to their role or department.

You will learn how to leverage Row-Level Security by working through three labs, which are designed to be followed in sequence

- **Introduction to Row-Level Security with a Read-Only Policy**: Start with the basics of implementing RLS by creating a read-only policy. This lab focuses on configuring RLS for different sales users, ensuring they can only access the sales data pertinent to their accounts.
  
- **Advanced Row-Level Security with an Updateable Policy**: Dive deeper into RLS by exploring an advanced scenario where different sales users, sharing the same database connection credentials, are granted permissions to not only read but also update data. This lab will guide you through the nuances of setting up a more complex, updateable policy.
  
- **Integrating Row-Level Security with a C# Client Application**: Learn how RLS policies can be applied directly to a client application written in C#. This lab demonstrates the practical implementation of RLS in real-world applications, showcasing how to secure data access at the row level from within application code.

Through these labs, you will gain hands-on experience in configuring and applying Row-Level Security, enabling you to implement robust data access controls in your SQL Server databases and applications.

___

[Lab: Row-Level Security (RLS) - Read-Only Policy ▶](https://github.com/lennilobel/sql2022-workshop-hol/blob/main/HOL/3.%20Security%20Features/3.%20Row%20Level%20Security/1.%20Read-Only%20RLS%20Policy.md)
