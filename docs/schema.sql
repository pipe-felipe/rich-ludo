-- ============================================
-- Rich Ludo Database Schema
-- SQLite Database Documentation
-- Version: 2
-- Last Updated: 2026-02-17
-- ============================================

-- ============================================
-- TABELA: transactions
-- Armazena todas as transações financeiras
-- ============================================
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Valor em centavos (ex: R$ 10,50 = 1050)
    amountCents INTEGER NOT NULL,

    -- Tipo da transação: 'income' ou 'expense'
    type TEXT NOT NULL,

    -- Categoria da transação (ex: 'alimentação', 'transporte')
    category TEXT,

    -- Descrição livre da transação
    description TEXT,

    -- Data formatada para exibição humana
    humanDate TEXT,

    -- 1 = transação recorrente, 0 = transação única
    isRecurring INTEGER NOT NULL DEFAULT 0,

    -- Timestamp de criação (milliseconds since epoch)
    createdAt INTEGER NOT NULL DEFAULT 0,

    -- Mês alvo da transação (1-12)
    targetMonth INTEGER NOT NULL DEFAULT 0,

    -- Ano alvo da transação (ex: 2026)
    targetYear INTEGER NOT NULL DEFAULT 0,

    -- Mês final para transações recorrentes (NULL = sem fim)
    endMonth INTEGER,

    -- Ano final para transações recorrentes (NULL = sem fim)
    endYear INTEGER
);

-- ============================================
-- TABELA: recurring_exclusions
-- Armazena exclusões de transações recorrentes
-- em meses específicos.
--
-- Exemplo: Se uma transação recorrente de "Aluguel"
-- não deve aparecer em Março/2026, cria-se um registro:
-- (transactionId=5, month=3, year=2026)
-- ============================================
CREATE TABLE recurring_exclusions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- ID da transação recorrente
    transactionId INTEGER NOT NULL,

    -- Mês da exclusão (1-12)
    month INTEGER NOT NULL,

    -- Ano da exclusão (ex: 2026)
    year INTEGER NOT NULL,

    -- Chave estrangeira com deleção em cascata
    FOREIGN KEY (transactionId)
        REFERENCES transactions (id)
        ON DELETE CASCADE
);

-- ============================================
-- NOTA SOBRE FOREIGN KEYS NO SQLITE
-- ============================================
-- Por padrão, o SQLite NÃO executa constraints de
-- Foreign Key. Para habilitar, execute:
--
-- PRAGMA foreign_keys = ON;
--
-- No código Dart/Flutter, isso deve ser feito
-- ao abrir a conexão com o banco.
-- ============================================

-- ============================================
-- HISTÓRICO DE MIGRATIONS
-- ============================================
-- Versão 1: Schema inicial (transactions)
-- Versão 2: Adicionado endMonth, endYear e tabela recurring_exclusions
-- ============================================

