-- ---------------------------------------------------------------------------
-- 1. AUDITORIA DE SAÚDE DAS ESTATÍSTICAS
-- ---------------------------------------------------------------------------
-- Estatísticas = "chutes matemáticos" do Query Optimizer (QO).
-- Quando o chute é ruim (Stale Stats), o QO escolhe o plano errado e o hardware sofre.

USE Financiamento_PROD;
GO

SELECT
    OBJECT_NAME(stat.object_id)   AS [Tabela],
    stat.name                     AS [Nome_da_Estatistica],
    sp.last_updated               AS [Ultima_Atualizacao],
    sp.rows                       AS [Linhas_na_Tabela],
    sp.rows_sampled               AS [Linhas_Lidas_para_o_Chute],
    sp.modification_counter       AS [Linhas_Modificadas_Desde_Ultimo_Update]
FROM sys.stats AS stat
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE OBJECT_NAME(stat.object_id) NOT LIKE 'sys%'
ORDER BY sp.modification_counter DESC; -- Mais desatualizada primeiro
GO