:: This batch file will update Customer.ID fields in the HQ Database to
:: match the Customer.HQID fiels and then 
:: use BCP to create the export .csv file
:: Created by New West Technology - D.Wright 04-22-15
	
	@ECHO OFF
	
:: Set the Server Name, DB Name, User name and Password here (no spaces by the =): 
	SET Server=
	SET DBName=
	SET DBUser=
	SET DBpass=
:: Set the File name (please make it unique for each store) and Path here:
	SET FileName=C:\Test\HQCustomerList.csv
	
:: Run Stored Procedure to UPDATE Customer.ID to match Customer.HQID
	sqlcmd -Q "SET NOCOUNT ON; EXEC sp_company_HQCustomerIDUpdate" -S %Server% -d %DBName% -U %DBUser% -P %DBPass% -X -t 3600 -b

:: Insert DB Name into SELECT Query for BCP to use
:: Simple query that just pulls data with NULLS
    SET QUERY=SELECT HQID, AccountNumber, FirstName,LastName, Company FROM %DBName%.dbo.Customer

:: Start piecing together BCP command.
	SET bcpCommand=bcp "%Query%" queryout %FileName% -S %Server% -U %DBUser% -P %DBPass% -c -t, 
::	ECHO %bcpCommand%
	%bcpCommand%

