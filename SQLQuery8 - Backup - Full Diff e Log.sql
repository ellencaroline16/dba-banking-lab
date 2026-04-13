-- ---------------------------------------------------------------------------
-- 3. RECOVERY MODEL E CADEIA DE BACKUP (Full / Diff / Log)
-- ---------------------------------------------------------------------------

USE master;
GO
ALTER DATABASE [Financiamento_PROD] SET RECOVERY FULL; -- Padrão obrigatório para Point-in-Time
GO

-- 3a. Full Backup — a base de tudo (tirar semanalmente)
BACKUP DATABASE [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_Full.bak'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO

-- 3b. Differential Backup — copia só o que mudou desde o Full (tirar diariamente)
BACKUP DATABASE [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_Diff.bak'
WITH DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO

-- 3c. Transaction Log Backup — o "vídeo" das transações (tirar a cada 15 min)
BACKUP LOG [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_Log.trn'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Validação rápida do backup:
RESTORE VERIFYONLY
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH CHECKSUM, STOP_ON_ERROR;
GO