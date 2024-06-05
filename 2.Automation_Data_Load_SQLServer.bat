@echo off
setlocal enabledelayedexpansion

rem the parameters below should be changed to reflect folder paths, servername and databasename in Prod 
set "batchFilePath=C:\Scripts\Dev"
set "folderPath=\\dev.local\apps$\UAT\SFTP\Collibra"
set "databaseName=CollibraDQ_NonPrd"
set "schemaName=dbo"
set "sqlserver=db-collibra-dev.dev.local"
rem end of list of parameters 

rem establish a set of flags and parameters for exception handling
set "flagTransformHierarchyCheck="
set "sourceTableName="
set "intermediateTableName="
set "targetTableName="
rem end of list of flags and parameters

rem Loop through CSV files in the folder
for %%f in (%folderPath%\*.csv) do (
   
   rem Get file names without extension and path
   set "fileName=%%~nf"

   rem Create variables
   set "inputFile=%%~nf.csv"
   set "cleanedFile=%%~nf_cleaned.csv"
   set "uploadFile=%%~nf_upload.csv"
   set "tableName=%%~nf"
   set "createTableDDL=%%~nf_ddl.sql"

   call "%batchFilePath%\etl_script.bat"

   if "%%~nf"=="report_DQ_Hierarchy_Check" (
      set "flagTransformHierarchyCheck=TRUE"
   )
)

if defined flagTransformHierarchyCheck (
   set "sourceTableName=report_DQ_Hierarchy_Check"
   set "intermediateTableName=table_transformed_hierarchy"
   set "targetTableName=table_hierarchy_check_with_levels"
   call "%batchFilePath%\transform_hierarchy_check_script.bat"
) 
endlocal
