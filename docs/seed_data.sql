-- ============================================
-- Rich Ludo - Dados de Teste (Seed Data)
-- Desde Janeiro/2024 até Março/2026
-- Inclui transações únicas e recorrentes
-- ============================================

-- Limpar dados existentes
DELETE FROM recurring_exclusions;
DELETE FROM transactions;

-- ============================================
-- TRANSAÇÕES RECORRENTES (aparecem todo mês)
-- ============================================

-- Salário mensal: R$ 5.500,00 (desde Jan/2024, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', 'Salário CLT', '05/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Aluguel: R$ 1.200,00 (desde Jan/2024, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (120000, 'expense', 'recurring', 'Aluguel apartamento', '10/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Internet: R$ 119,90 (desde Jan/2024, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (11990, 'expense', 'recurring', 'Internet fibra 300MB', '15/01/2024', 1, 1704067200000, 1, 2024, NULL, NULL);

-- Celular: R$ 59,90 (desde Mar/2024, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (5990, 'expense', 'recurring', 'Plano celular', '20/03/2024', 1, 1709251200000, 3, 2024, NULL, NULL);

-- Academia: R$ 89,90 (desde Jan/2024, terminou em Dez/2024)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8990, 'expense', 'care', 'Academia Smart Fit', '01/01/2024', 1, 1704067200000, 1, 2024, 12, 2024);

-- Streaming: R$ 55,90 (desde Jun/2024, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (5590, 'expense', 'recurring', 'Netflix + Spotify', '01/06/2024', 1, 1717200000000, 6, 2024, NULL, NULL);

-- Freelance extra: R$ 1.500,00 (desde Set/2024, terminou em Fev/2025)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'income', 'other', 'Freelance dev mobile', '10/09/2024', 1, 1725148800000, 9, 2024, 2, 2025);

-- Seguro carro: R$ 210,00 (desde Jan/2025, sem fim)
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (21000, 'expense', 'recurring', 'Seguro auto parcela', '05/01/2025', 1, 1735689600000, 1, 2025, NULL, NULL);

-- ============================================
-- TRANSAÇÕES ÚNICAS - 2024
-- ============================================

-- Janeiro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (4500, 'expense', 'food', 'Almoço restaurante', '12/01/2024', 0, 1704067200000, 1, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (15000, 'expense', 'transport', 'Uber semana', '20/01/2024', 0, 1704067200000, 1, 2024, NULL, NULL);

-- Fevereiro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8900, 'expense', 'food', 'Supermercado', '05/02/2024', 0, 1706745600000, 2, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (25000, 'expense', 'clothes', 'Roupa nova', '14/02/2024', 0, 1706745600000, 2, 2024, NULL, NULL);

-- Março 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (35000, 'expense', 'medicine', 'Consulta médica', '10/03/2024', 0, 1709251200000, 3, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (50000, 'income', 'gift', 'Presente aniversário', '15/03/2024', 0, 1709251200000, 3, 2024, NULL, NULL);

-- Abril 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (12000, 'expense', 'food', 'Jantar especial', '20/04/2024', 0, 1711929600000, 4, 2024, NULL, NULL);

-- Maio 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (6500, 'expense', 'hygiene', 'Produtos higiene', '08/05/2024', 0, 1714521600000, 5, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (18000, 'expense', 'stuff', 'Fone bluetooth', '22/05/2024', 0, 1714521600000, 5, 2024, NULL, NULL);

-- Junho 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (95000, 'expense', 'transport', 'Revisão carro', '15/06/2024', 0, 1717200000000, 6, 2024, NULL, NULL);

-- Julho 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (7800, 'expense', 'food', 'iFood semana', '10/07/2024', 0, 1719792000000, 7, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (200000, 'income', 'investment', 'Dividendos FIIs', '15/07/2024', 0, 1719792000000, 7, 2024, NULL, NULL);

-- Agosto 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (32000, 'expense', 'gift', 'Presente amigo', '12/08/2024', 0, 1722470400000, 8, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (14500, 'expense', 'food', 'Churrasco fim de semana', '24/08/2024', 0, 1722470400000, 8, 2024, NULL, NULL);

-- Setembro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (45000, 'expense', 'stuff', 'Mouse + teclado', '05/09/2024', 0, 1725148800000, 9, 2024, NULL, NULL);

-- Outubro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (28000, 'expense', 'clothes', 'Tênis corrida', '18/10/2024', 0, 1727740800000, 10, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (9500, 'expense', 'medicine', 'Farmácia', '25/10/2024', 0, 1727740800000, 10, 2024, NULL, NULL);

-- Novembro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'expense', 'stuff', 'Black Friday - monitor', '29/11/2024', 0, 1730419200000, 11, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (100000, 'income', 'other', 'Bônus empresa', '20/11/2024', 0, 1730419200000, 11, 2024, NULL, NULL);

-- Dezembro 2024
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (85000, 'expense', 'gift', 'Presentes Natal', '20/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', '13º salário', '20/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (42000, 'expense', 'food', 'Ceia Natal', '24/12/2024', 0, 1733011200000, 12, 2024, NULL, NULL);

-- ============================================
-- TRANSAÇÕES ÚNICAS - 2025
-- ============================================

-- Janeiro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (22000, 'expense', 'stuff', 'Material escritório', '08/01/2025', 0, 1735689600000, 1, 2025, NULL, NULL);

-- Fevereiro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (18500, 'expense', 'food', 'Restaurante japonês', '14/02/2025', 0, 1738368000000, 2, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (35000, 'expense', 'gift', 'Presente namorada', '14/02/2025', 0, 1738368000000, 2, 2025, NULL, NULL);

-- Março 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (65000, 'expense', 'care', 'Dentista', '10/03/2025', 0, 1740787200000, 3, 2025, NULL, NULL);

-- Abril 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (11000, 'expense', 'transport', 'Troca pneu', '22/04/2025', 0, 1743465600000, 4, 2025, NULL, NULL);

-- Maio 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (7200, 'expense', 'hygiene', 'Corte cabelo + barba', '15/05/2025', 0, 1746057600000, 5, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (300000, 'income', 'investment', 'Resgate CDB', '20/05/2025', 0, 1746057600000, 5, 2025, NULL, NULL);

-- Junho 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (19000, 'expense', 'food', 'Festa junina', '24/06/2025', 0, 1748736000000, 6, 2025, NULL, NULL);

-- Julho 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (120000, 'expense', 'transport', 'IPVA parcela', '10/07/2025', 0, 1751328000000, 7, 2025, NULL, NULL);

-- Agosto 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (55000, 'expense', 'stuff', 'Cadeira escritório', '05/08/2025', 0, 1754006400000, 8, 2025, NULL, NULL);

-- Setembro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (8900, 'expense', 'food', 'Rodízio pizza', '12/09/2025', 0, 1756684800000, 9, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (15000, 'expense', 'medicine', 'Exame sangue', '20/09/2025', 0, 1756684800000, 9, 2025, NULL, NULL);

-- Outubro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (42000, 'expense', 'clothes', 'Jaqueta inverno', '08/10/2025', 0, 1759276800000, 10, 2025, NULL, NULL);

-- Novembro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (250000, 'expense', 'stuff', 'Black Friday - tablet', '28/11/2025', 0, 1761955200000, 11, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (100000, 'income', 'other', 'Bônus anual', '25/11/2025', 0, 1761955200000, 11, 2025, NULL, NULL);

-- Dezembro 2025
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (75000, 'expense', 'gift', 'Presentes Natal', '22/12/2025', 0, 1764547200000, 12, 2025, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (550000, 'income', 'salary', '13º salário', '20/12/2025', 0, 1764547200000, 12, 2025, NULL, NULL);

-- ============================================
-- TRANSAÇÕES ÚNICAS - 2026
-- ============================================

-- Janeiro 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (16000, 'expense', 'food', 'Churrasco ano novo', '02/01/2026', 0, 1767225600000, 1, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (29000, 'expense', 'stuff', 'Teclado mecânico', '15/01/2026', 0, 1767225600000, 1, 2026, NULL, NULL);

-- Fevereiro 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (38000, 'expense', 'care', 'Dermatologista', '10/02/2026', 0, 1769904000000, 2, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (12000, 'expense', 'food', 'Almoço especial', '14/02/2026', 0, 1769904000000, 2, 2026, NULL, NULL);

-- Março 2026
INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (9500, 'expense', 'transport', 'Uber mês', '10/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (22000, 'expense', 'food', 'Supermercado quinzenal', '08/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

INSERT INTO transactions (amountCents, type, category, description, humanDate, isRecurring, createdAt, targetMonth, targetYear, endMonth, endYear)
VALUES (150000, 'income', 'investment', 'Dividendos trimestrais', '12/03/2026', 0, 1772323200000, 3, 2026, NULL, NULL);

-- ============================================
-- EXCLUSÕES DE RECORRENTES
-- (simula meses onde uma recorrente foi removida)
-- ============================================

-- Salário (id=1) excluído em Fev/2024 (ex: férias sem pagamento)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 2, 2024 FROM transactions WHERE description = 'Salário CLT' AND isRecurring = 1;

-- Academia (id=5) excluída em Ago/2024 (ex: viagem)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 8, 2024 FROM transactions WHERE description = 'Academia Smart Fit' AND isRecurring = 1;

-- Netflix+Spotify (id=6) excluída em Out/2024 (ex: cancelou temporariamente)
INSERT INTO recurring_exclusions (transactionId, month, year)
SELECT id, 10, 2024 FROM transactions WHERE description = 'Netflix + Spotify' AND isRecurring = 1;

-- ============================================
-- RESUMO DOS DADOS
-- ============================================
-- Recorrentes: 8 transações (5 sem fim, 2 com fim, 1 desde 2025)
-- Únicas 2024: 16 transações (12 meses cobertos)
-- Únicas 2025: 14 transações (12 meses cobertos)
-- Únicas 2026: 7 transações (Jan-Mar cobertos)
-- Exclusões: 3 (para testar filtro de recorrentes)
-- Total: ~45 transações

