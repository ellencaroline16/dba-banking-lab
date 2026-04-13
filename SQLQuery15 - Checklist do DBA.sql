-- ---------------------------------------------------------------------------
-- 3. CHECKLIST MATINAL DO DBA DE ELITE
-- ---------------------------------------------------------------------------

-- 3a. Espaço em disco (DMV do SO):
SELECT DISTINCT(volume_mount_point),
    total_bytes     / 1048576 AS [Tamanho_MB],
    available_bytes / 1048576 AS [Livre_MB]
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id);
GO

-- 3b. Jobs que falharam durante a madrugada:
SELECT name, last_run_date, last_run_time, last_run_outcome
FROM msdb.dbo.sysjobservers js
JOIN msdb.dbo.sysjobs j ON js.job_id = j.job_id
WHERE last_run_outcome = 0; -- 0 = Falha
GO

-- 3c. Data do último Backup Full por banco:
SELECT database_name, MAX(backup_finish_date) AS Ultimo_Backup_Full
FROM msdb.dbo.backupset
WHERE type = 'D' -- D = Database (Full)
GROUP BY database_name;
GO

-- 3d. Órfãos no banco de produção (verificação pós-restore):
USE Financiamento_PROD;
GO
SELECT name AS [Usuario_Orfao], sid
FROM sys.database_principals
WHERE type_desc    = 'SQL_USER'
  AND principal_id > 4
  AND name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')
  AND sid NOT IN (SELECT sid FROM sys.server_principals);
GO