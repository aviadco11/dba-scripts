
-- Dynamic SQL with parameter

DECLARE @StringToExec NVARCHAR(4000) = N'
                SELECT u.*
                  FROM dbo.Users u
                  WHERE u.Location = @Location
                  ORDER BY DisplayName;'

EXEC sp_executesql @StringToExec, N'@Location NVARCHAR(200)', @TopLocation;
GO

