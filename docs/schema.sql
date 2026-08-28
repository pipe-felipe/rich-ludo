-- ============================================
-- Rich Ludo Database Schema
-- SQLite Database Documentation
-- Version: 3
-- Last Updated: 2026-02-17
-- ============================================

-- ============================================
-- TABLE: transactions
-- Stores every financial transaction
-- ============================================
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Amount in cents (e.g. $10.50 = 1050)
    amountCents INTEGER NOT NULL,

    -- Transaction type: 'income' or 'expense'
    type TEXT NOT NULL,

    -- Transaction category (e.g. 'food', 'transport')
    category TEXT,

    -- Free-form transaction description
    description TEXT,

    -- Date formatted for human display
    humanDate TEXT,

    -- 1 = recurring transaction, 0 = one-off transaction
    isRecurring INTEGER NOT NULL DEFAULT 0,

    -- Creation timestamp (milliseconds since epoch)
    createdAt INTEGER NOT NULL DEFAULT 0,

    -- Target month of the transaction (1-12)
    targetMonth INTEGER NOT NULL DEFAULT 0,

    -- Target year of the transaction (e.g. 2026)
    targetYear INTEGER NOT NULL DEFAULT 0,

    -- Final month for recurring transactions (NULL = no end)
    endMonth INTEGER,

    -- Final year for recurring transactions (NULL = no end)
    endYear INTEGER
);

-- ============================================
-- TABLE: recurring_exclusions
-- Stores exclusions of recurring transactions
-- in specific months.
--
-- Example: If a recurring "Rent" transaction
-- should not appear in March/2026, a record is created:
-- (transactionId=5, month=3, year=2026)
-- ============================================
CREATE TABLE recurring_exclusions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- ID of the recurring transaction
    transactionId INTEGER NOT NULL,

    -- Month of the exclusion (1-12)
    month INTEGER NOT NULL,

    -- Year of the exclusion (e.g. 2026)
    year INTEGER NOT NULL,

    -- Foreign key with cascading deletion
    FOREIGN KEY (transactionId)
        REFERENCES transactions (id)
        ON DELETE CASCADE
);

-- ============================================
-- TABLE: categories
-- Stores only the categories created by the user.
-- The 13 built-in categories remain Dart enums
-- and are never rows of this table.
--
-- Example: a category named "Mercado" is stored as
-- (slug='custom_mercado', name='Mercado', type='expense')
-- and transactions.category holds 'custom_mercado'.
-- ============================================
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,

    -- Value written to transactions.category, always prefixed 'custom_'
    slug TEXT NOT NULL,

    -- Display name typed by the user (up to 30 characters)
    name TEXT NOT NULL,

    -- Category type: 'income' or 'expense'
    type TEXT NOT NULL,

    -- Code point of an entry of customCategoryIcons
    iconCodePoint INTEGER NOT NULL,

    -- ARGB value of an entry of CategoryPiColors.customPalette
    colorValue INTEGER NOT NULL,

    -- Creation timestamp (milliseconds since epoch)
    createdAt INTEGER NOT NULL DEFAULT 0,

    -- One name per type; the same name may exist for both types
    UNIQUE (slug, type)
);

-- ============================================
-- NOTE ON FOREIGN KEYS IN SQLITE
-- ============================================
-- By default, SQLite does NOT enforce Foreign Key
-- constraints. To enable them, run:
--
-- PRAGMA foreign_keys = ON;
--
-- In the Dart/Flutter code, this must be done
-- when opening the database connection.
-- ============================================

-- ============================================
-- MIGRATION HISTORY
-- ============================================
-- Version 1: Initial schema (transactions)
-- Version 2: Added endMonth, endYear and the recurring_exclusions table
-- Version 3: Added the categories table for user-created categories
-- ============================================
