-- ---------------------------------------------------------------------------
-- 1. MAPEAMENTO DE LOGINS E USERS
-- ---------------------------------------------------------------------------
-- Modelo mental:
--   Login  = crachá da portaria         (nível servidor — banco master)
--   User   = permissão para entrar no andar específico (nível banco)
--   Schema = sala trancada dentro desse andar (nível objeto)

USE Financiamento_PROD;
GO

-- Inventário de quem tem permissão nos Schemas principais
SELECT
    dp.name              AS [Usuario_do_Banco],
    dp.type_desc         AS [Tipo_de_Usuario],
    p.permission_name    AS [O_que_ele_pode_fazer],
    p.state_desc         AS [Status],
    s.name               AS [Nome_do_Schema]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS dp ON p.grantee_principal_id = dp.principal_id
INNER JOIN sys.schemas             AS s  ON p.major_id             = s.schema_id
WHERE p.class_desc = 'SCHEMA'
  AND s.name IN ('Financeiro', 'Cadastros');
GO


-- ---------------------------------------------------------------------------
-- 2. CRIANDO USUÁRIOS PARA AUDITORIA (ambientes de teste)
-- ---------------------------------------------------------------------------

-- 2a. O Desenvolvedor (lê e insere, mas NÃO apaga)
USE master;
GO
CREATE LOGIN [Dev_Joaozinho]    WITH PASSWORD = 'SenhaForte123!';
GO
USE Financiamento_PROD;
GO
CREATE USER  [Dev_Joaozinho]    FOR LOGIN [Dev_Joaozinho];
GRANT SELECT, INSERT ON SCHEMA::Cadastros TO [Dev_Joaozinho];
GO

-- 2b. O Analista de BI (somente leitura para relatórios)
USE master;
GO
CREATE LOGIN [Analista_BI]      WITH PASSWORD = 'SenhaForte123!';
GO
USE Financiamento_PROD;
GO
CREATE USER  [Analista_BI]      FOR LOGIN [Analista_BI];
GRANT SELECT ON SCHEMA::Financeiro TO [Analista_BI];
GO

-- 2c. A Aplicação (sistema do celular do cliente)
USE master;
GO
CREATE LOGIN [App_Financiamento] WITH PASSWORD = 'SenhaForte123!';
GO
USE Financiamento_PROD;
GO
CREATE USER  [App_Financiamento] FOR LOGIN [App_Financiamento];
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Financeiro TO [App_Financiamento];
GO

-- ---------------------------------------------------------------------------
-- 3. IDENTIFICAÇÃO DE USUÁRIOS ÓRFÃOS
-- ---------------------------------------------------------------------------
-- Ocorrem quando um banco é restaurado em outro servidor ou o Login é recriado.
-- O nome é o mesmo, mas o SID binário é diferente — vínculo quebrado.

USE Financiamento_PROD;
GO
SELECT
    name AS [Usuario_Orfao],
    sid
FROM sys.database_principals
WHERE type_desc    = 'SQL_USER'
  AND principal_id > 4
  AND name NOT IN ('guest', 'INFORMATION_SCHEMA', 'sys')
  AND sid NOT IN (SELECT sid FROM sys.server_principals);
GO

