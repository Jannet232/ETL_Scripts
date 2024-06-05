rem state parameters used for this additional transformation of the hierarchy data
echo SQL Server: !sqlserver!
echo Database name: !databaseName!
echo Schema name: !schemaName!
echo Source table: !sourceTableName!
echo Intermediate table: !intermediateTableName!
echo Target table: !targetTableName!
echo batchFilePath: !batchFilePath!

rem 
echo Applying additional transformations for hierarchy check data. This can take up to 2 minutes.

echo Transforming a usable manager_employee_id based on manager_user_sys_id and user_employee_id fields.
rem Create a stored procedure, using variable/parameters are defined during script execution, using pre-defined .sql file
sqlcmd -S %sqlserver% -d %databaseName% -E -i %batchFilePath%\stored_proc_transformed_hierarchy.sql 

rem Create an EMPTY .csv file corresponding to the intermediate table name to enable Data Purge and DROP TABLE from the SQL SERVER 
copy /y NUL %folderPath%\%intermediateTableName%.csv >NUL

sqlcmd -S %sqlserver% -d %databaseName% -E -Q "Execute stored_proc_transformed_hierarchy;"

echo Transforming a hierarchy_level column
sqlcmd -S %sqlserver% -d %databaseName% -E -i %batchFilePath%\stored_proc_hierarchy_check_with_levels.sql 

rem Create an EMPTY .csv file corresponding to the target table name to enable Data Purge and DROP TABLE from the SQL SERVER 
copy /y NUL %folderPath%\%targetTableName%.csv >NUL

sqlcmd -S %sqlserver% -d %databaseName% -E -Q "Execute stored_proc_hierarchy_check_with_levels;"

endlocal
