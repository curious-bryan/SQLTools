DECLARE @username VARCHAR(25)
DECLARE GetOrphanUsers CURSOR
FOR
SELECT UserName = name
FROM sysusers
WHERE issqluser = 1
	AND (sid IS NOT NULL
	AND sid <> 0x0)
	AND SUSER_SNAME(sid) IS NULL
	AND name in (select name from master.sys.server_principals where type = 'S')
ORDER BY name

OPEN GetOrphanUsers
FETCH NEXT
FROM GetOrphanUsers
INTO @username

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @username='dbo'
		EXEC sp_changedbowner 'sa'
		
	ELSE
		EXEC sp_change_users_login 'update_one', @username, @username
		
	PRINT @username
	FETCH NEXT
	FROM GetOrphanUsers
	INTO @username
END

CLOSE GetOrphanUsers
DEALLOCATE GetOrphanUsers


