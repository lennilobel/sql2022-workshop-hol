# Hands-On Lab: SQL Server 2022 for Developers

Welcome!

Before diving into the hands-on labs, ensure you have the necessary software and databases installed. Follow these steps to set up your environment:

1. **SQL Server 2022**: The Developer Edition of SQL Server 2022 is required for this lab. It's free for development and testing, not for production, and includes all the features of SQL Server 2022. Download and install it from [Microsoft's SQL Server Downloads page](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (right-click and open in a new tab).

2. **SQL Server Management Studio (SSMS)**: To interact with SQL Server, including running queries and managing databases, install the latest version of SSMS. This ensures compatibility with SQL Server 2022 and supports features like Always Encrypted that may not be supported in older SSMS versions. Download SSMS from [here](https://aka.ms/ssmsfullsetup) (right-click and open in a new tab).

3. **Visual Studio 2022**: Some demos, especially those involving Row-Level Security and Always Encrypted, require Visual Studio 2022. The Community Edition is free for students, open-source contributors, and individuals. Download it from [Visual Studio's Community Edition page](https://visualstudio.microsoft.com/vs/community/) (right-click and open in a new tab).

4. **AdventureWorks2019 Database**: Many demos utilize the AdventureWorks2019 sample database. Download the `AdventureWorks2019.bak` backup file available [here](https://1drv.ms/f/s!AiiTRkT0Yvc4xd8Kz1oSgzjbselEIA?e=yFaqjc) (right-click and open in a new tab).

   Then restore the backup file as follows:


 


   1. **Create a temporary folder:** First, create a temporary folder on your C drive to store the `.bak` file during the restoration process.

      1. Open File Explorer.
      2. Navigate to the C drive (C:\).
      3. Right-click in an empty space, select `New` > `Folder`, and name the new folder `HolDB`.

   2. **Copy the Backup File:** Copy the `AdventureWorks2019.bak` file from your Downloads folder to the `C:\HolDB` folder you just created.

      1. Navigate to your Downloads folder.
      2. Find the `AdventureWorks2019.bak` file.
      3. Right-click on the file and select `Copy`.
      4. Go back to the `C:\HolDB` folder, right-click in an empty space, and select `Paste`.

   3. **Restore the Database using SSMS:**    Now that the backup file is in an accessible location, you can proceed with restoring it to your SQL Server instance.

      1. Open SQL Server Management Studio (SSMS) and connect to your local SQL Server instance.
      2. In the Object Explorer on the left, expand and then right-click on the `Databases` node and select `Restore Database...`.
      2. In the Restore Database Dialog, select the `Device` radio button under the `Source` section.
      3. Click the `...` button on the right to open the Select Backup Devices dialog.
      4. Click on the `Add` button to open the Locate Backup File dialog.
      5. Navigate to the `C:\HolDB` folder and select the `AdventureWorks2019.bak` file, then click `OK`.
      6. The backup file should now appear in the Select Backup Devices dialog. Click `OK` to return to the Restore Database dialog.
      7. Now click `OK` to start the restore process.

   The restoration process will begin, and SSMS will display a progress bar. Once the process completes, a message will appear informing you that the database has been successfully restored. Click OK, and the AdventureWorks2019 database will appear in the "Databases" folder in Object Explorer.

5. **Wide World Importers Database**: One demo uses the Wide World Importers sample database. Download the `WideWorldImporters.bak` backup file file available [here](https://1drv.ms/f/s!AiiTRkT0Yvc4xd8Kz1oSgzjbselEIA?e=yFaqjc) (right-click and open in a new tab).

   Then restore the database using similar steps you just followed for AdventureWorks2019:

   1. **Copy the Backup File:** Copy the `WideWorldImports.bak` file from your Downloads folder to the `C:\HolDB` folder.

   3. **Restore the Database using SSMS:** Now that the backup file is in an accessible location, you can proceed with restoring it to your SQL Server instance.

      2. In the Object Explorer on the left, right-click on the `Databases` node and select `Restore Database...`.
      2. In the Restore Database Dialog, select the `Device` radio button under the `Source` section.
      3. Click the `...` button on the right to open the Select Backup Devices dialog.
      4. Click on the `Add` button to open the Locate Backup File dialog.
      5. Navigate to the `C:\HolDB` folder and select the `WideWorldImports.bak` file, then click `OK`.
      6. The backup file should now appear in the Select Backup Devices dialog. Click `OK` to return to the Restore Database dialog.
      7. Now click `OK` to start the restore process.

   After the restore completes successfully, the WideWorldImporters database will appear in the "Databases" folder in Object Explorer.
 
All set? [Let's get started!](https://github.com/lennilobel/sql2022-workshop-hol/tree/main/HOL)

