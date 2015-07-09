/*///////////////////////////////////////////////////////////////
/ This script will be used to compare Customer HQIDs with an	/
/ imported list from HQ, and update the HQID of any customer  	/
/ account matches found.										/
/ Authored by Dar Wright										/
/////////////////////////////////////////////////////////////////
*/

IF OBJECT_ID('[dbo].[sp_company_ImportUpdateCustomer]') IS NOT NULL
	DROP PROCEDURE [dbo].[sp_company_ImportUpdateCustomer]
GO

CREATE PROCEDURE [dbo].[sp_company_ImportUpdateCustomer]
AS
BEGIN

--Create and populate company_CustomerMatch0 Table
	IF OBJECT_ID('[dbo].[company_CustomerMatch0]', 'U') IS NOT NULL
		DROP TABLE [dbo].[company_CustomerMatch0]

	CREATE TABLE company_CustomerMatch0 (
		HQID INT, 
		AccountNumber NVarChar(20), 
		FirstName NVarchar(30),
		LastName NVarChar(50), 
		Company NVarChar(50)
	);

	BULK INSERT company_CustomerMatch0
	   FROM 'C:\test\HQCustomerList.csv'
	   WITH (
		  DATAFILETYPE = 'char',
		  FIELDTERMINATOR = ',',
		  KEEPNULLS
	   );

-- Create and populate company_CustomerMatch4 
-- by comparing AccountNumber, FirstName, LastName, Company from company_CustomerMatch0 table to Customer Table
-- inserting matching records into company_CustomerMatch4 and Deleting Matches from company_CustomerMatch0


	CREATE TABLE #company_CustomerMatch4 (
		HQID INT, 
		AccountNumber NVarChar(20), 
		FirstName NVarchar(30),
		LastName NVarChar(50), 
		Company NVarChar(50)
	);

	INSERT INTO #company_CustomerMatch4
		SELECT HQID, AccountNumber, FirstName, LastName, Company FROM company_CustomerMatch0 AS C0
		WHERE AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = C0.AccountNumber)
		AND FirstName IN
			(SELECT FirstName FROM Customer AS Cust WHERE Cust.FirstName = C0.FirstName)
		AND LastName IN
			(SELECT LastName FROM Customer AS Cust WHERE Cust.LastName = C0.LastName)
		AND Company IN
			(SELECT Company FROM Customer AS Cust WHERE Cust.Company = C0.Company);

	DELETE FROM company_CustomerMatch0
		WHERE AccountNumber IN 
			(SELECT AccountNumber FROM #company_CustomerMatch4 AS C4 WHERE company_CustomerMatch0.AccountNumber = C4.AccountNumber)
		AND FirstName IN 
			(SELECT FirstName FROM #company_CustomerMatch4 AS C4 WHERE company_CustomerMatch0.FirstName = C4.FirstName)
		AND LastName IN 
			(SELECT LastName FROM  #company_CustomerMatch4 AS C4 WHERE company_CustomerMatch0.LastName = C4.LastName)
		AND Company IN 
			(SELECT Company FROM   #company_CustomerMatch4 AS C4 WHERE company_CustomerMatch0.Company = C4.Company);

-- Create and populate company_CustomerMatch3 
-- by comparing AccountNumber, FirstName, LastName from company_CustomerMatch0 table to Customer Table
-- inserting matching records into company_CustomerMatch3 and Deleting Matches from company_CustomerMatch0


	CREATE TABLE #company_CustomerMatch3 (
		HQID INT, 
		AccountNumber NVarChar(20), 
		FirstName NVarchar(30),
		LastName NVarChar(50), 
	);

	INSERT INTO #company_CustomerMatch3
		SELECT HQID, AccountNumber, FirstName, LastName FROM company_CustomerMatch0 AS C0
		WHERE AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = C0.AccountNumber)
		AND FirstName IN
			(SELECT FirstName FROM Customer AS Cust WHERE Cust.FirstName = C0.FirstName)
		AND LastName IN
			(SELECT LastName FROM Customer AS Cust WHERE Cust.LastName = C0.LastName);

	DELETE FROM company_CustomerMatch0
		WHERE AccountNumber IN 
			(SELECT AccountNumber FROM #company_CustomerMatch3 AS C3 WHERE company_CustomerMatch0.AccountNumber = C3.AccountNumber)
		AND FirstName IN 
			(SELECT FirstName FROM #company_CustomerMatch3 AS C3 WHERE company_CustomerMatch0.FirstName = C3.FirstName)
		AND LastName IN 
			(SELECT LastName FROM #company_CustomerMatch3 AS C3 WHERE company_CustomerMatch0.LastName = C3.LastName);

-- Create and populate company_CustomerMatch2 
-- by comparing AccountNumber, FirstName OR AccountNumber, LastName from company_CustomerMatch0 table to Customer Table
-- inserting matching records into company_CustomerMatch2 and Deleting Matches from company_CustomerMatch0


	CREATE TABLE #company_CustomerMatch2 (
		HQID INT, 
		AccountNumber NVarChar(20), 
		FirstName NVarchar(30),
		LastName NVarChar(50), 
	);

	INSERT INTO #company_CustomerMatch2
		SELECT HQID, AccountNumber, FirstName, LastName FROM company_CustomerMatch0 AS C0
		WHERE ( AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = C0.AccountNumber)
		AND FirstName IN
			(SELECT FirstName FROM Customer AS Cust WHERE Cust.FirstName = C0.FirstName) )
		OR ( AccountNumber IN 
				(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = C0.AccountNumber)
			AND LastName IN
				(SELECT LastName FROM Customer AS Cust WHERE Cust.LastName = C0.LastName) );

	DELETE FROM company_CustomerMatch0
		WHERE ( AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = company_CustomerMatch0.AccountNumber)
		AND FirstName IN
			(SELECT FirstName FROM Customer AS Cust WHERE Cust.FirstName = company_CustomerMatch0.FirstName) )
		OR ( AccountNumber IN 
				(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = company_CustomerMatch0.AccountNumber)
			AND LastName IN
				(SELECT LastName FROM Customer AS Cust WHERE Cust.LastName = company_CustomerMatch0.LastName) );

-- Create and populate company_CustomerMatch1 
-- by comparing AccountNumber from company_CustomerMatch0 table to Customer Table
-- inserting matching records into company_CustomerMatch1 and Deleting Matches from company_CustomerMatch0

	
	CREATE TABLE #company_CustomerMatch1 (
		HQID INT, 
		AccountNumber NVarChar(20), 
	);

	INSERT INTO #company_CustomerMatch1
		SELECT HQID, AccountNumber FROM company_CustomerMatch0 AS C0
		WHERE ( AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = C0.AccountNumber)
			);

	DELETE FROM company_CustomerMatch0
		WHERE ( AccountNumber IN 
			(SELECT AccountNumber FROM Customer AS Cust WHERE Cust.AccountNumber = company_CustomerMatch0.AccountNumber) 
			);

--Create table and count how many HQID Mismatches there are in each company_CustomerMatch tables vs Customer Table
	IF OBJECT_ID('[dbo].[company_CustomerCompare]', 'U') IS NOT NULL
		DROP TABLE [dbo].[company_CustomerCompare]

	CREATE TABLE company_CustomerCompare (
			TableName NVarChar(20), 
			HQIDMisMatchCount INT, 
		);

	DECLARE @Match0CompareCount INT =
	 (SELECT COUNT(*) FROM company_CustomerMatch0 AS C0 WHERE C0.HQID NOT IN (SELECT HQID FROM Customer));
	DECLARE @Match1CompareCount INT =
	 (SELECT COUNT(*) FROM #company_CustomerMatch1 AS C1 WHERE C1.AccountNumber NOT IN (SELECT AccountNumber FROM Customer));
	DECLARE @Match2CompareCount INT =
	 (SELECT COUNT(*) FROM #company_CustomerMatch2 AS C2 WHERE C2.HQID NOT IN (SELECT HQID FROM Customer));
	DECLARE @Match3CompareCount INT =
	 (SELECT COUNT(*) FROM #company_CustomerMatch3 AS C3 WHERE C3.HQID NOT IN (SELECT HQID FROM Customer));
	DECLARE @Match4CompareCount INT =
	 (SELECT COUNT(*) FROM #company_CustomerMatch4 AS C4 WHERE C4.HQID NOT IN (SELECT HQID FROM Customer));

	INSERT INTO company_CustomerCompare (TableName, HQIDMisMatchCount)
	VALUES  ('CustomerMatch0', @Match0CompareCount ),
			('CustomerMatch1', @Match1CompareCount),
			('CustomerMatch2', @Match2CompareCount),
			('CustomerMatch3', @Match3CompareCount),
			('CustomerMatch4', @Match4CompareCount);

--Update the store Customer HQID with the HQID from the CustomerMatch1,2,3,4 tables.

	UPDATE Customer
	SET Customer.HQID = C4.HQID
	FROM Customer AS Cu
		INNER JOIN #company_CustomerMatch4 AS C4
			ON Cu.AccountNumber = C4.AccountNumber;
	UPDATE Customer
	SET Customer.HQID = C3.HQID
	FROM Customer AS Cu
		INNER JOIN #company_CustomerMatch3 AS C3
			ON Cu.AccountNumber = C3.AccountNumber;
	UPDATE Customer
	SET Customer.HQID = C2.HQID
	FROM Customer AS Cu
		INNER JOIN #company_CustomerMatch2 AS C2
			ON Cu.AccountNumber = C2.AccountNumber;
	UPDATE Customer
	SET Customer.HQID = C1.HQID
	FROM Customer AS Cu
		INNER JOIN #company_CustomerMatch1 AS C1
			ON Cu.AccountNumber = C1.AccountNumber;
END