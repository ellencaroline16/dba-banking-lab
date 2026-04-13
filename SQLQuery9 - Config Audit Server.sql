-- ---------------------------------------------------------------------------
-- 1. CONFIGURAÇÃO DE SQL SERVER AUDIT
-- ---------------------------------------------------------------------------
-- Vantagem: ASSÍNCRONO — usa buffer de memória, não gera Wait Stats nas transações.

-- 1a. Descobrir o caminho de log da instância automaticamente:
DECLARE @logpath NVARCHAR(4000);
SELECT @logpath = LEFT(
    CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(4000)),
    LEN(CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(4000))) -
    CHARINDEX('\', REVERSE(CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(4000))))
);
PRINT 'Caminho de log: ' + @logpath;
GO

SELECT CAST(SERVERPROPERTY('ErrorLogFileName') AS NVARCHAR(4000)) AS [Caminho_Real_do_Log];
GO

-- 1b. Criar o Server Audit (onde gravar):
USE master;
GO
CREATE SERVER AUDIT [Auditoria_Financiamento]
TO FILE (FILEPATH = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Log\')
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO
ALTER SERVER AUDIT [Auditoria_Financiamento] WITH (STATE = ON);
GO

-- Versão com pasta personalizada (ajuste conforme seu servidor):
USE master;
GO
CREATE SERVER AUDIT [Audit_Acesso_Financeiro]
TO FILE (FILEPATH = 'C:\Auditoria\')
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO
ALTER SERVER AUDIT [Audit_Acesso_Financeiro] WITH (STATE = ON);
GO

-- 1c. Criar a Database Audit Specification (o que vigiar):
USE Financiamento_PROD;
GO
CREATE DATABASE AUDIT SPECIFICATION [Audit_Acesso_Sensivel]
FOR SERVER AUDIT [Auditoria_Financiamento]
ADD (SELECT ON SCHEMA::Financeiro BY [public]),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),     -- tentativas de elevação de privilégio
ADD (DATABASE_OBJECT_ACCESS_GROUP)               -- falhas de acesso (Erro 229)
WITH (STATE = ON);
GO

-- 1d. Adicionar o schema Cadastros à auditoria (alterar especificação existente):
USE Financiamento_PROD;
GO
ALTER DATABASE AUDIT SPECIFICATION [Audit_Acesso_Sensivel] WITH (STATE = OFF);
GO
ALTER DATABASE AUDIT SPECIFICATION [Audit_Acesso_Sensivel]
ADD (SELECT ON SCHEMA::Cadastros BY [public]);
GO
ALTER DATABASE AUDIT SPECIFICATION [Audit_Acesso_Sensivel] WITH (STATE = ON);
GO

-- 1e. Aplicar Filtro de Predicado (exclui processos automáticos do log):
USE master;
GO
ALTER SERVER AUDIT [Audit_Acesso_Financeiro] WITH (STATE = OFF);
GO
ALTER SERVER AUDIT [Audit_Acesso_Financeiro]
WHERE [server_principal_name] <> 'User_App_Automated'; -- Reduz ruído no log
GO
ALTER SERVER AUDIT [Audit_Acesso_Financeiro] WITH (STATE = ON);
GO

-- 1f. Lendo a "fita da câmera" (logs de auditoria):
SELECT
    event_time                    AS [Data_Hora],
    session_server_principal_name AS [Quem],
    action_id                     AS [Acao],
    succeeded                     AS [Sucesso],
    statement                     AS [Comando_Executado],
    object_name                   AS [Tabela_Alvo]
FROM sys.fn_get_audit_file(
    'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Log\Auditoria_Financiamento*',
    NULL, NULL);
GO