USE LYCEUMINTEGRACAO
GO

-- EXEC FTC_PROC_ACTIVE_DIRECTORY
ALTER PROCEDURE FTC_PROC_ACTIVE_DIRECTORY

AS


IF (OBJECT_ID('tempdb..#Usuarios_AD') IS NOT NULL) DROP TABLE #Usuarios_AD
CREATE TABLE #Usuarios_AD (
    displayName nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    SamAccountName nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    userPrincipalName nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    givenName nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    sn nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    Title nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    department nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    company nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    physicalDeliveryOfficeName nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    mail nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    telephoneNumber nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    mobile nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    manager nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    postOfficeBox varchar (10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	userAccountControl nvarchar (20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	adspath nvarchar (4000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
)


IF (OBJECT_ID('tempdb..#Usuarios_AD_Temp') IS NOT NULL) DROP TABLE #Usuarios_AD_Temp
SELECT displayName, SamAccountName, userPrincipalName, givenName, sn, Title, department, company, physicalDeliveryOfficeName, mail, telephoneNumber, mobile, manager, userAccountControl, adspath
INTO #Usuarios_AD_Temp 
FROM #Usuarios_AD

CREATE INDEX IDX_ADSPATH ON #Usuarios_AD_Temp (adspath);

        
DECLARE 
    @Ds_Ultimo_Login VARCHAR(100) = 'a',
    @Query VARCHAR(MAX)
        
        
WHILE(@Ds_Ultimo_Login IS NOT NULL)
BEGIN
        
            
    TRUNCATE TABLE #Usuarios_AD_Temp


    SET @Query = '
    SELECT 
        userPrincipalName,
        SamAccountName,
        displayName,
        givenName, 
        sn, 
        physicalDeliveryOfficeName, 
        mail, 
        telephoneNumber,
        Title,
        department,
        company,
        manager,
        mobile,
		userAccountControl,
		adspath
    FROM 
        ''''LDAP://ADMGLOBAL.ad/OU=ATIVOS,OU=ADMGLOBAL,DC=admglobal,DC=ad''''
    WHERE 
        objectCategory = ''''Person'''' 
        AND objectClass = ''''User''''
        AND SamAccountName > ''''' + @Ds_Ultimo_Login + '''''
    ORDER BY
        SamAccountName
    '
            
    SET @Query = '
    INSERT INTO #Usuarios_AD_Temp (displayName, SamAccountName, userPrincipalName, givenName, sn, Title, department, company, physicalDeliveryOfficeName, mail, telephoneNumber, mobile, manager, userAccountControl,adspath )
    SELECT TOP 901 displayName, SamAccountName, userPrincipalName, givenName, sn, Title, department, company, physicalDeliveryOfficeName, mail, telephoneNumber, mobile, manager, userAccountControl, adspath  
    FROM OPENQUERY([ADSI], ''' + @Query + ''')'
            
    EXEC(@Query)


    INSERT INTO #Usuarios_AD(displayName, SamAccountName, userPrincipalName, givenName, sn, Title, department, company, physicalDeliveryOfficeName, mail, telephoneNumber, mobile, manager, userAccountControl, adspath)
    SELECT DISTINCT displayName, SamAccountName, userPrincipalName, givenName, sn, Title, department, company, physicalDeliveryOfficeName, mail, telephoneNumber, mobile, manager, userAccountControl, adspath 
    FROM #Usuarios_AD_Temp



            /*
				512 - Enable Account
				514 - Disable account
				576 - Enable Account + Passwd_cant_change
				544 - Account Enabled - Require user to change password at first logon
				4096 - Workstation/server
				66048 - Enabled, password never expires
				66050 - Disabled, password never expires
				262656 - Smart Card Logon Required
				532480 - Domain controller
			*/
            
    SET @Ds_Ultimo_Login = NULL
    SELECT TOP 1 @Ds_Ultimo_Login = SamAccountName FROM #Usuarios_AD_Temp ORDER BY SamAccountName DESC

	
	DECLARE @PATH VARCHAR(MAX)

	-- Cursor para percorrer os registros
	DECLARE cursor1 CURSOR FOR

	select a.adspath from #Usuarios_AD a

	--Abrindo Cursor
	OPEN cursor1

	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @PATH

	-- Percorrendo linhas do cursor (enquanto houverem)
	WHILE @@FETCH_STATUS = 0
	BEGIN

	UPDATE T SET T.COMPANY = (select top 1 REPLACE(S,'OU=','')
	from LYCEUM.dbo.split(@PATH,',')
	where
	s like 'OU=%'
	AND REPLACE(S,'OU=','') IN ('COM','DOM','EUS','FSA','ITA','JEQ','JUA','PET','SP','SSA','VIC','IMES','IDEA'))
	FROM #Usuarios_AD T 
	WHERE T.ADSPATH = @PATH


	UPDATE T SET T.DEPARTMENT = (select top 1 REPLACE(S,'OU=','')
	from LYCEUM.dbo.split(@PATH,',')
	where
	s like 'OU=%'
	AND REPLACE(S,'OU=','') NOT IN ('COM','DOM','EUS','FSA','ITA','JEQ','JUA','PET','SP','SSA','VIC','IMES','IDEA','ATIVOS','ADMGLOBAL','SETORES'))
	FROM #Usuarios_AD T 
	WHERE T.ADSPATH = @PATH

	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @PATH
	END
	CLOSE cursor1
	DEALLOCATE cursor1
        
        
END

TRUNCATE TABLE FTC_USUARIOS_AD

insert into FTC_USUARIOS_AD
SELECT * FROM #Usuarios_AD