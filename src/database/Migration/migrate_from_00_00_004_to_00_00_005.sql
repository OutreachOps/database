CREATE PROCEDURE migrate_from_00_00_004_to_00_00_005
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

        IF (@major = 0 and @minor = 0 and @revision = 4)

        BEGIN
            CREATE TABLE dbo.Tournaments
            (
                [Id] [int] IDENTITY(1,1) NOT NULL,
                [Description] nvarchar(256) NOT NULL,
                [Type] nvarchar(256) NOT NULL,
                [Status] nvarchar(128) NOT NULL,
                [TournamentCreateTime] [datetime2] NOT NULL DEFAULT GETUTCDATE(),
                [TournamentEndTime] [datetime2]
                CONSTRAINT pk_Tournaments PRIMARY KEY ([Id])
            );

            CREATE TABLE dbo.TournamentUsers
            (
                [Id] [int] IDENTITY(1,1) NOT NULL,
                [UserId] [int] NOT NULL,
                [TournamentUsersId] [int] NOT NULL,
                [PermAdmin] bit NOT NULL,
                CONSTRAINT fk_TournamentUsers_Users foreign key (UserID) references Users(Id),
                CONSTRAINT pk_TournamentUsers PRIMARY KEY ([Id])
            );


            INSERT Versions (Major,Minor,Revision) VALUES (0,0,5)
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
Exec migrate_from_00_00_004_to_00_00_005
GO

DROP PROCEDURE migrate_from_00_00_004_to_00_00_005

GO