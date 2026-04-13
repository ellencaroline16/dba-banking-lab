-- ---------------------------------------------------------------------------
-- 1. FAXINA DO SERVIDOR — CLEANUP JOB (Entregável Oficial)
-- ---------------------------------------------------------------------------
-- O banco de dados "msdb" é o caderninho do SQL Server Agent.
-- Se não apagarmos o histórico velho, o arquivo cresce, fragmenta
-- e o disco sofre I/O desnecessário só para ler logs antigos.

USE msdb;
GO

DECLARE @DataCorte DATETIME;
SET @DataCorte = DATEADD(DAY, -30, GETDATE()); -- Mantém somente os últimos 30 dias

PRINT 'Iniciando Faxina do Servidor... Data de Corte: ' + CAST(@DataCorte AS VARCHAR);

-- 1. Limpeza do histórico de Backups:
PRINT 'Limpando histórico de backups...';
EXEC sp_delete_backuphistory @oldest_date = @DataCorte;

-- 2. Limpeza do histórico de Jobs (SQL Server Agent):
PRINT 'Limpando histórico de Jobs...';
EXEC sp_purge_jobhistory @oldest_date = @DataCorte;

-- 3. Limpeza do histórico do Database Mail:
PRINT 'Limpando histórico de e-mails (Database Mail)...';
EXEC sysmail_delete_mailitems_sp @sent_before   = @DataCorte;
EXEC sysmail_delete_log_sp       @logged_before = @DataCorte;

PRINT 'Faxina concluída com sucesso! O disco e o Buffer Pool agradecem.';
GO