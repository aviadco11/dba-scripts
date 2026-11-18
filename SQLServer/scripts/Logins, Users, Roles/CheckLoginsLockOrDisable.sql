
-- check if logins is diable or lock
SELECT name, is_disabled, LOGINPROPERTY(name, N'isLocked') as is_locked,
LOGINPROPERTY(name, N'LockoutTime') as LockoutTime
FROM sys.sql_logins

