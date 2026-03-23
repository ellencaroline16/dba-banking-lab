
SET NOCOUNT ON;
SET XACT_ABORT ON;
 
DECLARE @Qtde int = 8000000;
DECLARE @maxCliAntes int = ISNULL((SELECT MAX(id_cliente) FROM dbo.[TABELA DE CLIENTES]),0);

WITH N AS (
  SELECT TOP (@Qtde) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
)

INSERT INTO dbo.[TABELA DE CLIENTES]
  (CPF, Nome, Email, DatadeNascimento, Rua, Bairro, Cidade, Estado, CEP)
SELECT
  RIGHT('00000000000' + CAST(10000000000 + (@maxCliAntes + n) AS varchar(11)), 11) AS CPF,   -- único
  CONCAT('Cliente ', @maxCliAntes + n)                           AS Nome,
  CONCAT('cliente', @maxCliAntes + n, '@exemplo.com')           AS Email,
  /* idade entre 18 e 65 */
  CONVERT(date, DATEADD(year, - (18 + ((@maxCliAntes + n) % 48)), GETDATE())) AS DatadeNascimento,
  CONCAT('Rua ', @maxCliAntes + n)            AS Rua,
  CONCAT('Bairro ', 1 + ((@maxCliAntes + n) % 20)) AS Bairro,
  CONCAT('Cidade ', 1 + ((@maxCliAntes + n) % 10)) AS Cidade,
  CASE (@maxCliAntes + n) % 5
       WHEN 0 THEN 'SP' WHEN 1 THEN 'RJ' WHEN 2 THEN 'MG' WHEN 3 THEN 'BA' ELSE 'PR' END AS Estado,
  RIGHT('00000000' + CAST(11000000 + ((@maxCliAntes + n) % 800000) AS varchar(8)), 8) AS CEP
FROM N;
 
DECLARE @minNovoCli int = @maxCliAntes + 1,
        @maxNovoCli int = (SELECT MAX(id_cliente) FROM dbo.[TABELA DE CLIENTES]);
 

WITH Novos AS (
  SELECT id_cliente,
         ROW_NUMBER() OVER (ORDER BY id_cliente) AS rn
  FROM dbo.[TABELA DE CLIENTES]
  WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli
)

INSERT INTO dbo.[TABELA DE TELEFONES] (Telefone, id_cliente)
SELECT
  CONCAT('11', RIGHT('000000000', 9 - LEN(rn)), rn) AS Telefone,  -- 11 + sequencial
  id_cliente
FROM Novos;
 

DECLARE @idBRL int = (SELECT id_moeda FROM dbo.[TABELA DE MOEDAS] WHERE CodigoMoeda='BRL');
IF @idBRL IS NULL RAISERROR('Moeda BRL não encontrada.', 16, 1);
 
WITH Novos AS (
  SELECT id_cliente,
         ROW_NUMBER() OVER (ORDER BY id_cliente) AS rn
  FROM dbo.[TABELA DE CLIENTES]
  WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli
)
INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda)
SELECT
  -- Numeração simples 80000-x + DV (rn % 9 + 1)
  CONCAT(90000 + rn, '-', (rn % 9) + 1) AS NumeroConta,
  n.id_cliente,
  (SELECT id_agencia
     FROM dbo.[TABELA DE AGENCIAS]
     WHERE NumeroAgencia = RIGHT('000' + CAST(1 + ((rn-1) % 3) AS varchar(3)), 4)  -- 0001..0003
  ) AS id_agencia,
  @idBRL AS id_moeda
FROM Novos n;
 

;WITH NovasContas AS (
  SELECT c.id_conta, c.id_cliente,
         ROW_NUMBER() OVER (ORDER BY c.id_conta) AS rn
  FROM dbo.[TABELA DE CONTAS] c
  WHERE c.id_cliente BETWEEN @minNovoCli AND @maxNovoCli
)
INSERT INTO dbo.[TABELA DE EMPRESTIMOS]
  (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status)
SELECT
  nc.id_cliente,
  (SELECT id_produto FROM dbo.[TABELA DE PRODUTOS]
     WHERE NomeProduto = CASE (nc.rn % 3)
                           WHEN 1 THEN 'PESSOAL'
                           WHEN 2 THEN 'CONSIGNADO'
                           ELSE 'GARANTIA' END),
  -- valor base variando por rn (mínimo 5.000, máximo ~54.990)
  CAST(5000 + ((nc.rn * 37) % 50000) AS decimal(15,2)) AS Valor,
  -- taxa por produto
  CASE (nc.rn % 3)
    WHEN 1 THEN 0.250000  -- PESSOAL
    WHEN 2 THEN 0.180000  -- CONSIGNADO
    ELSE 0.150000         -- GARANTIA
  END AS TaxaAnual,
  12 + ((nc.rn * 5) % 84) AS PrazoMeses,        -- 12..95
  CAST(GETDATE() AS date) AS DataInicio,
  'APROVADO' AS Status
FROM NovasContas nc;
 

DECLARE @idDeposito int =
  (SELECT id_tipo_transacao FROM dbo.[TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO');
IF @idDeposito IS NULL RAISERROR('Tipo DEPOSITO não encontrado.', 16, 1);
 
INSERT INTO dbo.[TABELA DE TRANSACOES] (id_conta, id_tipo_transacao, Valor, Descricao)
SELECT c.id_conta, @idDeposito,
       CAST(100 + ((c.id_conta * 17) % 4900) AS decimal(18,2)) AS Valor,  -- 100..4999
       'Depósito de abertura (massa)'
FROM dbo.[TABELA DE CONTAS] c
WHERE c.id_cliente BETWEEN @minNovoCli AND @maxNovoCli;
 

SELECT COUNT(*) AS NovosClientes FROM dbo.[TABELA DE CLIENTES]  WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli;
SELECT COUNT(*) AS NovosTelefones FROM dbo.[TABELA DE TELEFONES] WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli;
SELECT COUNT(*) AS NovasContas   FROM dbo.[TABELA DE CONTAS]    WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli;
SELECT COUNT(*) AS NovosEmp      FROM dbo.[TABELA DE EMPRESTIMOS] WHERE id_cliente BETWEEN @minNovoCli AND @maxNovoCli;
SELECT COUNT(*) AS NovasTrans    FROM dbo.[TABELA DE TRANSACOES] t
JOIN dbo.[TABELA DE CONTAS] c ON c.id_conta=t.id_conta
WHERE c.id_cliente BETWEEN @minNovoCli AND @maxNovoCli;

