-- ============================================
-- Rich Ludo - Seed Data (Test Data)
-- From January/2024 to March/2026
-- Includes one-off and recurring transactions
-- ============================================

-- Clear existing data
DELETE FROM recurring_exclusions;
DELETE FROM transactions;

-- ============================================
-- RECURRING TRANSACTIONS (appear every month)
-- ============================================

-- Monthly salary: R$ 5,500.00 (since Jan/2024, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', 'Salary', '05/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Rent: R$ 1,200.00 (since Jan/2024, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (120000, 'expense', 'recurring', 'Apartment rent', '10/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Internet: R$ 119.90 (since Jan/2024, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (11990, 'expense', 'recurring', '300MB fiber internet', '15/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Phone: R$ 59.90 (since Mar/2024, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (5990, 'expense', 'recurring', 'Phone plan', '20/03/2024', 1, 1709251200000, 3, 2024, NULL, NULL);

-- Gym: R$ 89.90 (since Jan/2024, ended Dec/2024)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8990, 'expense', 'care', 'Smart Fit gym', '01/01/2024', 1, 1704067200000, 1, 2024, 12, 2024);

-- Streaming: R$ 55.90 (since Jun/2024, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (5590, 'expense', 'recurring', 'Netflix + Spotify', '01/06/2024', 1, 1717200000000, 6, 2024, NULL, NULL);

-- Extra freelance work: R$ 1,500.00 (since Sep/2024, ended Feb/2025)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'income', 'other', 'Mobile dev freelance', '10/09/2024', 1, 1725148800000, 9, 2024, 2, 2025);

-- Car insurance: R$ 210.00 (since Jan/2025, no end)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (21000, 'expense', 'recurring', 'Car insurance installment', '05/01/2025', 1, 1735689600000, 1, 2025, NULL, NULL);

-- ============================================
-- ONE-OFF TRANSACTIONS - 2024
-- ============================================

-- January 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (4500, 'expense', 'food', 'Restaurant lunch', '12/01/2024', 0, 1704067200000, 1, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (15000, 'expense', 'transport', 'Uber during the week', '20/01/2024', 0, 1704067200000, 1, 2024, NULL, NULL);

-- February 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8900, 'expense', 'food', 'Groceries', '05/02/2024', 0, 1706745600000, 2, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (25000, 'expense', 'clothes', 'New clothes', '14/02/2024', 0, 1706745600000, 2, 2024, NULL, NULL);

-- March 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (35000, 'expense', 'medicine', 'Doctor appointment', '10/03/2024', 0, 1709251200000, 3, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (50000, 'income', 'gift', 'Birthday gift', '15/03/2024', 0, 1709251200000, 3, 2024, NULL, NULL);

-- April 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (12000, 'expense', 'food', 'Special dinner', '20/04/2024', 0, 1711929600000, 4, 2024, NULL, NULL);

-- May 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (6500, 'expense', 'hygiene', 'Hygiene products', '08/05/2024', 0, 1714521600000, 5, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (18000, 'expense', 'stuff', 'Bluetooth headphones', '22/05/2024', 0, 1714521600000, 5, 2024, NULL, NULL);

-- June 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (95000, 'expense', 'transport', 'Car servicing', '15/06/2024', 0, 1717200000000, 6, 2024, NULL, NULL);

-- July 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (7800, 'expense', 'food', 'iFood during the week', '10/07/2024', 0, 1719792000000, 7, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (200000, 'income', 'investment', 'REIT dividends', '15/07/2024', 0, 1719792000000, 7, 2024, NULL, NULL);

-- August 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (32000, 'expense', 'gift', 'Gift for a friend', '12/08/2024', 0, 1722470400000, 8, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (14500, 'expense', 'food', 'Weekend barbecue', '24/08/2024', 0, 1722470400000, 8, 2024, NULL, NULL);

-- September 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (45000, 'expense', 'stuff', 'Mouse + keyboard', '05/09/2024', 0, 1725148800000, 9, 2024, NULL, NULL);

-- October 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (28000, 'expense', 'clothes', 'Running shoes', '18/10/2024', 0, 1727740800000, 10, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (9500, 'expense', 'medicine', 'Pharmacy', '25/10/2024', 0, 1727740800000, 10, 2024, NULL, NULL);

-- November 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'expense', 'stuff', 'Black Friday - monitor', '29/11/2024', 0, 1730419200000, 11, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (100000, 'income', 'other', 'Company bonus', '20/11/2024', 0, 1730419200000, 11, 2024, NULL, NULL);

-- December 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (85000, 'expense', 'gift', 'Christmas gifts', '20/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', '13th salary', '20/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (42000, 'expense', 'food', 'Christmas dinner', '24/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

-- ============================================
-- ONE-OFF TRANSACTIONS - 2025
-- ============================================

-- January 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (22000, 'expense', 'stuff', 'Office supplies', '08/01/2025', 0, 1735689600000, 1, 2025, NULL, NULL);

-- February 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (18500, 'expense', 'food', 'Japanese restaurant', '14/02/2025', 0, 1738368000000, 2, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (35000, 'expense', 'gift', 'Gift for girlfriend', '14/02/2025', 0, 1738368000000, 2, 2025, NULL, NULL);

-- March 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (65000, 'expense', 'care', 'Dentist', '10/03/2025', 0, 1740787200000, 3, 2025, NULL, NULL);

-- April 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (11000, 'expense', 'transport', 'Tire replacement', '22/04/2025', 0, 1743465600000, 4, 2025, NULL, NULL);

-- May 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (7200, 'expense', 'hygiene', 'Haircut + beard trim', '15/05/2025', 0, 1746057600000, 5, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (300000, 'income', 'investment', 'CD redemption', '20/05/2025', 0, 1746057600000, 5, 2025, NULL, NULL);

-- June 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (19000, 'expense', 'food', 'Summer festival', '24/06/2025', 0, 1748736000000, 6, 2025, NULL, NULL);

-- July 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (120000, 'expense', 'transport', 'Vehicle tax installment', '10/07/2025', 0, 1751328000000, 7, 2025, NULL, NULL);

-- August 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (55000, 'expense', 'stuff', 'Office chair', '05/08/2025', 0, 1754006400000, 8, 2025, NULL, NULL);

-- September 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8900, 'expense', 'food', 'All-you-can-eat pizza', '12/09/2025', 0, 1756684800000, 9, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (15000, 'expense', 'medicine', 'Blood test', '20/09/2025', 0, 1756684800000, 9, 2025, NULL, NULL);

-- October 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (42000, 'expense', 'clothes', 'Winter jacket', '08/10/2025', 0, 1759276800000, 10, 2025, NULL, NULL);

-- November 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (250000, 'expense', 'stuff', 'Black Friday - tablet', '28/11/2025', 0, 1761955200000, 11, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (100000, 'income', 'other', 'Annual bonus', '25/11/2025', 0, 1761955200000, 11, 2025, NULL, NULL);

-- December 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (75000, 'expense', 'gift', 'Christmas gifts', '22/12/2025', 0, 1764547200000, 12, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', '13th salary', '20/12/2025', 0, 1764547200000, 12, 2025, NULL, NULL);

-- ============================================
-- ONE-OFF TRANSACTIONS - 2026
-- ============================================

-- January 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (16000, 'expense', 'food', 'New Year barbecue', '02/01/2026', 0, 1767225600000, 1, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (29000, 'expense', 'stuff', 'Mechanical keyboard', '15/01/2026', 0, 1767225600000, 1, 2026, NULL, NULL);

-- February 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (38000, 'expense', 'care', 'Dermatologist', '10/02/2026', 0, 1769904000000, 2, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (12000, 'expense', 'food', 'Special lunch', '14/02/2026', 0, 1769904000000, 2, 2026, NULL, NULL);

-- March 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (9500, 'expense', 'transport', 'Uber this month', '10/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (22000, 'expense', 'food', 'Biweekly groceries', '08/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'income', 'investment', 'Quarterly dividends', '12/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

-- ============================================
-- RECURRING EXCLUSIONS
-- (simulates months where a recurring transaction was removed)
-- ============================================

-- Salary (id=1) excluded in Feb/2024 (e.g. unpaid leave)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 2, 2024 FROM transactions WHERE description = 'Salary' AND isRecurring = 1;

-- Gym (id=5) excluded in Aug/2024 (e.g. travel)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 8, 2024 FROM transactions WHERE description = 'Smart Fit gym' AND isRecurring = 1;

-- Netflix+Spotify (id=6) excluded in Oct/2024 (e.g. temporarily cancelled)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 10, 2024 FROM transactions WHERE description = 'Netflix + Spotify' AND isRecurring = 1;

-- ============================================
-- DATA SUMMARY
-- ============================================
-- Recurring: 8 transactions (5 with no end, 2 with an end, 1 since 2025)
-- One-off 2024: 16 transactions (12 months covered)
-- One-off 2025: 14 transactions (12 months covered)
-- One-off 2026: 7 transactions (Jan-Mar covered)
-- Exclusions: 3 (to test the recurring filter)
-- Total: ~45 transactions
