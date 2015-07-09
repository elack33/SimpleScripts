IF OBJECT_ID('[dbo].[sp_company_ImportUpdateCustomer]') IS NOT NULL
	DROP PROCEDURE [dbo].[sp_company_HQCustomerIDUpdate]
GO

CREATE PROCEDURE [dbo].[sp_company_HQCustomerIDUpdate]
AS
BEGIN

	--Update the Customer ID to match the HQID.
	UPDATE CU
		SET CU.ID = C1.HQID
		FROM Customer AS CU
			INNER JOIN Customer AS C1
				ON CU.AutoID = C1.AutoID
		WHERE CU.HQID <> CU.ID

END;
