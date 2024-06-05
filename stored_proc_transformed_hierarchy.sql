SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Nathan Duong>
-- Create date: <Create Date,,09/04/2024>
-- Description:    <Description,, This adds the 'Manager_Employee_ID' column, based on the valid/usable 'employee_id' field to replace the unusable 'manager_user_sys_id' value
--                  This .sql uses $(variables) to be defined via SQLCMD at point of execution. 
--                  See Jira Issue DG-2727.>
-- =============================================
CREATE OR ALTER PROCEDURE stored_proc_transformed_hierarchy --defaulting to the schema of the script executor (intended to be a Service Account)
AS
BEGIN

    SELECT 
        main.*,
        second.Employee_ID AS Manager_Employee_ID,
        second.Employee_Status AS Manager_Employee_Status
    INTO $(databaseName).$(schemaName).$(intermediateTableName) --intermediate table containing transformed column
    FROM $(databaseName).$(schemaName).$(sourceTableName) main
    LEFT JOIN $(databaseName).$(schemaName).$(sourceTableName) second
    ON main.Manager_User_Sys_ID = second.User_Employee_ID

END
GO
