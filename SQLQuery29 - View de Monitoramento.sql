-- ---------------------------------------------------------------------------
-- 3. CRIAR O DASHBOARD COMO VIEW (Entregável Oficial da Semana 11)
-- ---------------------------------------------------------------------------

USE Financiamento_PROD;
GO

-- Criar o Schema de Monitoramento (sala da equipe de Infra):
CREATE SCHEMA Monitoramento;
GO

-- Criar a View (a "janela" para o trânsito do servidor):
CREATE VIEW Monitoramento.vw_Dashboard_Waits AS
SELECT
    r.session_id          AS [Sessao_Vitima],
    r.blocking_session_id AS [Sessao_Culpada_Vilao],
    r.wait_type           AS [Motivo_da_Espera],
    r.wait_time / 1000.0  AS [Tempo_Esperando_Segundos],
    DB_NAME(r.database_id) AS [Banco_de_Dados],
    st.text               AS [Query_da_Vitima]
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id > 50
  AND r.session_id <> @@SPID;
GO

-- Como qualquer pessoa da equipe usa o dashboard:
SELECT * FROM Monitoramento.vw_Dashboard_Waits;
GO