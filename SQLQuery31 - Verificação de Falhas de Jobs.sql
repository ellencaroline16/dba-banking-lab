-- ---------------------------------------------------------------------------
-- 2. VERIFICAÇÃO DE JOBS COM FALHA + ÚLTIMO BACKUP (Checklist rápido)
-- ---------------------------------------------------------------------------

-- Jobs que falharam:
SELECT name, last_run_date, last_run_time, last_run_outcome
FROM msdb.dbo.sysjobservers js
JOIN msdb.dbo.sysjobs j ON js.job_id = j.job_id
WHERE last_run_outcome = 0;
GO

-- Último Backup Full por banco:
SELECT database_name, MAX(backup_finish_date) AS Ultimo_Backup_Full
FROM msdb.dbo.backupset
WHERE type = 'D'
GROUP BY database_name;
GO
