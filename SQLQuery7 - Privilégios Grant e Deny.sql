-- ---------------------------------------------------------------------------
-- 2. PRIVILÉGIO MÍNIMO — DENY CIRÚRGICO EM NÍVEL DE COLUNA
-- ---------------------------------------------------------------------------
-- Lei Suprema: GRANT + DENY no mesmo usuário → DENY sempre vence.

USE Financiamento_PROD;
GO

-- Permite leitura na tabela, mas bloqueia CPF e DataNascimento (LGPD):
GRANT SELECT ON [Cadastros].[Clientes]                         TO [Dev_Joaozinho];
DENY  SELECT ON [Cadastros].[Clientes] (CPF, DataNascimento)   TO [Dev_Joaozinho];
GO

-- Criando usuário de Suporte com permissão somente nas colunas necessárias:
USE master;
GO
CREATE LOGIN [User_Suporte] WITH PASSWORD = 'SenhaForte123!';
GO
USE Financiamento_PROD;
GO
CREATE USER [User_Suporte] FOR LOGIN [User_Suporte];
GO
GRANT UPDATE ON [Cadastros].[Clientes] (Email)             TO [User_Suporte];
GRANT SELECT ON [Cadastros].[Clientes] (ClienteID, Nome)   TO [User_Suporte];
GO

-- Teste de fogo (rode em HOM):
EXECUTE AS USER = 'User_Suporte';
    UPDATE [Cadastros].[Clientes] SET Email = 'novoemail@abc.com' WHERE ClienteID = 1; -- Deve funcionar
    UPDATE [Cadastros].[Clientes] SET Nome  = 'Tentativa de Fraude' WHERE ClienteID = 1; -- Deve dar erro
REVERT; -- NUNCA ESQUEÇA O REVERT!
GO