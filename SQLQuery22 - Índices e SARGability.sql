-- ---------------------------------------------------------------------------
-- 1. O PROBLEMA DO SCAN (força bruta)
-- ---------------------------------------------------------------------------
-- Sem índice na coluna Email: SQL lê cada folha de 60.212 páginas.
-- 60.212 x 8KB = ~480MB de RAM consumidos para retornar 1 única linha!

USE Financiamento_PROD;
GO

SET STATISTICS IO ON;
GO

-- Query da tela de Login SEM índice (execute e anote os logical reads):
SELECT Email FROM Cadastros.Clientes WHERE Email = 'novoemail@abc.com';
GO

-- ---------------------------------------------------------------------------
-- 2. SOLUÇÃO PARCIAL E O KEY LOOKUP (o assassino silencioso)
-- ---------------------------------------------------------------------------

-- Criando o índice simples (resolve o Scan, mas cria o Key Lookup):
CREATE NONCLUSTERED INDEX IX_Clientes_Email
ON Cadastros.Clientes (Email);
GO

-- Agora busca por Email + Nome:
SELECT Email, Nome FROM Cadastros.Clientes WHERE Email = 'novoemail@abc.com';
-- Key Lookup: o SQL achou o Email no índice, mas foi buscar o Nome
-- na tabela principal (Clustered Index) — viagem extra que dobra o I/O.
GO


-- ---------------------------------------------------------------------------
-- 3. COVERING INDEX — A SOLUÇÃO DE ELITE
-- ---------------------------------------------------------------------------

-- Remove o índice incompleto:
DROP INDEX IX_Clientes_Email ON Cadastros.Clientes;
GO

-- Cria o Covering Index (a "Mochila Completa"):
-- INCLUDE anexa o Nome às páginas folha do índice — sem precisar ir à tabela.
CREATE NONCLUSTERED INDEX IX_Clientes_Email
ON Cadastros.Clientes (Email)
INCLUDE (Nome); -- O Key Lookup desaparece e o custo volta a 3 Logical Reads!
GO

-- Confirma: agora a query retorna com 3 logical reads (de 60.212 para 3):
SELECT Email, Nome FROM Cadastros.Clientes WHERE Email = 'novoemail@abc.com';
GO

SET STATISTICS IO OFF;
GO

-- ---------------------------------------------------------------------------
-- 4. COVERING INDEX PARA DATAS (SARGability)
-- ---------------------------------------------------------------------------

USE Financiamento_PROD;
GO

-- Índice na DataNascimento + colunas cobradas no SELECT:
CREATE NONCLUSTERED INDEX IX_Clientes_DataNascimento
ON Cadastros.Clientes (DataNascimento)
INCLUDE (Nome, CPF);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Query SARGable (usa intervalo contínuo — sem função no campo):
SELECT Nome, CPF, DataNascimento
FROM Cadastros.Clientes
WHERE DataNascimento >= '1990-01-01' AND DataNascimento < '1991-01-01';
-- vs. a query NON-SARGable: WHERE YEAR(DataNascimento) = 1990 (Full Scan!)
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
