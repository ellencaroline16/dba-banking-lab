-- ---------------------------------------------------------------------------
-- 1. ROLES CUSTOMIZADAS (o "Crachá de Departamento")
-- ---------------------------------------------------------------------------
-- Por que Roles? É mais performático o motor validar 1 Role do que
-- centenas de permissões individuais espalhadas pelos metadados.

USE Financiamento_PROD;
GO

-- 1a. Role_App_Financiamento — a engrenagem do sistema
--     NÃO tem DELETE para proteger contra bugs e SQL Injection.
CREATE ROLE [Role_App_Financiamento];
GO
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Financeiro TO [Role_App_Financiamento];
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Cadastros  TO [Role_App_Financiamento];
GO

-- 1b. Role_Analista_BI — o observador (conformidade LGPD)
--     DENY no schema Cadastros: não enxerga dados pessoais.
CREATE ROLE [Role_Analista_BI];
GO
GRANT SELECT ON SCHEMA::Financeiro TO [Role_Analista_BI];
DENY  SELECT ON SCHEMA::Cadastros  TO [Role_Analista_BI];
GO

-- 1c. Role_Auditoria_Compliance — o fiscal
--     SELECT em tudo + VIEW DEFINITION: vê o código dos objetos sem alterar.
CREATE ROLE [Role_Auditoria_Compliance];
GO
GRANT SELECT          TO [Role_Auditoria_Compliance];
GRANT VIEW DEFINITION TO [Role_Auditoria_Compliance];
GO

-- 1d. Role_Suporte_Nivel_1 — o mecânico
--     Acesso cirúrgico somente nas tabelas de troubleshooting.
CREATE ROLE [Role_Suporte_Nivel_1];
GO
GRANT SELECT ON [Financeiro].[Transacoes] TO [Role_Suporte_Nivel_1];
GRANT SELECT ON [Financeiro].[Contas]     TO [Role_Suporte_Nivel_1];
GO

-- Adicionando membros às Roles:
ALTER ROLE [Role_Analista_BI]      ADD MEMBER [Analista_BI];
ALTER ROLE [Role_App_Financiamento] ADD MEMBER [App_Financiamento];
GO

-- Relatório de auditoria de Roles:
SELECT
    r.name AS [Nome_da_Role],
    m.name AS [Nome_do_Membro],
    m.type_desc AS [Tipo_de_Membro]
FROM sys.database_role_members AS rm
JOIN sys.database_principals AS r ON rm.role_principal_id   = r.principal_id
JOIN sys.database_principals AS m ON rm.member_principal_id = m.principal_id;
GO
