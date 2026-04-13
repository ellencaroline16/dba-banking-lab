-- ---------------------------------------------------------------------------
-- 2. FRAGMENTAÇÃO E AÇÃO RECOMENDADA
-- ---------------------------------------------------------------------------
-- > 30% fragmentação → REBUILD (recria o índice do zero)
-- 5% a 30%           → REORGANIZE (desfragmenta folha a folha, online)
-- < 5%               → Saudável, não precisa de ação

USE Financiamento_PROD;
GO

SELECT
    s.name                                                     AS [Schema],
    t.name                                                     AS [Tabela],
    i.name                                                     AS [Indice],
    ps.index_type_desc                                         AS [Tipo_Indice],
    CAST(ps.avg_fragmentation_in_percent AS DECIMAL(5,2))      AS [Perc_Fragmentacao],
    ps.page_count                                              AS [Total_Paginas],
    CAST(ps.avg_page_space_used_in_percent AS DECIMAL(5,2))    AS [Perc_Ocupacao],
    CASE
        WHEN ps.avg_fragmentation_in_percent > 30          THEN 'REBUILD  (Crítico)'
        WHEN ps.avg_fragmentation_in_percent BETWEEN 5 AND 30 THEN 'REORGANIZE (Leve)'
        ELSE 'Saudável'
    END AS [Acao_Recomendada]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') ps
INNER JOIN sys.indexes  i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
INNER JOIN sys.tables   t ON i.object_id  = t.object_id
INNER JOIN sys.schemas  s ON t.schema_id  = s.schema_id
WHERE ps.page_count > 8
ORDER BY ps.avg_fragmentation_in_percent DESC;
GO


-- Insert p/ teste da fragmentação 

USE Financiamento_PROD;
GO

-- Gera 60.000 clientes de teste com dados variados
INSERT INTO Cadastros.Clientes (CPF, Nome, Email, DataNascimento, Rua, Bairro, Cidade, Estado, CEP)
SELECT TOP 60000
    RIGHT('00000000000' + CAST(ROW_NUMBER() OVER (ORDER BY a.object_id) AS VARCHAR), 11),
    'Cliente Teste ' + CAST(ROW_NUMBER() OVER (ORDER BY a.object_id) AS VARCHAR),
    'cliente' + CAST(ROW_NUMBER() OVER (ORDER BY a.object_id) AS VARCHAR) + '@email.com',
    DATEADD(DAY, -(ROW_NUMBER() OVER (ORDER BY a.object_id) % 15000), '2000-01-01'),
    'Rua Numero ' + CAST(ROW_NUMBER() OVER (ORDER BY a.object_id) AS VARCHAR),
    'Bairro ' + CAST((ROW_NUMBER() OVER (ORDER BY a.object_id) % 10) AS VARCHAR),
    CASE (ROW_NUMBER() OVER (ORDER BY a.object_id) % 5)
        WHEN 0 THEN 'São Paulo'
        WHEN 1 THEN 'Rio de Janeiro'
        WHEN 2 THEN 'Belo Horizonte'
        WHEN 3 THEN 'Curitiba'
        ELSE 'Porto Alegre'
    END,
    CASE (ROW_NUMBER() OVER (ORDER BY a.object_id) % 5)
        WHEN 0 THEN 'SP'
        WHEN 1 THEN 'RJ'
        WHEN 2 THEN 'MG'
        WHEN 3 THEN 'PR'
        ELSE 'RS'
    END,
    RIGHT('00000000' + CAST((ROW_NUMBER() OVER (ORDER BY a.object_id) % 99999999) AS VARCHAR), 8)
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO