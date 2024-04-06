# Hands-On Lab: SQL Server 2022 for Developers

Welcome!

Before diving into the hands-on labs, ensure you have the necessary software and databases installed. Follow these steps to set up your environment:

1. **SQL Server 2022**: The Developer Edition of SQL Server 2022 is required for this lab. It's free for development and testing, not for production, and includes all the features of SQL Server 2022. Download and install it from [Microsoft's SQL Server Downloads page](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (right-click and open in a new tab).

2. **SQL Server Management Studio (SSMS)**: To interact with SQL Server, including running queries and managing databases, install the latest version of SSMS. This ensures compatibility with SQL Server 2022 and supports features like Always Encrypted that may not be supported in older SSMS versions. Download SSMS from [here](https://aka.ms/ssmsfullsetup) (right-click and open in a new tab).

3. **Visual Studio 2022**: Some demos, especially those involving Row-Level Security and Always Encrypted, require Visual Studio 2022. The Community Edition is free for students, open-source contributors, and individuals. Download it from [Visual Studio's Community Edition page](https://visualstudio.microsoft.com/vs/community/) (right-click and open in a new tab).

4. **AdventureWorks2019 Database**: Many demos utilize the AdventureWorks2019 sample database. Download the `AdventureWorks2019.bak` backup file available from [Microsoft's documentation page](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms) (right-click and open in a new tab).

   Then restore the backup file as follows:

   1. **Open SSMS and Connect:** Launch SQL Server Management Studio and connect to your local SQL Server instance.

   2. **Navigate to 'Databases':** In Object Explorer on the left, expand the server node and right-click on the "Databases" folder, then select "Restore Database..."

   3. **Select Backup Source:** In the Restore Database window, choose the "Device" radio button under "Source", click the button with three dots to open "Select backup devices", click "Add", navigate to your Downloads folder, select AdventureWorks2019.bak, and click "OK".

    4. **Set Destination Database:** In the "Destination" section, enter "AdventureWorks2019" in the "Database" field for the name of the restored database.

    5. **Choose Backup Set:** Ensure the backup set to restore is checked under "Select the backup sets to restore". This should auto-populate based on the selected .bak file.

   8. **Initiate the Restore:** Click "OK" to start the restoration. This may take a few minutes, and you'll see a success message once complete. The AdventureWorks2019 database will appear in the "Databases" folder in Object Explorer.


5. **Wide World Importers Database**: One demo uses the Wide World Importers sample database. Download the `WideWorldImporters-Full.bak` backup file file found on the [GitHub releases page for SQL Server samples](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0) (right-click and open in a new tab).

   Then restore the database using the same steps you just followed for AdventureWorks2019, with the only difference being that when you select the backup file, you'll choose `WideWorldImporters.bak` from your Downloads folder. Just follow the instructions as previously described, substituting the name "WideWorldImporters" wherever "AdventureWorks2019" was used.

All set? [Let's get started!](https://github.com/lennilobel/sql2022-workshop-hol/tree/main/HOL)

