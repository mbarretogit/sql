USE LYCEUMINTEGRACAO
GO

IF (OBJECT_ID('LYCEUMITEGRACAO..FTC_USUARIOS_AD') IS NOT NULL) 
BEGIN 
DROP TABLE FTC_USUARIOS_AD
END 
ELSE
BEGIN
CREATE TABLE FTC_USUARIOS_AD (
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
END