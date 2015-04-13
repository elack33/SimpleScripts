/*///////////////////////////////////////////////////////////////
/ This script creates a table, a trigger						/
/ to help facilitate the updating of Aliases					/
/////////////////////////////////////////////////////////////////
*/

--SET DB Name here:
USE DBNAME
GO

--Create Table 
IF OBJECT_ID ('[dbo].[COMPANY_AliasExport]', 'U') IS NOT NULL
   DROP TABLE [dbo].[COMPANY_AliasExport];
GO

CREATE TABLE COMPANY_AliasExport
(ItemLookupCode nvarchar(25), Alias nvarchar(25));

--Create Trigger for Alias Table
IF OBJECT_ID ('[dbo].[tr_COMPANY_Alias_Export]', 'TR') IS NOT NULL
   DROP TRIGGER [dbo].[tr_COMPANY_Alias_Export];
GO

CREATE TRIGGER [dbo].[tr_COMPANY_Alias_Export]
ON [dbo].[Alias]
AFTER INSERT

AS 
BEGIN

	INSERT INTO COMPANY_AliasExport
		SELECT DISTINCT Item.ItemLookUpCode, inserted.Alias  
			FROM inserted
			INNER JOIN Item
			on Item.ID = inserted.Itemid
			LEFT OUTER JOIN deleted
			ON inserted.ItemID = deleted.ItemID;

END







