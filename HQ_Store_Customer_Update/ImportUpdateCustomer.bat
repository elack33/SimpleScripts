:: This batch file will update Customer.ID fields in the HQ Database to match the Customer.HQID 
:: field and then use BCP to export the customer records .csv file
:: Created by New West Technology 
	
	@ECHO OFF
	
:: Set the Server Name, DB Name, User name and Password here (no spaces by the =): 
	SET Server=
	SET DBName=
	SET DBUser=
	SET DBpass=

:: Set the EXPORT mismatch customer File name (please make it unique for each store) and Path here:
	SET FileName=C:\Test\CustMisMatchHQIDList.csv
	
:: Run Stored Procedure to UPDATE Customer.ID to match Customer.HQID
	sqlcmd -Q "SET NOCOUNT ON; EXEC sp_company_ImportUpdateCustomer" -S %Server% -d %DBName% -U %DBUser% -P %DBPass% -X -t 3600 -b

:: Insert DB Name into SELECT Query for BCP to use
:: Simple query that just pulls data with NULLS
    SET QUERY=SELECT HQID, AccountNumber, FirstName,LastName, Company FROM %DBName%.dbo.company_CustomerMatch0

:: Start piecing together BCP command.
	SET bcpCommand=bcp "%Query%" queryout %FileName% -S %Server% -U %DBUser% -P %DBPass% -c -t, 
::	ECHO %bcpCommand%
	%bcpCommand%

:: Export a list that compares the number of Mismatched HQIDs from the CustomerMatch table to the customer table

:: Set the EXPORT Count and compare HQID form custom tables to Customer table (please make it unique for each store) and Path here:
	SET FileName2=C:\Test\CustHQIDCompareCount.csv
	
:: Simple query that just pulls data with NULLS
    SET QUERY=SELECT TableName, HQIDMisMatchCount FROM %DBName%.dbo.company_CustomerCompare

:: Start piecing together BCP command.
	SET bcpCommand=bcp "%Query%" queryout %FileName2% -S %Server% -U %DBUser% -P %DBPass% -c -t, 
::	ECHO %bcpCommand%
	%bcpCommand%

:: Clean up the DB and drop all tables.
	sqlcmd -Q "DROP TABLE dbo.company_CustomerMatch0" -S %Server% -d %DBName% -U %DBUser% -P %DBPass% -X -t 3600 -b
	sqlcmd -Q "DROP TABLE dbo.company_CustomerCompare" -S %Server% -d %DBName% -U %DBUser% -P %DBPass% -X -t 3600 -b

