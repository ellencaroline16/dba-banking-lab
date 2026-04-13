-- ---------------------------------------------------------------------------
-- 1. REVISÃO DE SEGURANÇA — CASO JOÃOZINHO
-- ---------------------------------------------------------------------------

USE Financiamento_PROD;
GO

-- Garantir que as Roles existam antes de aplicar permissões:
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Analista_BI')
    CREATE ROLE [Role_Analista_BI];
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Role_Analista_Financeiro')
    CREATE ROLE [Role_Analista_Financeiro];
GO

-- Adicionar o Analista_BI à Role correta:
ALTER ROLE [Role_Analista_BI] ADD MEMBER [Analista_BI];
GO

-- Grant no Schema (a "sala") + Deny na tabela (o "armário sensível"):
GRANT SELECT ON SCHEMA::[Cadastros]     TO [Role_Analista_BI];
DENY  SELECT ON [Cadastros].[Clientes]  TO [Role_Analista_BI];
GO

-- Teste de fogo:
EXECUTE AS USER = 'Analista_BI';
    SELECT * FROM Cadastros.Agencias; -- Deve funcionar (Grant no schema vence)
    SELECT * FROM Cadastros.Clientes; -- Deve FALHAR (Deny na tabela vence)
REVERT;
GO

-- Criar usuário de relatório com acesso explícito:
CREATE LOGIN [Usuario_Relatorio] WITH PASSWORD = 'SenhaForte123!';
CREATE USER  [Usuario_Relatorio] FOR LOGIN [Usuario_Relatorio];
GRANT SELECT ON SCHEMA::Cadastros TO [Usuario_Relatorio];
GO

-- Auditoria de membros de Role:
SELECT
    r.name AS [Role],
    m.name AS [Membro]
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id   = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE m.name = 'Analista_BI';
GO