-- ---------------------------------------------------------------------------
-- 3. MASCARAMENTO DE DADOS SENSÍVEIS (Dynamic Data Masking — DDM)
-- ---------------------------------------------------------------------------
-- DDM funciona no nível do Protocolo TDS.
-- O dado no DISCO permanece real e íntegro.
-- O SQL aplica um "filtro" na SAÍDA para usuários sem privilégio.
-- NÃO use UPDATE para apagar dados reais — gera overhead no Transaction Log!

USE Financiamento_HOM;
GO

-- 3a. Mascarar CPF (mostra 3 primeiros e 2 últimos dígitos):
ALTER TABLE Cadastros.Clientes
ALTER COLUMN CPF ADD MASKED WITH (FUNCTION = 'partial(3, "XXX.XXX", 2)');
GO

-- 3b. Mascarar E-mail (mantém formato, esconde o nome):
ALTER TABLE Cadastros.Clientes
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');
GO

-- 3c. Verificar como o Joãozinho vê os dados mascarados:
EXECUTE AS USER = 'Dev_Joaozinho';
    SELECT Nome, CPF, Email FROM Cadastros.Clientes;
REVERT;
GO

-- 3d. Teste de burla via conversão de tipo (deve FALHAR — DDM é resistente):
EXECUTE AS USER = 'Dev_Joaozinho';
    SELECT CAST(CPF AS VARCHAR(MAX)) AS CPF_Burlado FROM Cadastros.Clientes;
REVERT;
GO


USE Financiamento_HOM;
GO

INSERT INTO Cadastros.Clientes (CPF, Nome, Email, DataNascimento, Rua, Bairro, Cidade, Estado, CEP)
VALUES ('12345678900', 'Maria Teste', 'maria@gmail.com', '1990-05-15', 
        'Rua das Flores', 'Centro', 'São Paulo', 'SP', '01310100');
GO


USE Financiamento_HOM;
GO

-- Ver todas as colunas e quais são obrigatórias (NOT NULL)
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Cadastros'
  AND TABLE_NAME   = 'Clientes'
ORDER BY ORDINAL_POSITION;
GO