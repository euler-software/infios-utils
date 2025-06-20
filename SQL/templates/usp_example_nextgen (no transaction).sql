USE [AAD]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_example]
     @in_wh_id           NVARCHAR(10)
    ,@in_hu_id           NVARCHAR(22)
AS

SET NOCOUNT ON;

DECLARE
   @error_msg            NVARCHAR(MAX)
  ,@hu_id                NVARCHAR(22)
  ,@hu_type              NVARCHAR(2)

BEGIN TRY
    SELECT @hu_id = hu_id
          ,@hu_type = type
    FROM t_hu_master
    WHERE wh_id = @in_wh_id
    AND hu_id = @in_hu_id

    IF @@ROWCOUNT = 0
    BEGIN
        SET @error_msg = CONCAT('LP [', @in_hu_id, '] not found.');
        THROW 50000, @error_msg, 1;
    END

    IF @hu_type = 'IV'
    BEGIN
        PRINT('HU type IV');
    END
    ELSE
    BEGIN
        SET @error_msg = CONCAT('Invalid HU Type to LP [', @in_hu_id, '].');
        THROW 50000, @error_msg, 1;
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    SET @error_msg = CONCAT('(Error Number: ', ERROR_NUMBER(),
                            ', Procedure: ', OBJECT_NAME(@@PROCID),
                            ', Line Number: ', ERROR_LINE(),
                            ', Error Message: ', ERROR_MESSAGE(), ')');

    EXEC dbo.usp_log_console_message 1, @error_msg;

    THROW 50000, @error_msg, 1;
END CATCH
GO

-- Grant
GRANT EXECUTE ON dbo.usp_example TO WEBWISE, AAD_USER, WA_USER;
GO