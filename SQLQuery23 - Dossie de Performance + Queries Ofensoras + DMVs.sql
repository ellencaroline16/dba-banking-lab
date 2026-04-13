-- ---------------------------------------------------------------------------
-- 1. LIMPAR O CACHE ANTES DO DIAGNÓSTICO
-- ---------------------------------------------------------------------------

DBCC FREEPROCCACHE; -- Zera o cache de planos e reseta as DMVs
GO

-- ---------------------------------------------------------------------------
-- 2. SIMULANDO AS QUERIES PROBLEMÁTICAS DO DEV
-- ---------------------------------------------------------------------------

USE Financiamento_PROD;
GO

-- Query 1: Função no WHERE (destrói SARGability — Full Scan em 4 milhões de linhas)
SELECT Nome, CPF, DataNascimento
FROM Cadastros.Clientes
WHERE YEAR(DataNascimento) = 1990;

-- Query 2: Curinga no início da string (Force Index Scan)
SELECT Nome, Email
FROM Cadastros.Clientes
WHERE Email LIKE '%@gmail.com';

-- Query 3: Agrupamento sem índice de suporte (Sort/Hash Match na CPU)
SELECT TransacaoID, SUM(Valor) AS Total_Financiado
FROM Financeiro.Transacoes
GROUP BY TransacaoID
HAVING SUM(Valor) > 50000;

-- Query 4: LIKE com % na frente (Non-SARGable — 400MB de RAM para 1 linha)
SELECT CPF, Nome, DataNascimento
FROM Cadastros.Clientes
WHERE Nome LIKE '%Phoebe%';
GO


-- ---------------------------------------------------------------------------
-- 3. RAIO-X DO DBA — TOP 5 QUERIES QUE MAIS ESPANCAM O DISCO (I/O)
-- ---------------------------------------------------------------------------

SELECT TOP 5
    qs.execution_count                                    AS [Vezes_Executada],
    qs.total_logical_reads / qs.execution_count           AS [Leituras_Media_por_Execucao],
    qs.total_logical_reads                                AS [Total_Leituras_IO],
    qs.total_worker_time   / qs.execution_count / 1000    AS [CPU_Media_ms],
    SUBSTRING(st.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
         END - qs.statement_start_offset) / 2) + 1)      AS [Query_Ofensora],
    qp.query_plan                                         AS [Plano_de_Execucao]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle)   AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE st.text NOT LIKE '%sys.%' -- Ignora queries internas do SQL Server
ORDER BY qs.total_logical_reads DESC; -- Pior I/O primeiro
GO
