-- ---------------------------------------------------------------------------
-- 4. SIMULAÇÃO DE USUÁRIO ÓRFÃO (didático — rode em HOM)
-- ---------------------------------------------------------------------------

USE master;
GO
CREATE LOGIN [Morador_Antigo] WITH PASSWORD = 'SenhaForte123!';
GO
USE Financiamento_PROD;
GO
CREATE USER [Morador_Antigo] FOR LOGIN [Morador_Antigo];
GO
USE master;
GO
DROP LOGIN [Morador_Antigo]; -- Remove o Login, mas o User continua no banco!
GO

-- Confirma o órfão gerado:
USE Financiamento_PROD;
GO
SELECT name AS [Usuario_Orfao], sid
FROM sys.database_principals
WHERE type_desc    = 'SQL_USER'
  AND principal_id > 4
  AND name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')
  AND sid NOT IN (SELECT sid FROM sys.server_principals);
GO

-- ---------------------------------------------------------------------------
-- 5. REMAPEAMENTO DE USUÁRIO ÓRFÃO
-- ---------------------------------------------------------------------------

USE master;
GO
CREATE LOGIN [Morador_Novo] WITH PASSWORD = 'NovaSenha123!';
GO
USE Financiamento_PROD;
GO
ALTER USER [Morador_Antigo] WITH LOGIN = [Morador_Novo]; -- Reconecta o User ao novo Login
GO