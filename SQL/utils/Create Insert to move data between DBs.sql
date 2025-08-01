DECLARE @table_name NVARCHAR(MAX) = 't_asn_master',
		@filter NVARCHAR(MAX) = 'WHERE wh_id = ''WH1'' AND asn_number = ''00000000000000000001''',
		--@filter NVARCHAR(MAX) = 'WHERE 1 = 1',
		@csv_column NVARCHAR(MAX),
        @quoted_data NVARCHAR(MAX),
        @statement NVARCHAR(MAX)

/**********************************************
---- Script by https://www.euler.software/ ----
---- Steps to use: 						   ----
---- 1 - Enter @table_name				   ----
---- 2 - Enter @filter searching your data ----
---- 3 - Run to make it happens 		   ----
**********************************************/

SELECT @csv_column=STUFF
(
    (
     SELECT ',['+ name +']' FROM sys.all_columns
     WHERE object_id=object_id(@table_name) AND
     is_identity!=1 FOR XML PATH('')
    ),1,1,''
)

SELECT @quoted_data=STUFF
(
    (
     SELECT ' ISNULL(QUOTENAME('+ name +','+QUOTENAME('''','''''')+'),'+'''NULL'''+')+'','''+'+' FROM sys.all_columns
     WHERE object_id=object_id(@table_name) AND
     is_identity!=1 FOR XML PATH('')
    ),1,1,''
)

SELECT @statement='SELECT ''INSERT INTO '+@table_name+'('+@csv_column+')VALUES('''+'+'+SUBSTRING(@quoted_data,1,LEN(@quoted_data)-5)+'+'+''')'''+' Insert_Scripts FROM '+ @table_name + ' ' + @filter + ' '

--SELECT @csv_column AS csv_column,@quoted_data AS quoted_data,@statement statement

EXECUTE (@statement)

SET NOCOUNT OFF
