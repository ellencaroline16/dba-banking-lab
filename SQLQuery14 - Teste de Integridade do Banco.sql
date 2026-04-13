-- ---------------------------------------------------------------------------
-- 2. TESTE DE INTEGRIDADE (VERIFYONLY + DBCC CHECKDB)
-- ---------------------------------------------------------------------------

-- 2a. Validar o arquivo .bak ANTES de confiar nele:
RESTORE VERIFYONLY
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH CHECKSUM, STOP_ON_ERROR;
GO
-- Mensagem esperada: "The backup set on file 1 is valid."

-- 2b. Check-up completo do banco restaurado:
DBCC CHECKDB ('Financiamento_HOM') WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO
-- Silêncio total = banco saudável. Só avisa se houver problema.