/*///////////////////////////////////////////////////////////////
/ This script will be used to take the Account Balance from 	/
/ HQ Customer records and insert them as a credit into the	 	/
/ Worksheet_GlobalAccountAdjustment and create WS350 and		/
/ WS401 with approval to send the changes to a store and back	/
/ Setting the AccountBalance to the correct credit amount 		/ 
/ In both the store and HQ										/
/ Authored by D. Wright 06-04-15			/
/////////////////////////////////////////////////////////////////
*/
--Set the STORE ID you want to use here, will have to connect HQ Client to this store to complete update
DECLARE @Store INT = ;

--Create temp table to hold some data from multiple tables to make inserting easier
CREATE TABLE #Temp (
StoreID INT,
CustomerID INT,
HistoryType INT,
AcctRecAmount Money,
AcctBal Money,
TotalAmount Money,
Comment Nvarchar(50),
);

--This starts populating data into the #temp with amounts from the AcctReceive Table and the AcctBalance from Customer
INSERT INTO #Temp (AcctRecAmount, AcctBal, CustomerID)
	SELECT SUM(AR.OriginalAmount) AS SUMOrAmt, C.AccountBalance AS ActBal, C.ID 
	FROM AccountReceivable AS AR
		RIGHT OUTER JOIN Customer AS C
			ON C.ID = AR.CustomerID
	GROUP BY C.ID, C.AccountBalance

--This updates the #temp with a valid total that cancels out any previous Account Receivable Balances
--Because the insert into the GlobalAccountAdjustment table makes it a negative amount, these may look backwards
--The idea is that positive account balances are going to be imported into the customer table, they need to be credits in 
--the AccountInformation 
UPDATE #Temp 
SET TotalAmount =
	CASE
		WHEN AcctRecAmount = 0 AND AcctBal = 0 THEN 0								
		WHEN AcctRecAmount = 0 AND AcctBal > 0 THEN AcctBal							
		WHEN AcctRecAmount = 0 AND AcctBal < 0 THEN AcctBal * -1					
		WHEN AcctRecAmount < 0 AND AcctBal = 0 THEN (AcctRecAmount * -1)			
		WHEN AcctRecAmount < 0 AND AcctBal < 0 THEN (AcctRecAmount * -1) + AcctBal	
		WHEN AcctRecAmount < 0 AND AcctBal > 0 THEN (AcctRecAmount * -1) + AcctBal	
		WHEN AcctRecAmount > 0 AND AcctBal = 0 THEN (AcctRecAmount * -1)			
		WHEN AcctRecAmount > 0 AND AcctBal < 0 THEN (AcctRecAmount * -1) + AcctBal	
		WHEN AcctRecAmount > 0 AND AcctBal > 0 THEN (AcctRecAmount * -1) + AcctBal	
	END

--Update the temp table with the store id from above, and a standard comment and history type
UPDATE #Temp --(StoreID, HistoryType, Comment)
SET StoreID = @Store, 
	HistoryType = 6,
	Comment = 'AcctBal Adjusted from NWT'

--Create WS350 to be processed by the chosen store with specific title and comment info
INSERT INTO Worksheet (Style, Status, Notes, Title)
VALUES (350, 2, 'Created by NWT Balance Adjustment', 'NWT Download Global Account Adjustments')

--Insert Store ID chosen above into Worksheetstore table so that correct store processes WS
INSERT INTO WorksheetStore (WorksheetID, Status, StoreID)
SELECT TOP 1 ID, 0, @Store FROM Worksheet WHERE style = 350 AND Status = 2 ORDER BY ID Desc

--Create WS401 to be processed by the chosen store with specific title and comment info
INSERT INTO Worksheet (Style, Status, Notes, Title)
VALUES (401, 2, 'NWT 401 Redo for Balance Adjustment', 'NWT Request Data Upload')

--Insert Store ID chosen above into Worksheetstore table so that correct store processes WS
INSERT INTO WorksheetStore (WorksheetID, Status, StoreID)
SELECT TOP 1 ID, 0, @Store FROM Worksheet WHERE style = 401 AND Status = 2 ORDER BY ID Desc

--Insert data from temp table into GlobalAccountAdjustment table
INSERT INTO Worksheet_GlobalAccountAdjustment 
	(WorksheetID, StoreID, CustomerID, HistoryType, Amount, Comment)
SELECT 
(SELECT TOP 1 ID FROM Worksheet WHERE style = 350 AND Status = 2 ORDER BY ID Desc), 
	StoreID, CustomerID, HistoryType, TotalAmount, Comment FROM #Temp

--Cleanup
DROP TABLE #temp