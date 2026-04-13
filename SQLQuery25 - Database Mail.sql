-- ---------------------------------------------------------------------------
-- HISTÓRICO DO DATABASE MAIL (diagnóstico de alertas)
-- ---------------------------------------------------------------------------
-- Database Mail usa Service Broker: ASSÍNCRONO.
-- O motor não trava esperando o e-mail ser enviado.

USE msdb;
GO

SELECT
    mailitem_id,
    recipients        AS [Destinatario],
    subject           AS [Assunto],
    send_request_date AS [Data_Tentativa_Envio],
    sent_status       AS [Status_do_Envio] -- 'sent', 'failed', 'unsent'
FROM sysmail_allitems
ORDER BY send_request_date DESC;
GO

-- Verificar erros de envio:
SELECT * FROM sysmail_event_log
WHERE log_level = 'error'
ORDER BY log_date DESC;
GO


USE msdb;
GO

EXEC sp_send_dbmail
    @profile_name = 'DBA_Alertas',
    @recipients   = 'ellen_caroline_17@hotmail.com',
    @subject      = 'Teste Database Mail — Banco ABC',
    @body         = 'Se você recebeu este e-mail, o Database Mail está configurado corretamente! O robô DBA está de plantão.';
GO