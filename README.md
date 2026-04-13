# 🏦 dba-banking-lab — Parte 2

> Segurança bancária real, disaster recovery com Point-in-Time e higienização de ambiente de produção — Parte 2 do projeto de formação DBA.

---

## 📌 Sobre esta Branch

Esta branch cobre o que o DBA enfrenta no dia a dia de produção: **quem pode ver o quê, como garantir que os dados não sumam, como monitorar o servidor em tempo real e como deixar o banco limpo e auditável.**

Todos os scripts foram executados e validados em ambiente real com SQL Server 17.0.1105.2, banco `Financiamento_PROD`.

---

## ⚙️ O que foi implementado

**🔐 Segurança e Controle de Acesso**
Logins e Users segmentados por perfil (Dev, BI, App, Suporte), 4 Roles customizadas com princípio do menor privilégio, DENY cirúrgico em nível de coluna para conformidade com LGPD, simulação e remapeamento de usuário órfão, testes de fogo com `EXECUTE AS USER`.

**🎭 Dynamic Data Masking (DDM)**
CPF mascarado com `partial()` e Email com `email()`. O dado no disco permanece íntegro — a máscara é aplicada apenas na saída. Teste de burla via `CAST` confirmado como resistente.

**💾 Cadeia de Backup Completa**
Full semanal, Differential diário e Transaction Log a cada 15 min. Validação com `RESTORE VERIFYONLY` + `DBCC CHECKDB`.

**🔍 SQL Server Audit**
Server Audit gravando em `C:\Auditoria\`, Database Audit Specification monitorando SELECT nos schemas Financeiro e Cadastros, com filtro de predicado para excluir processos automatizados.

**⚡ Performance e Índices**
Covering Index em Email com INCLUDE: **de 60.212 para 3 Logical Reads**. Análise de SARGability com `SET STATISTICS IO ON`. DMV `sys.dm_exec_query_stats` para identificar Top 5 queries mais custosas por I/O.

**🤖 Automação**
Job `Manutencao_Semanal` com 2 steps (UPDATE STATISTICS → BACKUP FULL), agendado aos domingos às 02h. Database Mail configurado via `smtp.office365.com` porta 587.

**📊 Monitoramento**
Schema `Monitoramento` + View `vw_Dashboard_Waits`. Simulação de blocking com `TABLOCKX`. Monitoramento de I/O Stalls por arquivo. Faxina do servidor com purge de 30 dias de histórico.

**🚨 Disaster Recovery — Point-in-Time Restore**
Cenário real: `DELETE FROM Cadastros.Clientes` sem WHERE — 60.000 clientes apagados. Recuperação via Tail-Log Backup + `STOPAT` com timestamp exato. **60.000 clientes recuperados com sucesso ✅**

**🧹 Higienização do Banco**
Mapeamento de FKs em cascata, migração de dados para tabelas com nomenclatura correta e DROP de todas as tabelas legadas (`TABELA DE CLIENTES`, `TABELA DE AGENCIAS`, etc.).

---

## 📈 Resultados

| Cenário | Antes | Depois |
|---|---|---|
| Busca por Email sem índice | 60.212 Logical Reads | 3 Logical Reads ✅ |
| DELETE sem WHERE — 60k clientes | Banco zerado | Recuperados via Point-in-Time ✅ |
| Latência de I/O | Sem visibilidade | Dashboard em tempo real ✅ |

---

## 🛠️ Tecnologias

**SQL Server 17.0.1105.2** · **SSMS 22** · T-SQL

Conceitos: RBAC · DDM · SQL Audit · Point-in-Time Recovery · Tail-Log · Covering Indexes · SARGability · DMVs · SQL Agent · Database Mail · I/O Stalls

---

## Contexto

**Parte 1 (branch main):** Modelagem, índices, stored procedures, triggers e carga massiva

**Parte 2 (esta branch):** Governança, segurança, disaster recovery, performance e automação

---

## 👩‍💻 Autora

Desenvolvido por **Ellen Caroline** — Estagiária de DBA em formação 🚀

---

*"Backup não é paranoia. É responsabilidade. O Point-in-Time Restore prova isso."*
