rem Change the SQL Server Name and File path for .sql file related to Prod instance before implementation
@echo off

rem the parameters below should be changed to reflect folder paths, servername and databasename in Prod 
set "folderPath=\\dev.local\apps$\UAT\SFTP\Collibra"
set "databaseName=CollibraDQ_NonPrd"
set "schemaName=dbo"
set "sqlserver=db-collibra-dev.dev.local"
rem end of list of parameters 

rem Loop through CSV files in the folder
for %%f in (%folderPath%\*.csv) do (
	sqlcmd -S %sqlserver% -E -Q "DROP TABLE %databasename%.%schemaName%.%%~nf"
	del /f "%%f"
)