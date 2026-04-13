-- ---------------------------------------------------------------------------
-- SCRIPTS DOS STEPS DO JOB DE MANUTENÇÃO
-- ---------------------------------------------------------------------------
-- Ordem correta (regra de ouro): FAXINA antes da FOTO.
-- Step 1 → UPDATE STATISTICS: atualiza o QO ANTES do backup.
-- Step 2 → BACKUP DATABASE:   tira a foto de um banco saudável e compacto.
--
-- IMPORTANTE: Configure o fluxo no SQL Server Agent:
--   Step 1 SUCESSO  → vai para Step 2
--   Step 1 FALHA    → ABORTA o Job (não backupeia banco com stats ruins)
--   Step 2 SUCESSO  → FIM: SUCESSO
--   Step 2 FALHA    → FIM: ERRO (requer ação do DBA)

-- STEP 1 — A Faxina (cole este código no Step 1 do Job):
USE Financiamento_PROD; -- OBRIGATÓRIO: SQL Agent executa no banco "master" por padrão
GO
UPDATE STATISTICS Cadastros.Clientes WITH FULLSCAN;
GO

-- STEP 2 — A Foto (cole este código no Step 2 do Job):
USE master;
GO
BACKUP DATABASE [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Step de Backup Diferencial (Job separado, agendado diariamente):
USE master;
GO
BACKUP DATABASE [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_Diff.bak'
WITH DIFFERENTIAL, INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO

-- Step de Backup de Log (Job separado, agendado a cada 15 minutos):
USE master;
GO
BACKUP LOG [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_Log.trn'
WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;
GO