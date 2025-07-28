IF OBJECT_ID('dbo.usp_search_text', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_search_text;
GO

CREATE PROCEDURE dbo.usp_search_text
    @search_term VARCHAR(255)
AS
BEGIN
    /*
    🔍 usp_search_text - Find that sneaky SQL term!
    📦 Utility proc by Euler Software → https://euler.software
    */
    SET NOCOUNT ON;

    SET @search_term = UPPER(LTRIM(RTRIM(@search_term)));

    IF @search_term = ''
    BEGIN
        THROW 50001, 'search_term cannot be empty.', 1;
    END

    SELECT DISTINCT
        SCHEMA_NAME(o.schema_id) AS schema_name,
        o.name AS object_name,
        o.type_desc AS object_type,
        OBJECT_DEFINITION(o.object_id) AS object_definition
    FROM sys.sql_modules m
    INNER JOIN sys.objects o ON m.object_id = o.object_id
    WHERE UPPER(m.definition) LIKE '%' + @search_term + '%'
      AND o.type IN ('P', 'V', 'FN', 'TF', 'IF')
    ORDER BY o.type_desc, o.name;
END;
GO

-- EXEC dbo.usp_search_text 'your_search_term'