-- ---------------------------------------------------------------------------
-- 1. TAMANHO DAS TABELAS (Pages e Extents)
-- ---------------------------------------------------------------------------
-- SQL Server não enxerga "tabelas" — enxerga Páginas de 8KB.
-- 8 páginas contíguas = 1 Extent (64KB). Essa é a unidade de alocação no disco.

USE Financiamento_PROD;
GO

SELECT
    s.name                                                     AS [Schema],
    t.name                                                     AS [Tabela],
    p.rows                                                     AS [Qtd_Linhas],
    SUM(au.total_pages)                                        AS [Total_Paginas],
    SUM(au.total_pages) * 8                                    AS [Tamanho_KB],
    CAST((SUM(au.total_pages) * 8) / 1024.0 AS DECIMAL(10,2)) AS [Tamanho_MB]
FROM sys.schemas s
JOIN sys.tables          t  ON s.schema_id    = t.schema_id
JOIN sys.indexes         i  ON t.object_id    = i.object_id
JOIN sys.partitions      p  ON i.object_id    = p.object_id AND i.index_id = p.index_id
JOIN sys.allocation_units au ON p.partition_id = au.container_id
WHERE t.is_ms_shipped = 0
GROUP BY s.name, t.name, p.rows
ORDER BY [Total_Paginas] DESC;
GO