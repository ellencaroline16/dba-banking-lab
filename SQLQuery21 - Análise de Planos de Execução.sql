-- ---------------------------------------------------------------------------
-- 3. ANÁLISE DE PLANOS DE EXECUÇÃO (SET STATISTICS)
-- ---------------------------------------------------------------------------
USE Financiamento_PROD;
GO

SET STATISTICS IO ON;  -- Mede Logical Reads (páginas de 8KB lidas na RAM)
SET STATISTICS TIME ON; -- Mede tempo de CPU
GO

-- Query A: busca por ID — geralmente gera Index SEEK (bom)
SELECT Nome, CPF FROM Cadastros.Clientes WHERE ClienteID = 10;

-- Query B: função no WHERE — mata a SARGability, força Index SCAN (ruim)
SELECT Nome, CPF FROM Cadastros.Clientes WHERE UPPER(Nome) = 'SERENA';

-- Query C: busca SARGable — sem função, SQL pode usar o índice (bom)
SELECT Nome, CPF FROM Cadastros.Clientes WHERE Nome = 'Serena';

-- Comparar os "logical reads" nas três queries acima — a diferença é a prova!
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
