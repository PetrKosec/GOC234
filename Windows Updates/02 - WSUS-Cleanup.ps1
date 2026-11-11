# WSUS CleanUp
Invoke-WsusServerCleanup `
-CleanupObsoleteUpdates `
-CleanupObsoleteComputers `
-CleanupUnneededContentFiles `
-DeclineExpiredUpdates `
-DeclineSupersededUpdates

# SQL DB Cleanup
# EXEC spUpdatestats
# ALTER INDEX ALL ON tbLocalizedPropertyForRevision REBUILD

# WSUS Database Maintenance
# Aktualizace statistik a rebuild indexů

$SqlInstance = "\\.\pipe\MICROSOFT##WID\tsql\query"
$Database = "SUSDB"

$query = @"
USE SUSDB;

PRINT 'Running spUpdateStats...';
EXEC spUpdatestats;

PRINT 'Rebuilding indexes on tbLocalizedPropertyForRevision...';
ALTER INDEX ALL ON dbo.tbLocalizedPropertyForRevision REBUILD;

PRINT 'Maintenance completed.';
"@

Invoke-Sqlcmd `
    -ServerInstance $SqlInstance `
    -Database $Database `
    -Query $query `
    -QueryTimeout 0 `
    -Verbose
