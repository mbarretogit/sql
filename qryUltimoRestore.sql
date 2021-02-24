WITH LastRestores AS
(
SELECT
    DatabaseName = [d].[name] ,
    [d].[create_date] ,
    [d].[compatibility_level] ,
    [d].[collation_name] ,
    r.*,
    RowNum = ROW_NUMBER() OVER (PARTITION BY d.Name ORDER BY r.[restore_date] DESC)
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.[restorehistory] r ON r.[destination_database_name] = d.Name
)
SELECT DatabaseName, RESTORE_DATE
FROM [LastRestores]
WHERE [RowNum] = 1
AND DatabaseName IN ('HADES','LYCEUM','LYCEUMINTEGRACAO','TOPDESK','TOPDESK_PROD','UNIFTC_ONE')