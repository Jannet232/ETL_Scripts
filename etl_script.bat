rem Data in the cleaned files are then loaded to corresponding tables in SQL Server
rem A SQL Server CREATE TABLE DDL file is created corresponding to the header row in the .csv files.
rem The intermediate files created are purged from SFTP Server
rem The SQL Server CREATE TABLE DDL file is not purged.

echo folderPath: !folderPath!
echo Inputfile: !inputFile!
echo Cleanedfile: !cleanedFile!
echo Tablename: !tableName!
echo UploadFile: !uploadFile!
echo CreateTableDDL: !createTableDDL!
   
Powershell.exe -ExecutionPolicy RemoteSigned -File clean_file.ps1 %folderPath% %inputFile% %cleanedFile% %uploadFile%
Powershell.exe -ExecutionPolicy RemoteSigned -File create_consistent_table_schema_ddl.ps1 %folderPath% %schemaName% %tableName% %uploadFile% %createTableDDL%

if exist %folderPath%\%createTableDDL% (
    sqlcmd -E -S %sqlserver% -d %databaseName% -i %folderPath%\%createTableDDL%
    bcp %databaseName%.%schemaName%.%tableName% in %folderPath%\%uploadFile% -c -S %sqlserver% -F2 -t^| -r \n -T -C 65001
    del /f "%folderPath%\%cleanedFile%"
    del /f "%folderPath%\%uploadFile%"
)
endlocal
