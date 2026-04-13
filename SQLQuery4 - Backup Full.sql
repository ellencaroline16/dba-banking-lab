BACKUP DATABASE [Financiamento_PROD]
TO DISK = 'C:\Auditoria\Financiamento_PROD_Full.bak'
WITH
    FORMAT,      -- Cria novo conjunto de backup (limpa se existir)
    COMPRESSION, -- Reduz tamanho e tempo de escrita no disco
    CHECKSUM,    -- OBRIGATÓRIO: valida páginas de 8KB antes de gravar
    STATS = 10,  -- Avisa a cada 10% concluído
    NAME = 'Full Backup de Financiamento_PROD';
GO