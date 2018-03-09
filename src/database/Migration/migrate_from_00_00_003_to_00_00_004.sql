CREATE PROCEDURE migrate_from_00_00_003_to_00_00_004
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
 
		DECLARE @major int 
        DECLARE @minor int
        DECLARE @revision int 
		DECLARE @maxVersionIdentiy int 
		SELECT @maxVersionIdentiy = max (Versions.Id) from Versions

        SELECT @major = Major from Versions where Id = @maxVersionIdentiy
        SELECT @minor = Minor from Versions where Id = @maxVersionIdentiy
        SELECT @revision = Revision from Versions where Id = @maxVersionIdentiy

        IF (@major = 0 and @minor = 0 and @revision = 3)

        BEGIN

            ALTER TABLE dbo.Users ADD CONSTRAINT pk_Users PRIMARY KEY (Id)

            CREATE UNIQUE INDEX Users_Idx1 ON dbo.Users (UserName DESC); 

            CREATE TABLE dbo.UserSessions
            (
                [Id] [int] IDENTITY(1,1) NOT NULL,
                [UserId] [int] NOT NULL,
                [SessionKey] nvarchar(128) NOT NULL,
                [SessionStartTime] [datetime2] NOT NULL DEFAULT GETUTCDATE(),
                CONSTRAINT ck_session UNIQUE(UserId,SessionKey) ,
                CONSTRAINT fk_Users foreign key (UserID) references Users(Id),
                CONSTRAINT pk_UserSessions PRIMARY KEY ([Id])
            );

            INSERT Versions (Major,Minor,Revision) VALUES (0,0,4); 

        END

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
Exec migrate_from_00_00_003_to_00_00_004
GO

DROP PROCEDURE migrate_from_00_00_003_to_00_00_004

GO