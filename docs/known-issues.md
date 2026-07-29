# Known issues and boundaries

## Relevant to the monthly bar

### SQLite path is under-tested

The active app path is `TransactionLocalService`, but the current test suite primarily mocks its use case. A green ViewModel test can therefore hide a mismatch between SQL results and in-memory filtering.

### Possible stale summary during loading

Navigation notifies listeners before the new month finishes loading. The transaction content displays a spinner, but the top bar has no explicit loading state. Verify the visible behavior before deciding whether to clear or mask the previous ratio.

### Savings is a separate defect candidate

Savings uses the real current month as its recurring reference even when an older or future month is selected. Do not mix that rule into the income/expense bar fix.

## Other confirmed maintenance issues

These are documented for future work and are not part of the monthly bar fix:

- The active path uses `getTransactionsByMonthYear()` and `targetMonth`/`targetYear`; older `createdAt`-based semantics still exist in the unused DAO and must not be mixed into the current flow.
- `TransactionDao` is an unused legacy data path with semantics different from `TransactionLocalService`.
- Spanish localization files exist, but `RichLudoApp` supports only Portuguese and English and hard-codes the Portuguese locale.
- Backup import replaces the database file and reopens it, but does not validate the backup before replacing the current file or provide rollback.
- `FormUiState.copyWith()` cannot explicitly clear nullable category fields, so switching transaction type can preserve stale category state.
- The form accepts zero as a valid amount, allowing zero-value transactions.
- There is no UI integration test covering the main screen, dialogs, import/export actions, or the top-bar ratio rendering.

Only the first three monthly-bar entries belong in the current `PLAN.md`. The remaining entries should not expand that task.
