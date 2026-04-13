-- ---------------------------------------------------------------------------
-- 1. SIMULAÇÃO DE BLOCKING (rode em HOM, em duas abas do SSMS)
-- ---------------------------------------------------------------------------
-- ABA 1: deixa a transação aberta sem COMMIT (o "vilão"):
USE Financiamento_PROD;
GO
BEGIN TRAN;
    SELECT TOP 1 * FROM Cadastros.Clientes WITH (TABLOCKX); -- Trava o prédio inteiro
-- NÃO execute COMMIT aqui — vá para a ABA 2 enquanto isso

-- ABA 2 (nova janela do SSMS): tenta ler a mesma tabela (a "vítima"):
USE Financiamento_PROD;
GO
SELECT TOP 10 * FROM Cadastros.Clientes; -- Vai ficar pendurada esperando...
GO


-- ---------------------------------------------------------------------------
-- 2. DASHBOARD DE WAITS E BLOCKINGS (consulte em uma terceira aba)
-- ---------------------------------------------------------------------------

SELECT
    r.session_id          AS [Sessao_Vitima],
    r.blocking_session_id AS [Sessao_Culpada_Vilao],
    r.wait_type           AS [Motivo_da_Espera],
    r.wait_time / 1000.0  AS [Tempo_Esperando_Segundos],
    DB_NAME(r.database_id) AS [Banco_de_Dados],
    st.text               AS [Query_da_Vitima]
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id > 50       -- Ignora processos internos do SQL
  AND r.session_id <> @@SPID; -- Ignora a sua própria pesquisa
GO

-- Para matar o vilão (substitua 53 pelo SPID do bloqueador):
KILL 53;
GO