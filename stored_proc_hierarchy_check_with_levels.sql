SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        <Author,,Nathan Duong>
-- Create date: <Create Date,,09/05/2024>
-- Description:    <Description,, This procedure appends a hierarchy level to the employee data. 
--                  Any orphans are assigned to the NULL hierarchy level. 
--                  This .sql uses $(variables) to be defined via SQLCMD at point of execution. 
--                  See Jira Issue DG-2471.>
-- =============================================
CREATE OR ALTER PROCEDURE stored_proc_hierarchy_check_with_levels --defaulting to the schema of the script executor (intended to be a Service Account)
AS
BEGIN

    WITH transformed_hierarchy_active_employees AS (
        SELECT 
            *
        FROM $(databaseName).$(schemaName).$(intermediateTableName)
        WHERE Employee_Status = 'Active' --hierarchy levels can only be assigned based on a complete chain of active employees
    ),
    seed AS (
        SELECT DISTINCT
            *,
            0 AS hierarchy_level
        FROM
            transformed_hierarchy_active_employees
        WHERE Employee_Status = 'Active' AND Manager_User_Sys_ID = 'No_MANAGER' --identify Chairman; top of the hierarchy.
    ),
    tree AS (
        SELECT
            root.*,
            1 AS hierarchy_level
        FROM transformed_hierarchy_active_employees root
        JOIN seed
            ON root.Manager_Employee_ID = seed.Employee_ID

        UNION ALL

        SELECT
            node.*,
            tree.hierarchy_level + 1 AS hierarchy_level
        FROM transformed_hierarchy_active_employees node
        JOIN tree
            ON node.Manager_Employee_ID = tree.Employee_ID
    ),
    hierarchy_data AS (
        SELECT * FROM seed
        UNION ALL
        SELECT * FROM tree
    ),
    orphaned_data AS (
        SELECT
            *,
            NULL AS hierarchy_level
        FROM
            transformed_hierarchy_active_employees
        WHERE Employee_ID NOT IN (
            SELECT DISTINCT Employee_ID FROM hierarchy_data
        )
    ),
    unioned_hierarchy_data AS (
        SELECT * FROM hierarchy_data
        UNION ALL
        SELECT * FROM orphaned_data
    )

    SELECT
        *
    INTO $(databaseName).$(schemaName).$(targetTableName)
    FROM unioned_hierarchy_data;
END
GO
