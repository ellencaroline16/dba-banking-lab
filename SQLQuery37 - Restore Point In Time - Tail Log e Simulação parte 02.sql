-- ---------------------------------------------------------------------------
-- SCRIPT DE EMERGÊNCIA COMPLETO (versão com KILL dinâmico de conexões)
-- ---------------------------------------------------------------------------

USE master;
GO

-- Mata qualquer conexão fantasma no banco afetado:
DECLARE @kill VARCHAR(8000) = '';
SELECT @kill = @kill + 'KILL ' + CONVERT(VARCHAR(5), session_id) + '; '
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('Financiamento_PROD');
EXEC(@kill);
GO

RESTORE DATABASE Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Base.bak'
WITH REPLACE, NORECOVERY;
GO

RESTORE LOG Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_TailLog.trn'
WITH STOPAT = '2026-03-17T13:38:59', RECOVERY;
GO

ALTER DATABASE Financiamento_PROD SET MULTI_USER;
GO

SELECT COUNT(*) AS [Total_de_Clientes_Salvos] FROM Cadastros.Clientes;
GO