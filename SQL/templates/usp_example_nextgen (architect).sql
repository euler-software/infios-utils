USE [AAD]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_example]
     @in_wh_id           NVARCHAR(10)
    ,@in_hu_id           NVARCHAR(22)
    ,@out_sys_shortmsg   NVARCHAR(100) OUTPUT
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
        SET @out_sys_shortmsg = 'Err LP Not Found';
        RETURN;
    END;

    IF @hu_type = 'IV'
    BEGIN
        PRINT('HU type IV');
    END
    ELSE
    BEGIN
        SET @out_sys_shortmsg = 'Err Invalid HU Type';
        RETURN;
    END

	BEGIN TRANSACTION

	UPDATE t_hu_master
	SET type = 'X'
	WHERE wh_id = @in_wh_id
    AND hu_id = @in_hu_id

	COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    SET @error_msg = CONCAT('(Error Number: ', ERROR_NUMBER(),
                            ', Procedure: ', OBJECT_NAME(@@PROCID),
                            ', Line Number: ', ERROR_LINE(),
                            ', Error Message: ', ERROR_MESSAGE(), ')');

    EXEC dbo.usp_log_console_message 1, @error_msg;

    -- Handle deadlock error
    IF ERROR_NUMBER() = 1205
    BEGIN
        PRINT @error_msg;
        THROW; -- Throw unformatted deadlock error to Architect to be caught. Must be unformatted to be caught.
    END
    ELSE
    BEGIN;
      THROW 50000, @error_msg, 1; -- Throw formatted error to Architect for logging. Errors nest if multiple sprocs are involved.
    END;
END CATCH
GO

-- Grant
GRANT EXECUTE ON dbo.usp_example TO AAD_USER, WA_USER;
GO