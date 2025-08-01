DECLARE
    @table_name NVARCHAR(128) = 't_whse', -- INSERT TABLE NAME HERE ⚠️
    --@filter NVARCHAR(MAX) = 'WHERE wh_id = ''WH1'' AND asn_number = ''00000000000000000001''', -- INSERT YOUR FILTER HERE ⚠️
    @filter NVARCHAR(MAX) = 'WHERE 1 = 1', -- IF YOU WANT ALL DATA, WITH NO FILTER, USE THIS FILTER AND COMMENT THE ABOVE ⚠️

    @csv_column NVARCHAR(MAX),
    @quoted_data NVARCHAR(MAX),
    @statement NVARCHAR(MAX),
    @table_exists INT

/*
    📦 Utility script by Euler Software → https://euler.software
    📝 This script generates INSERT statements from a table's data on SQL Server.

    🔧 How to use:
    1 - Enter @table_name (table must exist in current database)
    2 - Enter @filter to specify which data to export
    3 - Run the script
    4 - Copy the generated INSERT statements
    5 - Paste it in your destination database
    6 - Enjoy your data migration! 🎉

    ⚠️  Security Note: Ensure @table_name and @filter contain trusted input only
*/

-- Validate table exists
SELECT @table_exists = COUNT(*)
FROM sys.tables
WHERE name = @table_name

IF @table_exists = 0
BEGIN
    PRINT 'ERROR: Table ''' + @table_name + ''' does not exist in the current database.'
    RETURN
END

-- Build column list (excluding identity columns)
SELECT @csv_column = STUFF(
    (
        SELECT ',' + QUOTENAME(sys.all_columns.name)
        FROM sys.all_columns
        WHERE object_id = OBJECT_ID(@table_name)
        AND is_identity != 1
        ORDER BY column_id
        FOR XML PATH('')
    ), 1, 1, ''
)

-- Build data selection with proper NULL handling and data type considerations
SELECT @quoted_data = STUFF(
    (
        SELECT ' + ISNULL('''''''' + REPLACE(CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)), '''''''', '''''''''''') + '''''''', ''NULL'') + '','' + '
        FROM sys.all_columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@table_name)
        AND c.is_identity != 1
        ORDER BY c.column_id
        FOR XML PATH('')
    ), 1, 3, ''
)

-- Remove trailing comma and plus
SET @quoted_data = LEFT(@quoted_data, LEN(@quoted_data) - 5)

-- Build the final SELECT statement
SELECT @statement = 'SELECT ''INSERT INTO ' + QUOTENAME(@table_name) + '(' + @csv_column + ') VALUES('' + ' + @quoted_data + ' + '')'' AS Insert_Scripts FROM ' + QUOTENAME(@table_name) + ' ' + ISNULL(@filter, '')

-- Debug output (uncomment to see generated components)
--SELECT @csv_column AS csv_column, @quoted_data AS quoted_data, @statement AS statement

PRINT 'Executing query to generate INSERT statements...'
PRINT 'Table: ' + @table_name
PRINT 'Filter: ' + ISNULL(@filter, 'No filter (all rows)')

EXECUTE (@statement)

SET NOCOUNT OFF


