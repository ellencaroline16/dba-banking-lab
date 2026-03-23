# 🏦 dba-banking-lab

> Modelagem e administração de banco de dados bancário real com SQL Server — Parte 1 de um projeto de formação DBA.

---

## 📌 Sobre o Projeto

Este repositório documenta a **Parte 1** de um projeto prático de estágio em DBA, onde construí do zero um banco de dados com modelo relacional bancário completo no SQL Server, aplicando técnicas reais de administração, tuning de performance e automação.

O objetivo foi simular o ambiente de dados de uma instituição financeira, cobrindo desde a modelagem até práticas avançadas de DBA como índices, stored procedures, triggers e carga massiva de dados para testes de stress.

---

## 🗂️ Estrutura do Banco de Dados

O modelo é composto pelas seguintes tabelas principais:

| Tabela | Descrição |
|---|---|
| `TABELA DE CLIENTES` | Dados cadastrais dos correntistas |
| `TABELA DE CONTAS` | Contas bancárias vinculadas a clientes e agências |
| `TABELA DE AGENCIAS` | Agências da instituição |
| `TABELA DE TELEFONES` | Telefones dos clientes (1:N) |
| `TABELA DE TRANSACOES` | Movimentações financeiras (crédito/débito) |
| `TABELA DE TIPOS DE TRANSACOES` | Catálogo de tipos: DEPOSITO, SAQUE, TED, etc. |
| `TABELA DE EMPRESTIMOS` | Contratos de crédito (PESSOAL, CONSIGNADO, GARANTIA) |
| `TABELA DE PRODUTOS` | Produtos de crédito disponíveis |
| `TABELA DE MOEDAS` | Moedas suportadas (BRL, etc.) |
| `TABELA TOTAL DE TRANSACOES` | Consolidado diário de transações (atualizado por trigger) |
| `TABELA DE SALDO POR CONTA` | Saldo consolidado por conta (atualizado por trigger) |

---

## ⚙️ Funcionalidades Implementadas

###  Índices de Performance
- Índice **não-clusterizado** em `CLIENTES` por `(Nome, CPF)` com INCLUDE de colunas de cobertura
- Índice **não-clusterizado** em `TRANSACOES` por `id_conta` com INCLUDE de valor e data
- Índice **não-clusterizado** em `EMPRESTIMOS` por `(id_produto, Status)` com INCLUDE
- Análise de planos de execução com `SET STATISTICS IO, TIME ON` — **redução de custo de 48 para ~4 em queries críticas**

### Stored Procedures
- **`ListarEmprestimosVencidos`** — Lista todos os empréstimos não liquidados ordenados por dias restantes, com data prevista de fim calculada dinamicamente
- **`ResumoClienteFinanceiro`** — Retorna o perfil financeiro completo do cliente: qtde de contas, empréstimos, total emprestado e saldo movimentado

###  Triggers Automáticas
- **`TG_TRANSACOES_FEITAS`** — Reconsolida a tabela de total diário de transações a cada INSERT, UPDATE ou DELETE em `TABELA DE TRANSACOES`
- **`TG_SALDOPOR_CONTA`** — Mantém o saldo por conta sempre atualizado de forma automática e consistente

###  Carga Massiva para Stress Test
- Script com CTE recursiva para inserção em massa de clientes, telefones, contas, empréstimos e transações
- Geração de dados realistas: CPF sequencial único, e-mail, endereço, data de nascimento entre 18 e 65 anos, estados brasileiros (SP, RJ, MG, BA, PR)
- Projetado para testar comportamento do banco sob alta volumetria

---

## Resultados de Performance (antes x depois dos índices)

| Consulta | Antes | Depois |
|---|---|---|
| `SELECT * FROM CLIENTES` | 1min 19s / Custo 48,23 | — |
| `SELECT Nome WHERE Cidade` | 5s / Custo 0,026 | 5s / Custo 4,82 (Index Seek ✅) |
| `SELECT * FROM TELEFONES` | 51s / Custo 16,31 | — |
| `SELECT Status FROM EMPRESTIMOS` | 27s / Custo 11,84 | 26s / Custo 10,51 |

>  **Index Seek** confirmado nos planos de execução após criação dos índices.

---

## Como usar

```sql
-- 1. Execute o script principal para criar as tabelas e estruturas
-- Arquivo: CÓDIGO - INTEIRO ATÉ TRIGGERS.sql

-- 2. Popule o banco com dados de teste
-- Arquivo: SET NOCOUNT ON - Populando muito o banco.sql

-- 3. Crie os índices de performance
-- Arquivo: Índices.sql

-- 4. Crie as Stored Procedures
-- Arquivo: Procedures.sql

-- 5. Crie as Triggers
-- Arquivo: Triggers.sql

-- 6. Teste as procedures
EXEC ListarEmprestimosVencidos;
EXEC ResumoClienteFinanceiro @id_cliente = 1;
```

---

##  Tecnologias

- **SQL Server** (T-SQL)
- **SSMS** — SQL Server Management Studio
- Conceitos aplicados: modelagem relacional, RBAC, índices B-Tree, covering indexes, stored procedures, triggers AFTER, CTEs, stress testing

---

## Contexto

Este projeto faz parte de um **Plano de Formação DBA de 3 meses** (SQL Server), desenvolvido durante estágio na área de banco de dados.

**Parte 1 (este repositório):** Governança, Performance e Automação — Semanas 1 a 12
**Parte 2 (em breve):** Alta Disponibilidade, Disaster Recovery e MongoDB Atlas — Semanas 13 a 20

---

## 👩‍💻 Autora

Desenvolvido por **Ellen** — Estagiária de DBA em formação 🚀

---

*"O banco de dados não mente. O dado fala mais alto que qualquer dashboard."*
