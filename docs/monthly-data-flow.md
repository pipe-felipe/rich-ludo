# Monthly data flow

## Stored month fields

Each transaction has:

- `targetMonth` and `targetYear`: the transaction's start/selected month;
- `createdAt`: creation month timestamp used for ordering and legacy DAO queries;
- `isRecurring`: whether the transaction can appear in more than one month;
- `endMonth` and `endYear`: optional recurring end month.

Recurring exclusions store `(transactionId, month, year)` rows.

## Active SQLite query

`TransactionLocalService.getTransactionsByMonthYear(month, year)` executes:

```sql
WHERE isRecurring = 1
   OR (targetMonth = ? AND targetYear = ?)
```

This is intentionally a two-stage flow:

1. SQLite returns all recurring rows plus one-time rows for the requested month.
2. `MainScreenViewModel._visibleItemsForMonth()` applies recurring start/end dates and exclusions.

The service does not decide whether a recurring row is active in the requested month.

## ViewModel cache

`MainScreenViewModel` uses `_cachedMonths` with the key `month-year`.

- A cache miss queries the selected month.
- A cache hit reuses that month’s raw result and reloads exclusions/balance.
- `_filterAndComputeTotals()` creates the visible list for `_currentMonth` and `_currentYear`.
- Income and expense cents are summed from that visible list.
- Navigation requests a load and queues one reload if another load is already running.

## Top bar contract

`MainScreen` passes:

```dart
totalIncomeCents: viewModel.totalIncomeCents,
totalExpenseCents: viewModel.totalExpenseCents,
```

`MainTopBar` must remain a pure renderer. It must not query the database, read `DateTime.now()` to choose totals, or inspect the cache.

## Known timing behavior

Navigation calls `notifyListeners()` before the async month load completes. The content area listens to `load` and shows a spinner, while the top bar is rebuilt through the ViewModel. If the old ratio remains visible during this interval, the implementation must either expose a summary-loading state or clear the old totals until the selected month is ready.

## Separate savings behavior

`_computeSavingsCents()` uses accumulated non-recurring balance and recurring contributions up to the real current month. That is a separate savings rule and must not be changed while fixing the income/expense bar.
