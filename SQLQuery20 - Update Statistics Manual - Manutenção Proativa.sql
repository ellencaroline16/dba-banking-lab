-- ---------------------------------------------------------------------------
-- 2. UPDATE STATISTICS MANUAL (Manutenção Proativa)
-- ---------------------------------------------------------------------------
-- Problema: em tabelas gigantes o auto-update tem threshold alto.
-- Com 100 mil novos clientes/dia, o QO fica "cego" para os dados novos.

USE Financiamento_PROD;
GO
UPDATE STATISTICS Cadastros.Clientes WITH FULLSCAN; -- Lê 100% das páginas de 8KB
GO