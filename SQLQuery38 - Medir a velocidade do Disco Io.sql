-- ---------------------------------------------------------------------------
-- TESTE DE STRESS DE RESTORE (medir a velocidade real do disco)
-- ---------------------------------------------------------------------------
-- Fórmula do RTO: Tamanho do banco (MB) ÷ Velocidade do disco (MB/s) = segundos
-- Exemplo: 500GB (512.000 MB) ÷ 80 MB/s = 6.400s = 106 minutos
-- Se a diretoria quer 30 min de RTO → precisam de SSD NVMe.

USE master;
GO
ALTER DATABASE [Financiamento_HOM] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE [Financiamento_HOM]
FROM DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH
    REPLACE,
    RECOVERY, -- Deixa o banco online ao terminar
    STATS = 1; -- Avisa a cada 1% — use para medir a velocidade do disco
GO

ALTER DATABASE [Financiamento_HOM] SET MULTI_USER;
GO

-- Calcular a velocidade de I/O medida pelo teste:
SELECT
    DB_NAME(database_id)                                                          AS [Banco],
    io_stall_read_ms  / CASE WHEN num_of_reads  = 0 THEN 1 ELSE num_of_reads  END AS [Latencia_Leitura_MS],
    io_stall_write_ms / CASE WHEN num_of_writes = 0 THEN 1 ELSE num_of_writes END AS [Latencia_Escrita_MS],
    CAST(size_on_disk_bytes / 1024.0 / 1024.0 AS DECIMAL(10,2))                  AS [Tamanho_MB]
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
WHERE DB_NAME(database_id) = 'Financiamento_HOM';
GO
