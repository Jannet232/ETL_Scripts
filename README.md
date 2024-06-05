# Data Governance Tooling Project: Collibra Data Quality Non-Standard Data Source Integration

## Overview
This project aims to facilitate data movement and preparation for analysis in **Collibra Data Quality** (Collibra DQ) via an intermediary SQL Server with a JDBC connector. The process involves several batch files and PowerShell scripts and relies on SQL Server stored procedures to ensure data is ready for DQ Analysis in Collibra DQ.

## Execution Steps
### Using these files in DEV
0. Place these files in the following location: C:\Scripts\Dev 
1. Right+click on each file properties and unblock these files if you are CERTAIN they have not been tampered with.
2. If you are applying the additional hierarchy_check data transform, ensure the stored_proc_hierarchy_check_with_levels.sql and target table names are valid.
3. In the DEV environment, the process is not setup with task scheduler. Manually execute 1.Automate_Data_Purge_SQLServer.bat by double-click to clean the files.
4. Manually execute 2.Automation_Data_Load_SQLServer.bat to load the .csv files into the SQL Server. This particular .bat file will call the other scripts.
5. stored_proc_hierarchy_check_with_levels.sql is hard-coded. It requires the @CEO_Employee_ID to be defined for PROD, the database, schema and target table.

### Using these files in PROD
0. Place these files in the following location: \\hq.local\apps$\PRD\SFTP\Collibra_DQ_People
1. Right+click on each file properties and unblock these files if you are CERTAIN they have not been tampered with.
2. If you are applying the additional hierarchy_check data transform, ensure the stored_proc_hierarchy_check_with_levels.sql and target table names are valid. target table name must be the same in the stored_proc and in the .bat script
3. In PROD setup a basic task in task schedular to execute 1.Automate_Data_Purge_SQLServer.bat at the agreed start time.
4. In PROD, follow the execution of 2.Automation_Data_Load_SQLServer.bat to load the .csv files into the SQL Server. This particular .bat file will call various other scripts. If the hierarchy_check transform is applied, this process can take up to 3 minutes to complete. 

## Project Components

### 1. 1.Automate_Data_Purge_SQLServer.bat
- **Purpose**: Implementation script to drop existing tables in the target database.
- **Parameters**:
    - `folderPath`: Path to the directory containing CSV files.
    - `databaseName`: Name of the target database (in production).
    - `schemaName`: Target schema (e.g., `dbo`).
    - `sqlserver`: SQL Server hostname.

### 2. 2.Automation_Data_Load_SQLServer.bat
- **Purpose**: Loop through CSV files, create variables, and call an ETL script.
- **Parameters**: Same as in 1.Automate_Data_Purge_SQLServer.bat.

### 3. clean_file.ps1
- **Purpose**: Clean CSV files and create cleaned and upload versions.
- **Parameters**:
    - `$folderPath`: Folder path.
    - `$inputFile`: Input CSV file.
    - `$cleanedFile`: Cleaned CSV file.
    - `$uploadFile`: Upload CSV file.

### 4. create_consistent_table_schema_ddl.ps1
- **Purpose**: Generate CREATE TABLE DDL based on CSV headers.
- **Parameters**:
    - `$folderPath`: Folder path.
    - `$tableName`: Target table name.
    - `$uploadFile`: Upload CSV file.
    - `$createTableDDL`: Output DDL file.

### 5. etl_script.bat
- **Purpose**: Execute PowerShell scripts and SQL commands.
- **Parameters**: Same as in 1.Automate_Data_Purge_SQLServer.bat.

### 6. transform_hierarchy_check_script.bat
- **Purpose**: This file creates/executes a stored prod to apply Recursive 1:M Data Modelling to the hiarchy data AND produces an EMPTY .csv file used by '1.Automate_Data_Purge_SQLServer.bat'.
- **Parameters**:
    - `databaseName`: Name of the target database (in production).
    - `schemaName`: Target schema (e.g., "dbo").
    - `sqlserver`: SQL Server hostname.
    - `sourceTableName`: Source table name. I.e., "report_DQ_Hierarchy_Check"
    - `targetTableName`: Target table name. I.e., "table_hierarchy_check_with_levels"
- **Outputs**:
    - `Chairman_Employee_ID`: This is the seed employee_ID used to build out the hierarchy, it is required for applying the Recursive 1:M data modelling

### 7. stored_proc_hierarchy_check_with_levels.sql
- **Purpose**: This file contains the Recursive 1:M logic in a SQL DDL to transform and apply a hierarchy level to the employee data.
- **Parameters**: This DDL assumes the following:
    - The schema this stored procedure will be created in, is the ServiceAccount (or Users) own personal schema. 
    - Variables are passed along from the .bat session calling SQLCMD: $(databaseName),$(schemaName),$(sourceTableName), $(targetTableName), $(Chairman_Employee_ID)
