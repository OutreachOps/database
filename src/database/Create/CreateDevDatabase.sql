USE [Master]
GO

DECLARE @dbname nvarchar(128)
SET @dbname = N'Outreach_Operations_Dev'

IF (EXISTS (SELECT name 
FROM master.dbo.sysdatabases 
WHERE ('[' + name + ']' = @dbname 
OR name = @dbname)))

	BEGIN
		DROP DATABASE [Outreach_Operations_Dev]
	END

	CREATE DATABASE [Outreach_Operations_Dev] ON  PRIMARY 
	( NAME = N'Outreach_Operations_Dev', FILENAME = N'C:\development\OODatabase\data\Outreach_Operations_Dev.mdf' , 
	SIZE = 128MB , MAXSIZE = 8GB, FILEGROWTH = 1GB )
	LOG ON 
	( NAME = N'Outreach_Operations_Dev_log', FILENAME = N'C:\development\OODatabase\data\Outreach_Operations_Dev.ldf' , 
	SIZE = 128MB , MAXSIZE = 2GB , FILEGROWTH = 10%)
GO