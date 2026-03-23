
SELECT * FROM [TABELA DE TRANSACOES]
-- 00:00:33 (tempo de consulta) - custo: 15,4628

-- Índices padrão alura Não Clusterizado

CREATE NONCLUSTERED INDEX IX_CLIENTES_NOME_CPF ON [TABELA DE CLIENTES] (Nome, CPF) -- Acelera a consulta através do nome e cpf 
INCLUDE (Email, Cidade, Estado);

CREATE NONCLUSTERED INDEX IX_TRANSACOES_CONTA ON [TABELA DE TRANSACOES] (id_conta) -- Acelera a consulta através do id da conta
INCLUDE (Valor, DataTransacao, Descricao);

-- * Perguntar pro Robson o que muda de fato eu ter as PK's declaradas antes da criação dos índices em relação a fazer depois. 

EXPLAIN SELECT nome FROM funcionarios WHERE departamento = 'Vendas';

EXPLAIN SELECT Nome FROM [TABELA DE CLIENTES] WHERE Estado = 'MG'; 



-- Fluxo para entender e criar o índice. 
-- Exemplo abaixo: Quero buscar o nome dos clientes que estão na cidade 9 

SELECT * FROM [TABELA DE CLIENTES]

SET STATISTICS IO ON;
GO
-- Consulta antes do índice  -- Tempo 00:00:05 | Custo 0,0265192
SELECT Nome FROM [TABELA DE CLIENTES] WHERE Cidade = 'Cidade 9';

-- Crie o índice aqui
CREATE INDEX idx_nome_cidade ON [TABELA DE CLIENTES] (Cidade);

-- Execute a mesma consulta novamente -- 00:00:05 | Custo  4,82797
SELECT Nome FROM [TABELA DE CLIENTES] WHERE Cidade = 'Cidade 9';
GO
SET STATISTICS IO OFF;

/*Index Seek: É o ideal. 
Significa que o banco de dados usou o índice para encontrar dados de forma rápida e precisa, sem percorrer toda a tabela.*/


-- 01 índice novo

SELECT * FROM [TABELA DE EMPRESTIMOS]
-- Consulta antes do índice  -- Tempo 00:00:27 | Custo 11,8446%
SELECT id_produto,Status FROM [TABELA DE EMPRESTIMOS] WHERE Status = 'APROVADO';

CREATE NONCLUSTERED INDEX
ix_emprestimo_produto_status
ON [TABELA DE EMPRESTIMOS] (id_produto, Status)
INCLUDE (Valor,PrazoMeses,TaxaAnual);

-- Consulta depois do índice -- Tempo 00:00:26 | Custo: 10,5109%
SELECT id_produto,Status FROM [TABELA DE EMPRESTIMOS] WHERE Status = 'APROVADO';



