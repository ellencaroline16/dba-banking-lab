
-- Criando a tabela de clientes 
CREATE TABLE [TABELA DE CLIENTES] ( 
  id_cliente INT IDENTITY (1,1) PRIMARY KEY, 
  CPF CHAR (11) NOT NULL, 
  Nome VARCHAR (250) NOT NULL, 
  Email VARCHAR (250) NOT NULL, 
  DatadeNascimento DATE NOT NULL, 
  Rua VARCHAR (250) NOT NULL, 
  Bairro VARCHAR (80) NOT NULL, 
  Cidade VARCHAR (80) NOT NULL, 
  Estado VARCHAR (2) NOT NULL, 
  CEP CHAR (8)  NOT NULL, 
  CONSTRAINT UQ_TabelaClientes_CPF UNIQUE (CPF) 
); 

-- Criando a tabela de telefones
CREATE TABLE [TABELA DE TELEFONES] ( 
  id_telefone INT IDENTITY (1,1) PRIMARY KEY, 
  Telefone VARCHAR (20) NOT NULL, 
  id_cliente INT NOT NULL, 
  CONSTRAINT FK_Telefone_Cliente 
    FOREIGN KEY (id_cliente) REFERENCES [TABELA DE CLIENTES] (id_cliente) 
); 

-- Inserindo clientes/populando a base
INSERT INTO [TABELA DE CLIENTES] 
  (CPF, Nome, Email, DatadeNascimento, Rua, Bairro, Cidade, Estado, CEP) 
VALUES ('12345678910','Phoebe Buffay','phoebe.buffay@email.com','1967-02-16','Bedford Street, 80','Greenwitch Village','Nova Iorque','NY','09582050'), 
('09856321705','Rachel Green','rachel.green@email.com','1970-05-05',' Bedford Street, 70',' Greenwitch Village','Nova Iorque','NY','09582050'), 
('86974512308','Monica Geller','monica.geller@email.com','1970-03-23',' Bedford Street, 80',' Greenwitch Village','Nova Iorque','NY','09582050'),
('59786632215','Ross Geller','ross.geller@email.com','1967-10-18','Rodeo Drive, 60','Beverly Hills','Los Angeles','LA','09583050'),
('00258996842','Chandler Bing','chandler.bing@email.com','1968-04-08','Ocean Drive, 20','Miami','Florida','FL','09586050'), 
('88779922548','Joey Tribbiani','joey.tribbiani@email.com','1968-04-24','International Drive, 100','Orlando','Florida','FL','09589050');

-- Inserindo a tabela de telefones
INSERT INTO [TABELA DE TELEFONES] (Telefone, id_cliente) 
VALUES ('11966335591', 1), 
       ('11988955685', 2),
       ('11936547892', 3),
       ('11945489966', 4),
       ('11982197536', 5),
       ('11922157984', 6),
       ('11922158574', 3);

-- Join/Junção da tabela de clientes + telefone
SELECT c.Nome, t.Telefone 
FROM [TABELA DE CLIENTES] c 
JOIN [TABELA DE TELEFONES] t ON c.id_cliente = t.id_cliente 
ORDER BY c.id_cliente; 

SELECT * FROM [TABELA DE CLIENTES];

-- Ajustar dps p/ os telefones aparecerem na tabela de clientes

--Testes com os filtros (Alura)

-- Um e/ou outro usando OR
SELECT [Nome],[Estado] FROM [TABELA DE CLIENTES] 
WHERE [Estado]='NY' OR [Estado]='LA';

-- Where + operador lógico maior que > 
SELECT * FROM [TABELA DE CLIENTES] 
WHERE DatadeNascimento > '1968-10-14'; 

-- Like - Começa com a palavra e termina com qualquer texto
SELECT * FROM [TABELA DE CLIENTES] WHERE (Rua LIKE 'Bedford%'); 

--Like - Começa c/ qualquer texto, tem a palavra no meio e termina com outro texto
SELECT * FROM [TABELA DE CLIENTES] WHERE (Rua LIKE '%Drive%'); 

SELECT [Cidade] FROM [TABELA DE CLIENTES]; 

-- Filtra as cidades e evita a duplicidade
SELECT DISTINCT [Cidade] FROM [TABELA DE CLIENTES];

-- Ranking
SELECT TOP 2 * FROM [TABELA DE CLIENTES]; 

-- Ordenando com o ORDER BY e em ordem crescente e decrescente 
SELECT * FROM [TABELA DE CLIENTES] ORDER BY [Bairro] DESC, [Rua] ASC;

-- Criando a tabela de produtos
CREATE TABLE dbo.[TABELA DE PRODUTOS] ( 
  id_produto      INT IDENTITY(1,1) PRIMARY KEY, 
  NomeProduto     VARCHAR(50)  NOT NULL,   -- 'PESSOAL','CONSIGNADO','GARANTIA' 
  Descricao       VARCHAR(200) NULL, 
  PrazoMaxMeses   INT          NOT NULL, 
  ValorMaximo     DECIMAL(15,2) NOT NULL, 
  TaxaJurosAnual  DECIMAL(9,6)  NOT NULL   -- 0.250000 = 25% a.a. 
); 

-- Produtos bancários (dados fictícios)
INSERT INTO dbo.[TABELA DE PRODUTOS] 
  (NomeProduto, Descricao, PrazoMaxMeses, ValorMaximo, TaxaJurosAnual) 
VALUES 
('PESSOAL','Sem garantia',                      48,  50000.00, 0.250000), 
('CONSIGNADO','Desconto em folha',              96, 200000.00, 0.180000), 
('GARANTIA','Com garantia (veículo/imóvel)',   120, 300000.00, 0.150000); 

-- Consultando a tabela de produtos
SELECT * FROM dbo.[TABELA DE PRODUTOS] ORDER BY NomeProduto;

-- Criando a tabela de empréstimos 
CREATE TABLE dbo.[TABELA DE EMPRESTIMOS] ( 
  id_emprestimo  INT IDENTITY(1,1) PRIMARY KEY, 
  id_cliente     INT          NOT NULL,     -- quem contratou
  id_produto     INT          NOT NULL,     -- qual é o produto adquirido
  Valor          DECIMAL(15,2) NOT NULL,    -- qual o valor solicitado
  TaxaAnual      DECIMAL(9,6)  NOT NULL,    -- ex.: 0.250000 = 25% a.a. 
  PrazoMeses     INT           NOT NULL,    -- em quantos meses será pago
  DataInicio     DATE          NOT NULL,    -- quando irá se iniciar 
  Status         VARCHAR(30)   NOT NULL,    -- APROVADO/ATIVO/LIQUIDADO/RECUSADO
  CONSTRAINT FK_Emprestimo_Cliente 
    FOREIGN KEY (id_cliente) REFERENCES [TABELA DE CLIENTES](id_cliente), 
  CONSTRAINT FK_Emprestimo_Produto 
    FOREIGN KEY (id_produto) REFERENCES dbo.[TABELA DE PRODUTOS](id_produto) 
); 

-- Populando a parte de empréstimo através de subqueries, um por um p/ não me perder, e utilizando o CAST p/ conversão para data

INSERT INTO dbo.[TABELA DE EMPRESTIMOS]  (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status) 
VALUES ( 
  (SELECT id_cliente FROM [TABELA DE CLIENTES]  WHERE Nome='Rachel Green'), 
  (SELECT id_produto FROM dbo.[TABELA DE PRODUTOS] WHERE NomeProduto='CONSIGNADO'), 
  20000.00, 0.180000, 24, CAST(GETDATE() AS DATE), 'APROVADO' 
); 

INSERT INTO dbo.[TABELA DE EMPRESTIMOS] (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status) 
VALUES ( 
  (SELECT id_cliente FROM [TABELA DE CLIENTES]  WHERE Nome='Phoebe Buffay'), 
  (SELECT id_produto FROM dbo.[TABELA DE PRODUTOS] WHERE NomeProduto='PESSOAL'), 
  10000.00, 0.250000, 12, CAST(GETDATE() AS DATE), 'APROVADO' 
); 

INSERT INTO dbo.[TABELA DE EMPRESTIMOS]  (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status) 
VALUES ( 
  (SELECT id_cliente FROM [TABELA DE CLIENTES]  WHERE Nome='Monica Geller'), 
  (SELECT id_produto FROM dbo.[TABELA DE PRODUTOS] WHERE NomeProduto='GARANTIA'), 
  80000.00, 0.150000, 48, CAST(GETDATE() AS DATE), 'APROVADO' 
); 

INSERT INTO dbo.[TABELA DE EMPRESTIMOS]  (id_cliente, id_produto, Valor, TaxaAnual, PrazoMeses, DataInicio, Status) 
VALUES ( 
  (SELECT id_cliente FROM [TABELA DE CLIENTES]  WHERE Nome='Ross Geller'), 
  (SELECT id_produto FROM dbo.[TABELA DE PRODUTOS] WHERE NomeProduto='GARANTIA'), 
  90000.00, 0.200000, 50, CAST(GETDATE() AS DATE), 'ATIVO' 
);


-- Conferindo se deu certo
SELECT * FROM dbo.[TABELA DE EMPRESTIMOS]; 
SELECT e.id_emprestimo, 
       c.Nome        AS Cliente, 
       p.NomeProduto AS Produto, 
       e.Valor, e.PrazoMeses, e.TaxaAnual, e.Status, e.DataInicio 
FROM dbo.[TABELA DE EMPRESTIMOS] e 
JOIN [TABELA DE CLIENTES]      c ON c.id_cliente = e.id_cliente 
JOIN dbo.[TABELA DE PRODUTOS]  p ON p.id_produto = e.id_produto 
ORDER BY e.id_emprestimo;

-- Deletando empréstimo duplicado
DELETE FROM [TABELA DE EMPRESTIMOS] WHERE id_emprestimo = 4;

SELECT * FROM [TABELA DE CLIENTES];

-- Atualizando o e-mail da Rachel
UPDATE [TABELA DE CLIENTES] 
SET Email = 'rachelgreen.novo@email.com'
WHERE Nome = 'Rachel Green';

SELECT * FROM [TABELA DE CLIENTES] WHERE Email = 'rachelgreen.novo@email.com';

UPDATE [TABELA DE EMPRESTIMOS]
SET Status = 'REPROVADO'
WHERE id_cliente = 1 ;

UPDATE [TABELA DE EMPRESTIMOS]
SET Status = 'LIQUIDADO'
WHERE id_emprestimo = 3;

-- Unir tabela de cliente e de empréstimo para mostrar o valor que cada um pegou emprestado + status do emprestimo 
-- Testar PF e FK, testar inserção inválida
-- Criar tabelas relacionadas, contas clientes, transações, moedas, agências
-- Funções agregadas (utilizar nas tabelas relacionadas 

-- Criando a tabela de agências
CREATE TABLE [TABELA DE AGENCIAS] (
id_agencia INT IDENTITY (1,1) PRIMARY KEY,
NumeroAgencia VARCHAR (06) NOT NULL UNIQUE,
NomeAgencia VARCHAR (50) NOT NULL);

-- Criando a tabela de moedas
CREATE TABLE [TABELA DE MOEDAS] (
id_moeda INT IDENTITY (1,1) PRIMARY KEY,
CodigoMoeda CHAR (3) NOT NULL UNIQUE, -- USD, BRL, EUR
NomeMoeda VARCHAR (30) NOT NULL);

-- Criando a tabela de contas
CREATE TABLE [TABELA DE CONTAS] (
id_conta INT IDENTITY(1,1) PRIMARY KEY,
NumeroConta VARCHAR (20) NOT NULL UNIQUE,
id_cliente INT NOT NULL,
id_agencia INT NOT NULL,
id_moeda INT NOT NULL,
Saldo DECIMAL(18,2) NOT NULL DEFAULT (0.00),  -- padronizando a forma como o valor deve ser evidenciado
DataAbertura DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
CONSTRAINT FK_Conta_Cliente FOREIGN KEY (id_cliente) REFERENCES [TABELA DE CLIENTES] (id_cliente),
CONSTRAINT FK_Conta_Agencia FOREIGN KEY (id_agencia) REFERENCES [TABELA DE AGENCIAS] (id_agencia),
CONSTRAINT FK_Conta_Moeda FOREIGN KEY (id_moeda) REFERENCES [TABELA DE MOEDAS] (id_moeda));


-- Criando a tabela com os tipos transações
CREATE TABLE [TABELA DE TIPOS DE TRANSACOES] (
id_tipo_transacao INT IDENTITY (1,1) PRIMARY KEY,
NomeTipo VARCHAR (30) NOT NULL UNIQUE, -- Depósito, Saque, Transferência
Natureza VARCHAR (10) NOT NULL CHECK (Natureza IN ('CREDITO', ' DEBITO')));


-- Criando a tabela de transações
CREATE TABLE [TABELA DE TRANSACOES] (
  id_transacao INT IDENTITY(1,1) PRIMARY KEY,
  id_conta INT  NOT NULL,
  id_tipo_transacao INT NOT NULL,
  Valor  DECIMAL(18,2) NOT NULL,
  DataTransacao DATETIME  NOT NULL DEFAULT (GETDATE()), -- o getdate pega a data e hora atual de forma automática
  Descricao VARCHAR(100) NULL,
  CONSTRAINT FK_Transacao_Conta FOREIGN KEY (id_conta) REFERENCES [TABELA DE CONTAS](id_conta),
  CONSTRAINT FK_Transacao_Tipo FOREIGN KEY (id_tipo_transacao) REFERENCES [TABELA DE TIPOS DE TRANSACOES](id_tipo_transacao)
);

-- Massa de informações via insert (populando) 
INSERT INTO [TABELA DE CLIENTES] (CPF, Nome, Email, DataDeNascimento, Rua, Bairro, Cidade, Estado, CEP) VALUES ('11111111111','Serena van der Woodsen','serena@gossip.com','1988-07-14','5th Avenue, 101','Upper East Side','New York','NY','10021'),
('22222222222','Blair Waldorf','blair@gossip.com','1988-11-15','Park Avenue, 45','Upper East Side','New York','NY','10022'),
('33333333333','Dan Humphrey','dan@gossip.com','1989-02-20','Brooklyn Heights, 12','Brooklyn','New York','NY','11201'),
('44444444444','Nate Archibald','nate@gossip.com','1989-04-05','Madison Avenue, 200','Upper East Side','New York','NY','10023'),
('55555555555','Chuck Bass','chuck@gossip.com','1988-06-10','Empire Hotel, 33','Manhattan','New York','NY','10024'),
('66666666666','Meredith Grey','meredith@greys.com','1978-09-27','Seattle Grace St, 1','Capitol Hill','Seattle','WA','98101'),
('77777777777','Derek Shepherd','derek@greys.com','1966-11-13','Lakeview Road, 20','Queen Anne','Seattle','WA','98102'),
('88888888888','Cristina Yang','cristina@greys.com','1976-03-20','Broadway Ave, 300','Capitol Hill','Seattle','WA','98103'),
('99999999999','Alex Karev','alex@greys.com','1975-01-10','Harborview St, 12','Downtown','Seattle','WA','98104'),
('00000000000','Miranda Bailey','bailey@greys.com','1970-05-23','Pine Street, 89','First Hill','Seattle','WA','98105');

-- Usando Union ALL na tabela para unir o telefone com cliente ao invés do Join
INSERT INTO [TABELA DE TELEFONES] (Telefone, id_cliente)
SELECT '11990000001', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Serena van der Woodsen') UNION ALL
SELECT '11990000002', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Blair Waldorf') UNION ALL
SELECT '11990000003', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Dan Humphrey') UNION ALL
SELECT '11990000004', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Nate Archibald') UNION ALL
SELECT '11990000005', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Chuck Bass') UNION ALL
SELECT '11990000006', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Meredith Grey') UNION ALL
SELECT '11990000007', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Derek Shepherd') UNION ALL
SELECT '11990000008', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Cristina Yang') UNION ALL
SELECT '11990000009', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Alex Karev') UNION ALL
SELECT '11990000010', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Miranda Bailey');

-- Inserindo dados de agências (um teste) 
INSERT INTO [TABELA DE AGENCIAS] (NumeroAgencia,NomeAgencia) VALUES ('0001', 'Agência Matriz') , ('0002', 'Agência Filial');
INSERT INTO [TABELA DE AGENCIAS] (NumeroAgencia,NomeAgencia) VALUES ('0003', 'Agência Apoio');

-- Inserindo os tipos de moedas
INSERT INTO [TABELA DE MOEDAS] (CodigoMoeda, NomeMoeda) VALUES ('BRL', 'Moeda Brasileira'), ('USD', 'Dólar Americano');

-- Insert que vai criar a conta para cada um dos "clientes"
INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda) VALUES ('10001-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Serena van der Woodsen'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('10002-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Blair Waldorf'), (SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('10003-3', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Dan Humphrey'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('10004-4', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Nate Archibald'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('10005-5', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Chuck Bass'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL'));
 

INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda) VALUES ('20001-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Meredith Grey'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD')),
('20002-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Derek Shepherd'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD')),
('20003-3', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Cristina Yang'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0003'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD')),
('20004-4', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Alex Karev'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0003'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD')),
('20005-5', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Miranda Bailey'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD'));
 

INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda) VALUES ('30001-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Phoebe Buffay'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('30002-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Rachel Green'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('30003-3', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Monica Geller'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('30004-4', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Ross Geller'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD')),
('30005-5', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Chandler Bing'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0003'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('30006-6', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Joey Tribbiani'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0003'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='USD'));


--INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('DEPOSITO', 'CREDITO'),
--('SAQUE', 'SAQUE'),
--('PAGAMENTO', 'PAGAMENTO'),
--('TRANSFERENCIA', 'TRANSFERENCIA');

-- Descobrindo o erro do insert (um espaço na criação dos tipos de transações que se referia a débitos, estava travando os comandos acima
-- Ou seja, nenhum aceita a transferência, é necesário dropar e recriar de forma correta p/ funcionar.


-- Buscando as constraints de check da tabela 
SELECT cc.name,cc.definition
FROM sys.check_constraints cc
JOIN sys.tables t ON t.object_id = cc.parent_object_id
WHERE t.name = 'TABELA DE TIPOS DE TRANSACOES';

-- Excluindo os checks atuais 
ALTER TABLE [TABELA DE TIPOS DE TRANSACOES]
DROP CONSTRAINT CK_Tipos_Natureza;

-- Comando que o Chat me ensinou pq os anteriores não foram suficientes p/ resolver o @sql faz parte do T-SQL
DECLARE @sql NVARCHAR(MAX);
SELECT @sql = ' ALTER TABLE [TABELA DE TIPOS DE TRANSACOES] DROP CONSTRAINT' + QUOTENAME(name) 
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID ('TABELA DE TIPOS DE TRANSACOES');
PRINT @sql;-- Ver o comando
EXEC sp_executesql @sql; -- Dropar de fato

-- RECRIANDO E ALTERANDO A TABELA 
ALTER TABLE [TABELA DE TIPOS DE TRANSACOES]
ADD CONSTRAINT CK_Tipos_Natureza
CHECK (Natureza IN ('CREDITO', 'DEBITO'));

-- REPOPULANDO OS TIPOS C/ TRUNCATE (APAGA AS LINHAS MAS MANTÉM A ESTRUTURA DA TABELA) pegadinha do truncate kkkkry
TRUNCATE TABLE [TABELA DE TIPOS DE TRANSACOES];
INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('DEPOSITO','CREDITO'),
('SAQUE','DEBITO'),
('PAGAMENTO','DEBITO'),
('TRANSFERENCIA','CREDITO');

-- Ainda com todos os comandos acima, ainda está dando erro em registrar o processo de transferência
-- segunda indicação do chat 

-- Consertando o CHECK + comando para decidir se é feito update ou insert + conferência

-- 1) Apagar TODOS os CHECKs da tabela (independe do nome)
DECLARE @drop NVARCHAR(MAX) = N'';
SELECT @drop = STRING_AGG(
  'ALTER TABLE dbo.[TABELA DE TIPOS DE TRANSACOES] DROP CONSTRAINT ' + QUOTENAME(cc.name) + ';',
  CHAR(10)
)
FROM sys.check_constraints cc
JOIN sys.tables t ON t.object_id = cc.parent_object_id
WHERE t.name = 'TABELA DE TIPOS DE TRANSACOES';
 
IF @drop IS NOT NULL AND LEN(@drop) > 0
    EXEC sp_executesql @drop;
 
-- 2) Criar APENAS o CHECK certo
ALTER TABLE dbo.[TABELA DE TIPOS DE TRANSACOES]
ADD CONSTRAINT CK_Tipos_Natureza
CHECK (Natureza IN ('CREDITO','DEBITO'));
 
-- 3) Ajustar dados existentes (sem apagar nada, preserva FK/Transações)
UPDATE dbo.[TABELA DE TIPOS DE TRANSACOES]
SET Natureza = CASE
  WHEN LTRIM(RTRIM(NomeTipo)) IN ('DEPOSITO','TRANSFERENCIA') THEN 'CREDITO'
  WHEN LTRIM(RTRIM(NomeTipo)) IN ('SAQUE','PAGAMENTO')        THEN 'DEBITO'
  WHEN LTRIM(RTRIM(Natureza))  IN ('CREDITO','DEBITO')         THEN UPPER(LTRIM(RTRIM(Natureza)))
  WHEN LTRIM(RTRIM(Natureza))  IN ('TRANSFERENCIA','DEPOSITO') THEN 'CREDITO'
  WHEN LTRIM(RTRIM(Natureza))  IN ('SAQUE','PAGAMENTO')        THEN 'DEBITO'
  ELSE 'DEBITO'  
END;
 
-- Conferência rápida 
SELECT id_tipo_transacao, NomeTipo, Natureza
FROM dbo.[TABELA DE TIPOS DE TRANSACOES]
ORDER BY NomeTipo;

SELECT * FROM [TABELA DE TIPOS DE TRANSACOES];

INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('DEPOSITO', 'CREDITO');
INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('SAQUE', 'DEBITO');
INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('PAGAMENTO', 'DEBITO');
INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('TRANSFERENCIA', 'CREDITO');
INSERT INTO [TABELA DE TIPOS DE TRANSACOES] (NomeTipo, Natureza) VALUES ('TRANSFERENCIA 02', 'DEBITO');


-- Inserindo dados na tabela de transações, já ligando com a conta e qual tipo de transação está sendo feita
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30001-1'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        1500.00, 'Depósito inicial Phoebe');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30002-2'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        2000.00, 'Depósito inicial Rachel');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30003-3'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        1800.00, 'Depósito inicial Monica');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30004-4'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        2200.00, 'Depósito inicial Ross');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30005-5'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        1700.00, 'Depósito inicial Chandler');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='30006-6'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        1600.00, 'Depósito inicial Joey');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='20001-1'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        5000.00, 'Depósito inicial Meredith');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='20002-2'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        4500.00, 'Depósito inicial Derek');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='20003-3'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        3000.00, 'Depósito inicial Cristina');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='20004-4'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        2800.00, 'Depósito inicial Alex');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='20005-5'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        3500.00, 'Depósito inicial Miranda');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10001-1'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        6000.00, 'Depósito inicial Serena');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10002-2'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        5500.00, 'Depósito inicial Blair');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10003-3'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        3200.00, 'Depósito inicial Dan');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10004-4'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        2800.00, 'Depósito inicial Nate');
 
INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10005-5'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='DEPOSITO'),
        7000.00, 'Depósito inicial Chuck');

-- Outros tipos de transações + Uso dos JOINS (Inner, Left e Right)
-- Inner Join: A conta precisa existir igualmente nas tabelas - " Só entra na festa quem tem nome na lista."

-- Left Join: Trás os registros da esquerda e os da direita só se existirem - caso não eles vem como NULL
-- lista todos os clientes até quem não tem conta, o campo NumeroConta aparece Nulo
-- " Todo mundo da lista entra, mas quem não tiver ingresso entra com o lugar vazio NULL."

-- Right Join: Trás os registros da direita mesmo que não estejam ligados com o da esquerda, parece com o inner.
-- " Todas as pessoas com ingresso entram, mesmo que não estejam na lista."

-- Saque na conta da Rachel usando INNER
INSERT INTO [TABELA DE TRANSACOES] (id_conta, id_tipo_transacao, Valor, Descricao) VALUES 
    (( SELECT c.id_conta FROM [TABELA DE CONTAS] c INNER JOIN [TABELA DE CLIENTES] cli ON cli.id_cliente = c.id_cliente
        WHERE cli.Nome = 'Rachel Green'), (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES]
        WHERE NomeTipo = 'SAQUE'), 300.00, 'Primeiro Saque da Rachel');

-- Rachel transferindo para Monica, usando LEFT
INSERT INTO [TABELA DE TRANSACOES] (id_conta, id_tipo_transacao, Valor, Descricao) VALUES 
    (( SELECT c.id_conta FROM [TABELA DE CONTAS] c LEFT JOIN [TABELA DE CLIENTES] cli ON cli.id_cliente = c.id_cliente
        WHERE cli.Nome = 'Monica Geller'), (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES]
        WHERE NomeTipo = 'TRANSFERENCIA'), 100.00, 'Transferencia da Rachel para Monica');

-- Serena transferindo para a Blair, usando o RIGHT
INSERT INTO [TABELA DE TRANSACOES] (id_conta, id_tipo_transacao, Valor, Descricao) VALUES 
    (( SELECT c.id_conta FROM [TABELA DE CONTAS] c RIGHT JOIN [TABELA DE CLIENTES] cli ON cli.id_cliente = c.id_cliente
        WHERE cli.Nome = 'Blair Waldorf'), (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES]
        WHERE NomeTipo = 'TRANSFERENCIA'), 500.00, 'Transferencia da Serena para Blair');


-- Testes de integridade = Regras para manter os dados coerentes, são as constraints.
-- As que eu usei ao longo do código foram: 
-- PK: garante que cada registro seja único tipo o id_cliente
-- FK: garante que um valor de uma tabela tbm exista na tabela relacionada, ex: uma conta precisa ter um cliente
-- UNIQUE: garante que não tenha duplicidade em uma coluna, ex : um cpf tem que ser um dado com essa regra.
-- CHECK: garante que só os valores permitidos sejam aceitos, ex: as transações só podem ter a natureza crédito (entrada) e débito (saída)
-- Not Null: garante que o campo não fique vazio, ex: o nome do cliente, ou algum dado essencial.

--Testando 03 constraints: dois clientes com o mesmo ID, criar uma conta com ID cliente inexistente e CPF duplicado

-- ID existente 
INSERT INTO [TABELA DE CLIENTES] (id_cliente, Nome, CPF, DatadeNascimento)
VALUES (100, 'Calliope Torres', '12345678900', '1990-05-10');

--CPF duplicado
INSERT INTO [TABELA DE CLIENTES] (id_cliente, Nome, CPF, DatadeNascimento)
VALUES (100, 'Arizona Robins', '12345678900', '1990-05-12');

-- Com conta já existente 
INSERT INTO [TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda, Saldo)
VALUES ('99999-9', 9999, 1, 1, 2000.00);


-- Lógica : Usar funções agregadas para criar um "painel" por cliente, no caso, que mostre os dados do cliente, quanto ele tem em conta
-- os saldos, uma união das regras anteriores para ver se o empréstimo pode ser feito.
-- MAX: pega o maior valor de uma coluna - ex: o maior saldo 
-- MIN: pega o menor valor de uma coluna - ex: o menor saldo
-- COUNT: conta quantos registros existem - ex: o total de transações
-- SUM: soma todos os valores - ex: o saldo total de todos os clientes
-- AVG: calcula a média - ex: média dos saldos
-- WHEN: define um critério - ex: quando algo for ...
-- THEN: o que deve ser mostrado quando o critério do when for verdadeiro
-- ELSE: o que mostrar caso não atenda a nenhum critério 
-- CASE: abre a condição como se fosse um "SE" 

SELECT
    cli.Nome, -- 1 cliente / 1 linha
    MAX(tel.Telefone)                             AS Telefone,           -- pega 1 telefone e evita duplicidade
    MAX(ct.NumeroConta)                           AS NumeroConta,        -- pega 1 conta e evita duplicidade
    MAX(mo.CodigoMoeda)                           AS Moeda,              -- moeda associada a conta na hora do insert
    COUNT(tr.id_transacao)                        AS QtdeTransacoes,     -- puxa o total das transações - com base no que fiz no insert, no caso os de natureza crédito que é a entrada/saldo
    SUM(CASE tp.Natureza WHEN 'CREDITO' THEN tr.Valor ELSE 0 END) AS TotalCreditos,  -- SUM , soma apenas os créditos entradas
    SUM(CASE tp.Natureza WHEN 'DEBITO'  THEN tr.Valor ELSE 0 END) AS TotalDebitos,   -- SUM, soma apenas os débitos saídas 
    SUM(CASE tp.Natureza WHEN 'CREDITO' THEN tr.Valor ELSE -tr.Valor END) AS SaldoMovimentado, -- soma os créditos e subtrai os débitos 
    COUNT(emp.id_emprestimo)                      AS QtdeEmprestimos, -- soma quantos empréstimos a pessoa tem
    SUM(emp.Valor)                                AS TotalEmprestado     -- SUM , soma total dos valores dos empréstimos 
FROM [TABELA DE CLIENTES]               cli
LEFT JOIN [TABELA DE TELEFONES]        tel ON tel.id_cliente    = cli.id_cliente
LEFT JOIN [TABELA DE CONTAS]           ct  ON ct.id_cliente     = cli.id_cliente
LEFT JOIN [TABELA DE MOEDAS]           mo  ON mo.id_moeda       = ct.id_moeda
LEFT JOIN [TABELA DE TRANSACOES]       tr  ON tr.id_conta       = ct.id_conta
LEFT JOIN [TABELA DE TIPOS DE TRANSACOES] tp ON tp.id_tipo_transacao = tr.id_tipo_transacao
LEFT JOIN [TABELA DE EMPRESTIMOS]      emp ON emp.id_cliente    = cli.id_cliente
GROUP BY cli.Nome -- agrupa as informações por cliente
ORDER BY cli.Nome; -- ordena alfabeticamente

-- Lógica: listar os empréstimos por clientes usando as funções agregadas para trazer 1 telefone e 1 conta por cliente
-- EMPRESTIMOS POR CLIENTE (COUNT, SUM, AVG, MIN, MAX)
SELECT
    cli.Nome, -- pesquisa por cliente 
    MAX(tel.Telefone)   AS Telefone,
    MAX(ct.NumeroConta)  AS NumeroConta,
    COUNT(emp.id_emprestimo)  AS QtdeEmprestimos,     
    SUM(emp.Valor)  AS TotalEmprestado,   
    AVG(emp.Valor)   AS ValorMedio,         
    MIN(emp.Valor) AS MenorEmprestimo,    
    MAX(emp.Valor)   AS MaiorEmprestimo    
FROM [TABELA DE CLIENTES]          cli
LEFT JOIN [TABELA DE TELEFONES]    tel ON tel.id_cliente = cli.id_cliente
LEFT JOIN [TABELA DE CONTAS]       ct  ON ct.id_cliente  = cli.id_cliente
LEFT JOIN [TABELA DE EMPRESTIMOS]  emp ON emp.id_cliente = cli.id_cliente
GROUP BY cli.Nome
ORDER BY TotalEmprestado DESC; -- ordenado do maior para o menor, em ordem descendente 

-- Lógica : mostrar em painel, os totais de de débito, crédito e saldo líquido ( com base nos inserts anteriores)
-- e tirar a média do valor das transações realizadas via AVG
-- TRANSACOES POR CLIENTE (SUM, AVG)
SELECT
    cli.Nome,
    COUNT(tr.id_transacao) AS QtdeTransacoes,    -- somando a quantidade de transações
    SUM(CASE tp.Natureza WHEN 'CREDITO' THEN tr.Valor ELSE 0 END) AS TotalCreditos, -- usando o case para puxar o total por natureza, aqui é o de créditos
    SUM(CASE tp.Natureza WHEN 'DEBITO'  THEN tr.Valor ELSE 0 END) AS TotalDebitos,  -- usando o case para puxar o total por natureza, aqui é o de débitos
    SUM(CASE tp.Natureza WHEN 'CREDITO' THEN tr.Valor ELSE -tr.Valor END) AS SaldoLiquido, -- usando o case para puxar o total por natureza, nesse caso puxa o débito e crédito e subtrai para ter o saldo líquido
    AVG(tr.Valor) AS ValorMedioTransacao      -- média com base nos valores anteriores
FROM [TABELA DE CLIENTES]               cli
JOIN [TABELA DE CONTAS]                 ct  ON ct.id_cliente  = cli.id_cliente -- é necessário que ele tenha uma conta
LEFT JOIN [TABELA DE TRANSACOES]        tr  ON tr.id_conta    = ct.id_conta -- ele pode ter feito uma transação ou não 
LEFT JOIN [TABELA DE TIPOS DE TRANSACOES] tp ON tp.id_tipo_transacao = tr.id_tipo_transacao -- qual a natureza da transação se é entrada (crédito) ou (débito) saida
GROUP BY cli.Nome
ORDER BY cli.Nome;
 
 -- Lógica: Pega o cliente, o telefone e o produto (do banco) e devolve o valor, prazo, taxa anual e uma parcela simples (valor/prazo)
 -- SIMULACAO BASICA DE EMPRESTIMO (valor/prazo = parcela simples)
SELECT
    cli.Nome,
    MAX(tel.Telefone)          AS Telefone,
    emp.id_emprestimo, -- o tipo de contrato que deve ser único devido o ID do clientes
    prod.NomeProduto, -- o tipo do produto se é garantia, pessoal, consignado, garantia
    emp.Valor, -- atributo do contrato (determinado lá no insert de empréstimo)
    emp.PrazoMeses, -- atributo do contrato (determinado lá no insert de empréstimo)
    emp.TaxaAnual, -- atributo do contrato (determinado lá no insert de empréstimo)
    CAST(emp.Valor / NULLIF(emp.PrazoMeses,0) AS DECIMAL(15,2)) AS ParcelaSimples -- parcela simples
    -- divide o valor do empréstimo pelos meses, se o prazo for  o nullif não deixa e transforma em NULL 
    -- decimal em até duas casas
FROM [TABELA DE EMPRESTIMOS] emp
JOIN [TABELA DE CLIENTES]   cli ON cli.id_cliente = emp.id_cliente -- FK pois um empréstimo tem que pertencer a um cliente 
LEFT JOIN [TABELA DE TELEFONES] tel ON tel.id_cliente = cli.id_cliente
JOIN [TABELA DE PRODUTOS]   prod ON prod.id_produto = emp.id_produto
GROUP BY cli.Nome, emp.id_emprestimo, prod.NomeProduto, emp.Valor, emp.PrazoMeses, emp.TaxaAnual
ORDER BY cli.Nome, emp.id_emprestimo;


-- Lógica : Como se fosse um extrato 
-- TRANSACOES DETALHADAS (cliente + telefone + conta + moeda + tipo)
SELECT
    cli.Nome,
    tel.Telefone,
    ct.NumeroConta,
    md.CodigoMoeda AS Moeda,
    tp.NomeTipo    AS TipoTransacao,
    tp.Natureza,
    tr.Valor,
    tr.DataTransacao,
    tr.Descricao
FROM [TABELA DE TRANSACOES]        tr
JOIN [TABELA DE CONTAS]            ct  ON ct.id_conta = tr.id_conta
JOIN [TABELA DE CLIENTES]          cli ON cli.id_cliente = ct.id_cliente
LEFT JOIN [TABELA DE TELEFONES]    tel ON tel.id_cliente = cli.id_cliente
JOIN [TABELA DE TIPOS DE TRANSACOES] tp ON tp.id_tipo_transacao = tr.id_tipo_transacao
JOIN [TABELA DE MOEDAS]            md  ON md.id_moeda = ct.id_moeda
ORDER BY tr.DataTransacao DESC, cli.Nome;

INSERT INTO [TABELA DE CLIENTES] 
  (CPF, Nome, Email, DatadeNascimento, Rua, Bairro, Cidade, Estado, CEP) 
VALUES
('90100100101','Eleven','eleven@hawkins.com','2004-02-19','Maple Street, 101','Downtown','Hawkins','IN','46001'),
('90100100102','Mike Wheeler','mike@hawkins.com','2004-06-12','Oak Avenue, 45','Downtown','Hawkins','IN','46002'),
('90100100103','Dustin Henderson','dustin@hawkins.com','2004-09-08','Elm Street, 77','Suburb','Hawkins','IN','46003'),
('90100100104','Lucas Sinclair','lucas@hawkins.com','2004-08-10','Willow Road, 22','Suburb','Hawkins','IN','46004'),
('90100100105','Will Byers','will@hawkins.com','2004-03-22','Pine Street, 88','Downtown','Hawkins','IN','46005'),
('90100100106','Max Mayfield','max@hawkins.com','2004-05-10','Cedar Lane, 34','Suburb','Hawkins','IN','46006'),
('90100100107','Jim Hopper','hopper@hawkinspd.com','1976-01-15','Police St, 12','Central','Hawkins','IN','46007'),
('90100100108','Joyce Byers','joyce@hawkins.com','1975-10-28','Birch Ave, 66','Downtown','Hawkins','IN','46008'),
('90100100109','Nancy Wheeler','nancy@hawkins.com','2002-04-14','Rose Street, 5','Central','Hawkins','IN','46009'),
('90100100110','Jonathan Byers','jonathan@hawkins.com','2001-06-03','Ivy Street, 77','Central','Hawkins','IN','46010'),
('90100100111','Steve Harrington','steve@hawkins.com','2001-11-02','Hill Road, 32','Suburb','Hawkins','IN','46011'),
('90100100112','Robin Buckley','robin@hawkins.com','2002-03-09','Park Lane, 20','Downtown','Hawkins','IN','46012'),
('90100100113','Rebecca Pearson','rebecca@thisisus.com','1950-03-30','Pearson Street, 10','North Side','Pittsburgh','PA','15201'),
('90100100114','Jack Pearson','jack@thisisus.com','1947-10-18','Pearson Street, 12','North Side','Pittsburgh','PA','15201'),
('90100100115','Randall Pearson','randall@thisisus.com','1980-11-14','Randall Ave, 50','West Philly','Philadelphia','PA','19101'),
('90100100116','Kevin Pearson','kevin@thisisus.com','1980-11-14','Hollywood Blvd, 200','Hollywood','Los Angeles','CA','90028'),
('90100100117','Kate Pearson','kate@thisisus.com','1980-11-14','Ocean Drive, 30','Santa Monica','Los Angeles','CA','90401'),
('90100100118','Beth Pearson','beth@thisisus.com','1981-08-12','Market St, 22','West Philly','Philadelphia','PA','19102'),
('90100100119','Toby Damon','toby@thisisus.com','1979-09-20','Palm Street, 70','Santa Monica','Los Angeles','CA','90402'),
('90100100120','Miguel Rivas','miguel@thisisus.com','1969-02-02','Sunset Blvd, 15','Hollywood','Los Angeles','CA','90027'),
('90100100121','Deja Pearson','deja@thisisus.com','2005-07-05','Chestnut St, 33','West Philly','Philadelphia','PA','19103'),
('90100100122','Annie Pearson','annie@thisisus.com','2010-01-19','Spruce St, 40','West Philly','Philadelphia','PA','19104'),
('90100100123','Tess Pearson','tess@thisisus.com','2006-05-25','Pine St, 28','West Philly','Philadelphia','PA','19105'),
('90100100124','Nicky Pearson','nicky@thisisus.com','1948-07-01','Veterans Rd, 55','Bethlehem','Philadelphia','PA','19106'),
('90100100125','Percy Jackson','percy@camp.com','2003-08-18','Half-Blood Hill, 1','Camp','Long Island','NY','10001'),
('90100100126','Annabeth Chase','annabeth@camp.com','2003-07-12','Cabin 6, Hill','Camp','Long Island','NY','10002'),
('90100100127','Grover Underwood','grover@camp.com','2000-04-15','Forest Cabin, 2','Camp','Long Island','NY','10003'),
('90100100128','Chiron','chiron@camp.com','1970-01-01','Big House, 1','Camp','Long Island','NY','10004'),
('90100100129','Luke Castellan','luke@camp.com','2001-05-10','Cabin 11, Hill','Camp','Long Island','NY','10005'),
('90100100130','Thalia Grace','thalia@camp.com','2001-12-22','Cabin 1, Hill','Camp','Long Island','NY','10006'),
('90100100131','Nico di Angelo','nico@camp.com','2004-01-28','Cabin 13, Hill','Camp','Long Island','NY','10007'),
('90100100132','Bianca di Angelo','bianca@camp.com','2001-10-10','Cabin 13, Hill','Camp','Long Island','NY','10008'),
('90100100133','Clarisse La Rue','clarisse@camp.com','2002-09-09','Cabin 5, Hill','Camp','Long Island','NY','10009'),
('90100100134','Sally Jackson','sally@camp.com','1975-03-03','Queens Blvd, 45','Astoria','New York','NY','11101'),
('90100100135','Tyson','tyson@camp.com','2000-06-06','Dockside, 9','Port','New York','NY','11102'),
('90100100136','Rachel Dare','rachel@camp.com','2003-02-27','Arts Ave, 7','Manhattan','New York','NY','11103'),
('90100100137','Tony Stark','tony@starkindustries.com','1970-05-29','Malibu Point, 10880','Malibu','Los Angeles','CA','90265'),
('90100100138','Steve Rogers','steve@avengers.com','1918-07-04','Brooklyn St, 1940','Brooklyn','New York','NY','11201'),
('90100100139','Natasha Romanoff','natasha@shield.com','1984-11-22','Red Room Lane, 13','Secret','Moscow','RU','101000'),
('90100100140','Bruce Banner','bruce@avengers.com','1969-12-18','Culver St, 88','Harlem','New York','NY','11202'),
('90100100141','Thor Odinson','thor@asgard.com','1976-01-01','Royal Palace, 1','Asgard','Realm','AS','000001'),
('90100100142','Clint Barton','clint@shield.com','1971-01-07','Farm Road, 5','Countryside','Iowa','IA','50001'),
('90100100143','Wanda Maximoff','wanda@avengers.com','1989-02-10','Sokovia St, 8','Center','Sokovia','SK','70001'),
('90100100144','Vision','vision@avengers.com','2015-08-12','Lab St, 42','Avengers HQ','New York','NY','11203'),
('90100100145','Peter Parker','peter@avengers.com','2001-08-10','Queens Ave, 20','Queens','New York','NY','11368'),
('90100100146','Stephen Strange','strange@sanctum.com','1976-11-18','177A Bleecker Street','Greenwich','New York','NY','10012'),
('90100100147','T’Challa','tchalla@wakanda.com','1977-11-29','Royal Palace, 1','Capital','Wakanda','WK','60001'),
('90100100148','Scott Lang','scott@avengers.com','1969-04-06','San Francisco St, 15','Downtown','San Francisco','CA','94101'),
('90100100149','Hope van Dyne','hope@avengers.com','1980-10-02','San Francisco St, 18','Downtown','San Francisco','CA','94102'),
('90100100150','Carol Danvers','carol@avengers.com','1968-10-24','Airbase Road, 7','Military','Los Angeles','CA','90001');
 

SELECT * FROM [TABELA DE CLIENTES];

SELECT * FROM [TABELA DE CONTAS];

-- Massa de dados para a tabela de contas
INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda) VALUES ('90001-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Eleven'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90002-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Mike Wheeler'), (SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90003-3', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Dustin Henderson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90004-4', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Lucas Sinclair'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90005-5', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Will Byers'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90006-6', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Max Mayfield'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90007-7', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Jim Hopper'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90008-8', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Joyce Byers'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90009-9', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Nancy Wheeler'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90010-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Jonathan Byers'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90011-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Steve Harrington'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90012-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Robin Buckley'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0001'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL'));
 

 INSERT INTO dbo.[TABELA DE CONTAS] (NumeroConta, id_cliente, id_agencia, id_moeda) VALUES ('90013-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Rebecca Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90014-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Jack Pearson'), (SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90015-3', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Randall Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90016-4', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Kevin Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90017-5', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Kate Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90018-6', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Beth Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90019-7', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Toby Damon'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90020-8', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Miguel Rivas'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90021-9', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Deja Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90022-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Annie Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90023-1', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Tess Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL')),
('90024-2', (SELECT id_cliente FROM dbo.[TABELA DE CLIENTES] WHERE Nome='Nicky Pearson'),(SELECT id_agencia FROM dbo.[TABELA DE AGENCIAS] WHERE NumeroAgencia='0002'),(SELECT id_moeda   FROM dbo.[TABELA DE MOEDAS]  WHERE CodigoMoeda='BRL'));

SELECT * FROM [TABELA DE CONTAS]

-- Colocar a parte de views, procedures e triggers

-- SubQUery
SELECT Estado,
COUNT (*) AS TotalClientes
FROM [TABELA DE CLIENTES]
GROUP BY Estado

SELECT * FROM [TABELA DE TRANSACOES] ORDER BY Valor;

-- Montando uma base para as triggers
CREATE TABLE [TABELA TOTAL DE TRANSACOES]
(DataTransacao DATE NULL,
TotalTransacao FLOAT);

-- Consulta que irá integrar a trigger/gatilho 
SELECT
TDT.DataTransacao,
TTT.NomeTipo, 
SUM(TDT.Valor) AS TotalTransacao
FROM [TABELA DE TRANSACOES] AS TDT
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS TTT 
ON TTT.id_tipo_transacao = TDT.id_tipo_transacao
GROUP BY TDT.DataTransacao, TTT.NomeTipo;

SELECT * FROM [TABELA DE CLIENTES]
SELECT * FROM [TABELA DE TRANSACOES]

ALTER TABLE [TABELA TOTAL DE TRANSACOES] -- inserindo um campo que seria necessário p/ base da trigger
ADD NomeTipo VARCHAR(50) NOT NULL;

INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10005-5'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='TRANSFERENCIA'),
        2000.00, 'Transferência de Chuck para Blair');

INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10002-2'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='TRANSFERENCIA'),
        2000.00, 'Saque da transferência do Chuck');

SELECT * FROM [TABELA TOTAL DE TRANSACOES]
SELECT * FROM [TABELA DE CONTAS]

SELECT * FROM [TABELA TOTAL DE TRANSACOES] ORDER BY DataTransacao;

INSERT INTO [TABELA DE TRANSACOES] (id_conta,id_tipo_transacao,Valor,Descricao, DataTransacao)
VALUES ((SELECT id_conta FROM [TABELA DE CONTAS] WHERE NumeroConta='10003-3'),
        (SELECT id_tipo_transacao FROM [TABELA DE TIPOS DE TRANSACOES] WHERE NomeTipo='SAQUE'),
        2000.00, 'Saque do Dan', CAST(GETDATE() AS date));

DELETE FROM [TABELA TOTAL DE TRANSACOES]; -- Está relacionado a uma parte importante do gatilho, ele apaga as informações e recalcula a partir do insert abaixo

INSERT INTO [TABELA TOTAL DE TRANSACOES] ( DataTransacao, NomeTipo, TotalTransacao)
SELECT
    CAST(t.DataTransacao AS date) -- conversão p/ data 
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

SELECT * FROM [TABELA TOTAL DE TRANSACOES] ORDER BY DataTransacao;

-- Usando check para regra de idade, só pode ter empréstimo quem for tiver 18 anos ou mais 
CREATE TABLE TAB_CHECK
(ID INT NOT NULL, 
NOME VARCHAR (50) NULL,
IDADE INT NULL,
CIDADE VARCHAR(50) NULL,
CONSTRAINT CHK_IDADE CHECK (IDADE >=18));


-- View 01
CREATE VIEW MEDIA_CLIENTES
AS
SELECT Estado,
COUNT (*) AS TotalClientes
FROM [TABELA DE CLIENTES]
GROUP BY Estado

SELECT * FROM [MEDIA_CLIENTES]

-- Acessar de uma base na outra em determinada tabela 
SELECT * FROM DESAFIOESTAGIO_BANCO.dbo.[TABELA DE TELEFONES];

-- View 02
CREATE VIEW MEDIA_TIPO_DE_TRANSACOES
AS 
SELECT TTT.NomeTipo AS TipoTransacao, 
COUNT (*) AS Quantidade,
SUM (TDT.Valor) AS ValorTotal
FROM [TABELA DE TRANSACOES]AS TDT
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS TTT
ON TDT.id_tipo_transacao = TTT.id_tipo_transacao
GROUP BY TTT.NomeTipo;

SELECT * FROM [MEDIA_TIPO_DE_TRANSACOES];

-- View 03
CREATE VIEW SALDO_POR_CONTA
AS
SELECT
	C.NumeroConta,
	SUM(CASE
			WHEN TT.Natureza = 'CREDITO' THEN T.Valor
			WHEN TT.Natureza = 'DEBITO' THEN T.Valor
			ELSE 0 
			END) AS SaldoAtual
FROM [TABELA DE TRANSACOES] AS T
INNER JOIN [TABELA DE TIPOS DE TRANSACOES] AS TT
ON T.id_tipo_transacao = TT.id_tipo_transacao
INNER JOIN [TABELA DE CONTAS] AS C
ON C.id_conta = T.id_conta
GROUP BY C.NumeroConta;

SELECT * FROM [SALDO_POR_CONTA];


--View 04
CREATE VIEW NOME_DO_CLIENTE_E_SALDO
AS
SELECT
    c.id_cliente,
    cli.Nome AS NomeCliente,
    SUM(CASE 
            WHEN tt.Natureza = 'CREDITO' THEN t.Valor
            WHEN tt.Natureza = 'DEBITO'  THEN -t.Valor
            ELSE 0
        END) AS SaldoAtual
FROM dbo.[TABELA DE TRANSACOES] AS t
INNER JOIN dbo.[TABELA DE TIPOS DE TRANSACOES]   AS tt
  ON tt.id_tipo_transacao = t.id_tipo_transacao
INNER JOIN dbo.[TABELA DE CONTAS]  AS c
  ON c.id_conta = t.id_conta
 INNER JOIN dbo.[TABELA DE CLIENTES]  AS cli
  ON cli.id_cliente = c.id_cliente
GROUP BY c.id_cliente,cli.Nome;
 
SELECT * FROM NOME_DO_CLIENTE_E_SALDO ORDER BY NomeCliente;

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
