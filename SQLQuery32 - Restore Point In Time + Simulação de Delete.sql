-- ---------------------------------------------------------------------------
-- CENÁRIO: Dev executou DELETE FROM Cadastros.Clientes SEM WHERE às 13:39
-- ---------------------------------------------------------------------------

-- PASSO 0: Garantir que temos o backup base recente:
USE master;
GO
BACKUP DATABASE Financiamento_PROD
TO DISK = 'C:\Auditoria\Financiamento_PROD_Base.bak'
WITH INIT, COMPRESSION, CHECKSUM;
GO

-- PASSO 1: Expulsar todos do banco e CONGELAR o paciente:
ALTER DATABASE Financiamento_PROD SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- PASSO 2: Capturar o Tail-Log Backup (o "último suspiro" do banco)
--          NORECOVERY = deixa o banco em estado "Restoring..." (não abre para ninguém)
BACKUP LOG Financiamento_PROD
TO DISK = 'C:\Auditoria\Financiamento_PROD_TailLog.trn'
WITH INIT, NORECOVERY;
GO

-- PASSO 3: Restaurar a Foto Base (Backup Full):
RESTORE DATABASE Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Base.bak'
WITH REPLACE, NORECOVERY;
GO

-- PASSO 4: A MÁQUINA DO TEMPO — Tail-Log com STOPAT
--          O SQL lê o log sequencialmente e para 1 segundo ANTES do DELETE.
--          Ajuste o timestamp para 1 segundo antes do desastre confirmado.
RESTORE LOG Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_TailLog.trn'
WITH STOPAT = '2026-04-13T12:32:29', RECOVERY;
GO

-- PASSO 5: Reabrir o banco para os usuários:
ALTER DATABASE Financiamento_PROD SET MULTI_USER;
GO

-- PASSO 6: Confirmar os dados salvos:
SELECT COUNT(*) AS [Total_de_Clientes_Salvos] FROM Cadastros.Clientes;
GO


-- 02

-- PASSO 1: Finalizar o restore e abrir o banco
USE master;
GO
RESTORE DATABASE Financiamento_PROD WITH RECOVERY;
GO

-- PASSO 2: Voltar para Multi User
ALTER DATABASE Financiamento_PROD SET MULTI_USER;
GO

-- PASSO 3: Confirmar que voltou
SELECT COUNT(*) AS [Total_Clientes] FROM Financiamento_PROD.Cadastros.Clientes;
GO


-- Ajustado com a ajuda do Claud

USE master;
GO

-- PASSO 1: Expulsar todos
ALTER DATABASE Financiamento_PROD 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- PASSO 2: Tail-Log Backup
BACKUP LOG Financiamento_PROD
TO DISK = 'C:\Auditoria\Financiamento_PROD_TailLog.trn'
WITH INIT, NORECOVERY;
GO

-- PASSO 3: Restaurar o Full
RESTORE DATABASE Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Base.bak'
WITH REPLACE, NORECOVERY;
GO

-- PASSO 4: Máquina do Tempo — timestamp exato do GETDATE() antes do DELETE!
RESTORE LOG Financiamento_PROD
FROM DISK = 'C:\Auditoria\Financiamento_PROD_TailLog.trn'
WITH STOPAT = '2026-04-13T12:43:04.687', RECOVERY;
GO

-- PASSO 5: Reabrir
ALTER DATABASE Financiamento_PROD SET MULTI_USER;
GO

-- PASSO 6: Confirmar os 60.000 salvos!
USE Financiamento_PROD;
GO

SELECT COUNT(*) AS [Clientes_Salvos] 
FROM Cadastros.Clientes;
GO