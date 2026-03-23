/*
 PROCEDURE DE IDADE (ALURA)

SELECT CPF, NOME, DatadeNascimento FROM [TABELA DE CLIENTES]

SELECT CPF, NOME, DatadeNascimento, DATEDIFF(YEAR, DatadeNascimento, GETDATE()) AS Idade FROM [TABELA DE CLIENTES]

UPDATE [TABELA DE CLIENTES] SET DatadeNascimento = DATEDIFF(YEAR, DatadeNascimento, GETDATE())

CREATE PROCEDURE CalculaIdade
AS
BEGIN
UPDATE [TABELA DE CLIENTES] SET DatadeNascimento = DATEDIFF(YEAR, DatadeNascimento, GETDATE())
END

INSERT INTO 

EXEC */



-- Procedure para listar planos vencidos, medindo pela data de início x prazo meses e o status 

CREATE PROCEDURE dbo.ListarEmprestimosVencidos
AS
BEGIN
    SET NOCOUNT ON;
 
    SELECT
        emp.id_emprestimo AS CodigoEmprestimo,
        cli.Nome          AS Cliente,
        prod.NomeProduto  AS TipoProduto,
        emp.Valor         AS ValorContratado,
        emp.PrazoMeses    AS PrazoMeses,
        emp.DataInicio    AS DataInicio,
        DATEADD(MONTH, emp.PrazoMeses, emp.DataInicio) AS DataPrevistaFim,
        emp.Status        AS StatusAtual,
        DATEDIFF(DAY, GETDATE(), DATEADD(MONTH, emp.PrazoMeses, emp.DataInicio)) AS DiasRestantes
    FROM dbo.[TABELA DE EMPRESTIMOS] emp
    INNER JOIN dbo.[TABELA DE CLIENTES]  cli  ON cli.id_cliente  = emp.id_cliente
    INNER JOIN dbo.[TABELA DE PRODUTOS]  prod ON prod.id_produto = emp.id_produto
    WHERE emp.Status <> 'LIQUIDADO'
    ORDER BY DiasRestantes ASC;
END;
GO

INSERT [TABELA DE EMPRESTIMOS] (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status)
VALUES (1,(SELECT TOP 1 id_produto FROM [TABELA DE PRODUTOS] WHERE NomeProduto = 'PESSOAL'),15000.00, 0.0250000, 12, '2022-01-10', 'ATIVO');

EXEC ListarEmprestimosVencidos;


-- Procedure para verificar a saúde financeira do cliente e o relacionamento dele com o banco

CREATE PROCEDURE dbo.ResumoClienteFinanceiro
    @id_cliente INT
AS
BEGIN
    SET NOCOUNT ON;
 
    SELECT
        cli.id_cliente                        AS CodigoCliente,
        cli.Nome                              AS NomeCliente,
        cli.CPF                               AS CPF,
        COUNT(DISTINCT ct.id_conta)           AS QtdeContas,
        COUNT(DISTINCT emp.id_emprestimo)     AS QtdeEmprestimos,
        SUM(emp.Valor)                        AS TotalEmprestado,
        SUM(
            CASE
                WHEN tp.Natureza = 'CREDITO' THEN tr.Valor
                WHEN tp.Natureza = 'DEBITO'  THEN -tr.Valor
                ELSE 0
            END
        ) AS SaldoMovimentado
    FROM dbo.[TABELA DE CLIENTES]       cli
    LEFT JOIN dbo.[TABELA DE CONTAS]   ct  ON ct.id_cliente  = cli.id_cliente
    LEFT JOIN dbo.[TABELA DE TRANSACOES] tr ON tr.id_conta   = ct.id_conta
    LEFT JOIN dbo.[TABELA DE TIPOS DE TRANSACOES] tp
           ON tp.id_tipo_transacao = tr.id_tipo_transacao
    LEFT JOIN dbo.[TABELA DE EMPRESTIMOS] emp
           ON emp.id_cliente = cli.id_cliente
    WHERE cli.id_cliente = @id_cliente
    GROUP BY cli.id_cliente, cli.Nome, cli.CPF;
END;
GO

EXEC ResumoClienteFinanceiro @id_cliente = 1;