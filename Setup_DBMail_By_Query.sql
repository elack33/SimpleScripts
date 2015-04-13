/*///////////////////////////////////////////////////////////////
/ This script creates will help enable and setup				/
/ DB Mail using queries.										/
/////////////////////////////////////////////////////////////////
*/

--Enable DataBase Mail

USE msdb
GO
--Enable advanced options
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
--Enable Database Mail
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO
--Disable advanced options
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;

--You may have to run this in pieces, by sections.

--First please create a new Credential under Security
	--PLEASE NOTE: the Identity User should have admin access
--This should have the same profile name and the password of the email account are settings up.
	--There is no other way to store the email account password.
--Right click the new Credential and goto Facets and find the ID, then enter it below:
DECLARE @CredentialID int = 65536;

--Enter other variable data below
DECLARE 
	@name nvarchar(50) = 'Unique Name',
	@descrip nvarchar(50) = 'Description',
	@emailAdd nvarchar(100) = 'Example@none.com',
	@displayName nvarchar(100) = 'Jon Doe',
	@replyAdd nvarchar(100) = 'ReplyExample@none.com',
	@lastModUser nvarchar(50) = 'sa',
	@serverType nvarchar(20) = 'SMTP',
	@serverName nvarchar(50) = 'smtp.gmail.com',
	@port smallint = 587,
	@username nvarchar(50) = 'User@gmail.com';
	
----------------------

USE msdb
--Configure mail account
INSERT INTO sysmail_account (name, description, email_address, display_name, replyto_address, last_mod_user)
VALUES (@name, @descrip, @emailAdd, @displayName, @replyAdd, @lastModUser);
--select * from sysmail_account

-----------------------

USE msdb
--Configure profile
INSERT INTO sysmail_profile (name, description, last_mod_user)
VALUES (@name, @descrip, @lastModUser);
--select * from sysmail_profile

-----------------------

USE msdb
DECLARE @profileID int = (SELECT Profile_ID FROM sysmail_profile WHERE name = @name);
DECLARE @accountID int = (SELECT Account_ID FROM sysmail_account WHERE name = @name);
	--Link mail account with profile
INSERT INTO sysmail_profileaccount (profile_id, account_id, sequence_number, last_mod_user)
VALUES (@profileID, @accountID, 1, @lastModUser)
--select * from sysmail_profileaccount

------------------------

USE msdb
--Configure server
INSERT INTO sysmail_server (account_id, servertype, servername, port, username, credential_id, use_default_credentials, enable_ssl, flags, [timeout], last_mod_user)
VALUES (@accountID, @serverType, @serverName, @port, @username, @CredentialID, 0, 1, 0, 60, @lastModUser);
--select * from sysmail_server

-------------------------

USE msdb
--Update Maximum File Size to allow csv file to be emailed.
UPDATE sysmail_configuration
SET paramvalue='10000000'
WHERE paramname = 'MaxFileSize'

-------------------------

--Remove comment and send a test message!
--EXEC sp_send_dbmail @profile_name='Unique Name',
--@recipients='Example@none.com',
--@subject='Test message',
--@body='If you see this in your mailbox that means Database Mail has been correctly set up. Congratulations!'

-------------------------











