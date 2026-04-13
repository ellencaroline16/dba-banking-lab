-- Isso vai gerar um evento na fita da câmera
USE Financiamento_PROD;
GO
SELECT TOP 1 * FROM Financeiro.Transacoes;
GO