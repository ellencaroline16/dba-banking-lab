CREATE TRIGGER TG_TRANSACOES_FEITAS
ON [TABELA DE TRANSACOES] 
AFTER INSERT, UPDATE, DELETE 
AS 
BEGIN 
DELETE FROM [TABELA TOTAL DE TRANSACOES]; 

INSERT INTO [TABELA TOTAL DE TRANSACOES] ( DataTransacao, NomeTipo, TotalTransacao)
SELECT 
    CAST(t.DataTransacao AS date)
AS DataTransacao, 'TOTAL'
AS NomeTipo,
    SUM(CASE WHEN tp.Natureza = 'CREDITO' THEN t.Valor
        WHEN tp.Natureza = 'DEBITO' THEN t.Valor
    ELSE 0 END)
AS TotalTransacao
FROM [TABELA DE TRANSACOES] AS t
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS tp
ON tp.id_tipo_transacao = t.id_tipo_transacao
GROUP BY CAST(t.DataTransacao AS date)
ORDER BY CAST(t.DataTransacao AS date);

END;


INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao, DataTransacao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10003-3'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
      10000.00, 'Depósito do salário - Dan', CAST(GETDATE() AS date));

CREATE TABLE [TABELA DE SALDO POR CONTA]
(id_conta INT NOT NULL,
MovimentacaoSaldo FLOAT NULL);

SELECT
t.id_conta,
SUM(CASE WHEN tp.Natureza = 'CREDITO' THEN t.Valor
        WHEN tp.Natureza = 'DEBITO' THEN t.Valor
    ELSE 0 END) AS MovimentacaoSaldo
FROM [TABELA DE TRANSACOES] AS t
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS tp
ON tp.id_tipo_transacao = t.id_tipo_transacao
GROUP BY id_conta;

CREATE TRIGGER TG_SALDOPOR_CONTA
ON [TABELA DE TRANSACOES]
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
DELETE FROM [TABELA DE SALDO POR CONTA]

INSERT INTO [TABELA DE SALDO POR CONTA] (id_conta, MovimentacaoSaldo)
SELECT
t.id_conta,
SUM(CASE WHEN tp.Natureza = 'CREDITO' THEN t.Valor
        WHEN tp.Natureza = 'DEBITO' THEN t.Valor
    ELSE 0 END) AS MovimentacaoSaldo
FROM [TABELA DE TRANSACOES] AS t
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS tp
ON tp.id_tipo_transacao = t.id_tipo_transacao
GROUP BY id_conta;

END;
