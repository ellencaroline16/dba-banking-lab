-- ---------------------------------------------------------------------------
-- 2. DATABASE REFRESH (PROD → HOM)
-- ---------------------------------------------------------------------------
-- PROD é o Restaurante Oficial. HOM é a Cozinha de Testes.
-- Refresh = jogar fora os ingredientes velhos de HOM e trazer os de PROD.

-- Passo 0: descobrir os nomes lógicos dos arquivos no backup:
RESTORE FILELISTONLY
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak';
GO

USE master;
GO

-- Passo 1: expulsar todos do banco de HOM:
ALTER DATABASE [Financiamento_HOM] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Passo 2: o Restore de Elite com MOVE (evita sobrescrever arquivos de PROD):
RESTORE DATABASE [Financiamento_HOM]
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH REPLACE,
    MOVE 'Financiamento_PROD'     TO 'C:\Auditoria\Financiamento_HOM.mdf',
    MOVE 'Financiamento_PROD_log' TO 'C:\Auditoria\Financiamento_HOM_log.ldf',
    STATS = 10;
GO

-- Passo 3: reabrir o banco:
ALTER DATABASE [Financiamento_HOM] SET MULTI_USER;
GO

-- Passo 4: remap dos usuários órfãos gerados pelo Restore:
USE Financiamento_HOM;
GO
ALTER USER [Dev_Joaozinho] WITH LOGIN = [Dev_Joaozinho];
GO

-- Verificar se ainda há órfãos:
SELECT dp.name AS [Usuario_Orfao], dp.sid
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON dp.sid = sp.sid
WHERE sp.sid IS NULL
  AND dp.type_desc    = 'SQL_USER'
  AND dp.principal_id > 4;
GO

-- Recriar Role removida pelo Restore:
USE Financiamento_HOM;
GO
CREATE ROLE [Role_App_Financiamento];
GO
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Financeiro TO [Role_App_Financiamento];
GO
ALTER ROLE [Role_App_Financiamento] ADD MEMBER [Dev_Joaozinho];
GO
