CREATE PROCEDURE migrate_from_00_00_001_to_00_00_002
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT,
        QUOTED_IDENTIFIER,
        ANSI_NULLS,
        ANSI_PADDING,
        ANSI_WARNINGS,
        ARITHABORT,
        CONCAT_NULL_YIELDS_NULL ON;
    SET NUMERIC_ROUNDABORT OFF;
 
    DECLARE @localTran bit
    IF @@TRANCOUNT = 0
    BEGIN
        SET @localTran = 1
        BEGIN TRANSACTION LocalTran
    END
 
    BEGIN TRY
 

        IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'Versions'))
        BEGIN
            DROP TABLE dbo.Versions
        END

        IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'version'))
        BEGIN
            DROP TABLE dbo.version
        END
        

		CREATE TABLE dbo.Versions
		(
			 [Id] [int] IDENTITY(1,1) NOT NULL,
			 [Major] [int] NOT NULL,
			 [Minor] [int] NOT NULL,
			 [Revision] [int] NOT NULL,
			 [VersionUpdateTime] [datetime2] NOT NULL DEFAULT GETUTCDATE(),
			 CONSTRAINT versionCK UNIQUE(major,minor,revision)  
		);

		INSERT Versions (major,minor,revision) VALUES (0,0,2); 
 
        IF @localTran = 1 AND XACT_STATE() = 1
            COMMIT TRAN LocalTran
 
    END TRY
    BEGIN CATCH
 
        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT
 
        SELECT  @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE()
 
        IF @localTran = 1 AND XACT_STATE() <> 0
            ROLLBACK TRAN
 
        RAISERROR ( @ErrorMessage, @ErrorSeverity, @ErrorState)
 
    END CATCH
 
END

GO
EXEC migrate_from_00_00_001_to_00_00_002
GO

DROP PROCEDURE migrate_from_00_00_001_to_00_00_002

GO