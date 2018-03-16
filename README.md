# Outreach Operations Database
Database for outreach operations

To build development database run .\build.ps1 from the repository root directory.  This creates a outreach_operations_dev database against a local database at '(localdb)\MSSQLLocalDB' using SQL Local DB   

The dev build process performs the folloing;  
-- Creates a database
-- Creates a database structure by migrating through all of the migrate scripts that have been used to build the production database.