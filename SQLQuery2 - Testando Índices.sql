SELECT * FROM [TABELA DE AGENCIAS]

SET STATISTICS IO, TIME ON;
SELECT * FROM [TABELA DE CLIENTES] -- 00:01:19 (TEMPO DE CONSULTA) - CUSTO 48,2332

SELECT * FROM [TABELA DE CONTAS] -- Verificar pq o saldo está zerado de todas as contas 

SELECT * FROM [TABELA DE EMPRESTIMOS] -- Possível melhoria no tempo 

SELECT * FROM [TABELA DE MOEDAS]

SELECT * FROM [TABELA DE PRODUTOS]

SELECT * FROM [TABELA DE TELEFONES] -- Possível melhoria no tempo 00:00:51 - CUSTO 16,3153

SELECT * FROM [TABELA DE TIPOS DE TRANSACOES]

SELECT * FROM [TABELA DE TRANSACOES]

-- Índices padrão alura Não Clusterizado

CREATE NONCLUSTERED INDEX IX_CLIENTES_NOME_CPF ON [TABELA DE CLIENTES] (Nome, CPF) -- Acelera a consulta através do nome e cpf 
INCLUDE (Email, Cidade, Estado);

CREATE NONCLUSTERED INDEX IX_TRANSACOES_CONTA ON [TABELA DE TRANSACOES] (id_conta) -- Acelera a consulta através do id da conta
INCLUDE (Valor, DataTransacao, Descricao);

-- Índice clusterizado
--CREATE CLUSTERED INDEX IX_CLIENTES_CPF ON [TABELA DE CLIENTES] (CPF); 
-- Não irá funcionar pelo fato de que a tabela já tem uma pk e não posso usar outra ainda que com o índice. 

-- * Perguntar pro Robson o que muda de fato eu ter as PK's declaradas antes da criação dos índices em relação a fazer depois. 