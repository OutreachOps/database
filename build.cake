#tool "Microsoft.SQLServer.SMO"
#r System.Data
#r Microsoft.SqlServer.ConnectionInfo
#r Microsoft.SqlServer.Smo
#r Microsoft.SqlServer.Management.Sdk.Sfc

//////////////////////////////////////////////////////////////////////
// ARGUMENTS
//////////////////////////////////////////////////////////////////////

var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");
var databaseConnectionString = Argument("devConnectionString",@"Server=(localdb)\MSSQLLocalDB;Database=Outreach_Operations_Dev;Trusted_Connection=True;");
var createDatabaseConnectionString = Argument("devConnectionString",@"Server=(localdb)\MSSQLLocalDB;Database=master;Trusted_Connection=True;");
var releasePassword = Argument("releasePassword", "Password Not Set");

//////////////////////////////////////////////////////////////////////
// PREPARATION
//////////////////////////////////////////////////////////////////////

// Define directories.
var buildDir = Directory("./src/Example/bin") + Directory(configuration);

//////////////////////////////////////////////////////////////////////
// TASKS
//////////////////////////////////////////////////////////////////////


Task("Deploy")
    .IsDependentOn("Set-Production-DatabaseString")
    .IsDependentOn("Migrate-Database")
    .Does(() =>
{
});

Task("Set-Production-DatabaseString")
   
    .Does(() =>
{
    databaseConnectionString =  string.Format("Server=tcp:outreachoperations.database.windows.net,1433;Initial Catalog=outreach_operations;Persist Security Info=False;User ID=outreachadmin;Password={0};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",releasePassword);
    
    Information(databaseConnectionString);
});


Task("Create-Dev-Database")
    .Does(() =>
{
    using (System.Data.SqlClient.SqlConnection sqlConnection = new   System.Data.SqlClient.SqlConnection(createDatabaseConnectionString))
    {
        Microsoft.SqlServer.Management.Common.ServerConnection svrConnection = new  Microsoft.SqlServer.Management.Common.ServerConnection(sqlConnection);
        Microsoft.SqlServer.Management.Smo.Server server = new Microsoft.SqlServer.Management.Smo.Server(svrConnection);

        string script = System.IO.File.ReadAllText("./src/database/create/CreateDevDatabase.sql");
        string[] singleCommand = System.Text.RegularExpressions.Regex.Split(script, "^GO", System.Text.RegularExpressions.RegexOptions.Multiline);
         System.Collections.Specialized.StringCollection scl = new  System.Collections.Specialized.StringCollection();
        foreach(string t in singleCommand)
        {
            if(t.Trim().Length > 0) scl.Add(t.Trim());
        }
        try
        {
            int[] result = server.ConnectionContext.ExecuteNonQuery(scl, Microsoft.SqlServer.Management.Common.ExecutionTypes.ContinueOnError);
            // Now check the result array to find any possible errors??
        }
		catch (Exception e)
		{
            Console.WriteLine(e.ToString());         
		
		}
        finally
        {

        }
    }      
});

Task("Migrate-Database")
    .Does(() =>
{
    var files = GetFiles("./src/database/migration/*.sql");
    foreach(var file in files)
    {
        using (System.Data.SqlClient.SqlConnection sqlConnection = new   System.Data.SqlClient.SqlConnection(databaseConnectionString))
        {
            Microsoft.SqlServer.Management.Common.ServerConnection svrConnection = new  Microsoft.SqlServer.Management.Common.ServerConnection(sqlConnection);
            Microsoft.SqlServer.Management.Smo.Server server = new Microsoft.SqlServer.Management.Smo.Server(svrConnection);

            string script = System.IO.File.ReadAllText(file.FullPath);
            Information(file.FullPath);
            string[] singleCommand = System.Text.RegularExpressions.Regex.Split(script, "^GO", System.Text.RegularExpressions.RegexOptions.Multiline);
            System.Collections.Specialized.StringCollection scl = new  System.Collections.Specialized.StringCollection();
            foreach(string t in singleCommand)
            {
                if(t.Trim().Length > 0) scl.Add(t.Trim());
            }
            try
            {
                int[] result = server.ConnectionContext.ExecuteNonQuery(scl, Microsoft.SqlServer.Management.Common.ExecutionTypes.ContinueOnError);
                // Now check the result array to find any possible errors??
            }
            finally
            {

            }
        }  
    }
});


Task("Create-Database-Dependencies")
    .Does(() =>
{
    EnsureDirectoryExists("./src/data");
  
});


//////////////////////////////////////////////////////////////////////
// TASK TARGETS
//////////////////////////////////////////////////////////////////////

Task("Default")
    .IsDependentOn("Create-Database-Dependencies")
    .IsDependentOn("Create-Dev-Database")
    .IsDependentOn("Migrate-Database");

//////////////////////////////////////////////////////////////////////
// EXECUTION
//////////////////////////////////////////////////////////////////////

RunTarget(target);
