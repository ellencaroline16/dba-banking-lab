-- ---------------------------------------------------------------------------
-- 7. INVENTÁRIO DE PERMISSÕES (gerador de scripts de segurança)
-- ---------------------------------------------------------------------------

USE Financiamento_PROD;
GO
SELECT
    dp.name AS [Usuario],
    p.permission_name,
    s.name AS [Schema_Name]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS dp ON p.grantee_principal_id = dp.principal_id
INNER JOIN sys.schemas             AS s  ON p.major_id             = s.schema_id
WHERE p.class_desc = 'SCHEMA';
GO