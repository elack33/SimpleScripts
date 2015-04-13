:: This batch file will use BCP to create the AliasExport file
:: and then run a SQL Stored Procedure to remove the data from the table
	
	@ECHO OFF
	
:: Set the Server Name, DB Name, User name and Password here (no spaces by the =): 
	SET Server=SERVER
	SET DBName=Database
	SET DBUser=User
	SET DBpass=Password
:: Set the File name (please make it unique for each store) and Path here:
	SET FileName=\\192.168.2.1\shares\AliasExport\AliasExport01.csv
	
:: Insert DB Name into SELECT Query for BCP to use
	SET Query=SELECT DISTINCT * FROM %DBName%.dbo.COMPANY_AliasExport
:: Start piecing together BCP command.
	SET bcpCommand=bcp "%Query%" queryout %FileName% -S %Server% -U %DBUser% -P %DBPass% -c -t, 
::	ECHO %bcpCommand%
	%bcpCommand%

::  Run a query to clean data from table
	sqlcmd -Q "TRUNCATE TABLE dbo.COMPANY_AliasExport" -S %Server% -d %DBName% -U %DBUser% -P %DBPass% -X -t 3600 -b