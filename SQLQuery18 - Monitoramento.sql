-- ---------------------------------------------------------------------------
-- 3. MONITORAMENTO DE LATÊNCIA FÍSICA (I/O Stalls)
-- ---------------------------------------------------------------------------
-- I/O Stall = tempo de espera para o disco ler ou gravar uma página.
-- Ideal: < 10ms. Acima de 50ms = sinal de alerta crítico.

SELECT
    DB_NAME(database_id)                                                         AS [Banco],
    file_id,
    io_stall_read_ms  / CASE WHEN num_of_reads  = 0 THEN 1 ELSE num_of_reads  END AS [Latencia_Leitura_MS],
    io_stall_write_ms / CASE WHEN num_of_writes = 0 THEN 1 ELSE num_of_writes END AS [Latencia_Escrita_MS],
    CAST((size_on_disk_bytes / 1024.0 / 1024.0) AS DECIMAL(10,2))                AS [Tamanho_MB]
FROM sys.dm_io_virtual_file_stats(NULL, NULL)
WHERE DB_NAME(database_id) IN ('Financiamento_PROD', 'Financiamento_HOM');
GO