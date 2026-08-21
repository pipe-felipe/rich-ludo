# RichLudo - Agent Guidelines

## Architecture
Clean Architecture + MVVM (Flutter recommended patterns):
```
lib/
├── data/           # Concrete implementations
│   ├── local/      # DAO and DatabaseHelper (SQLite)
│   ├── repository/ # *RepositoryImpl
│   └── services/   # *Service (interface) + *LocalService (impl)
├── domain/         # Pure business rules
│   ├── model/      # Immutable entities with copyWith
│   ├── repository/ # Abstract interfaces
│   └── usecase/    # Use cases (1 call() method)
├── presentation/   # MVVM
│   ├── ui/         # View: screens/, widgets/, theme/, utils/
│   └── viewmodel/  # ViewModel: ChangeNotifier + Commands
└── utils/          # Result<T>, Command<T>
```
- **MVVM**: View (widgets) observes the ViewModel via `Consumer`/`ListenableBuilder`
- **DI**: Provider in `main.dart` (Service → Repository → UseCase → ViewModel)
- **Result<T>**: Sealed class for error handling (`Ok<T>` | `Error<T>`)
- **Command<T>**: Wraps async ops with `running`, `completed`, `error` states

## Code Style
- **Models**: Immutable, `copyWith()`, `==` and `hashCode` implemented
- **Interfaces**: Abstract classes in `domain/` (Repository, Service)
- **Private widgets**: `_NameWidget` when used only in the same file
- **Documentation**: Only on important public classes/methods (include a docs.flutter.dev link when relevant)
- **Money values**: `int amountCents` (cents), format with `formatMoney()`
- **Dates**: `targetMonth` (1-12), `targetYear`, `createdAt` (ms epoch)
- **Enums**: Use for finite types (`TransactionType`, `ExpenseCategory`)
- **Language**: Code, comments and tests in English; user-facing strings only through `AppLocalizations` (`lib/l10n/*.arb`)

OBS: Do not, ever, create a code duplication
Make sure that there is no string or other kinda of variables that is created more than one time

## Testing
Structure mirrored in `test/`:
```
test/
├── data/repository/     # RepositoryImpl tests
├── domain/usecase/      # UseCase tests
├── presentation/viewmodel/ # ViewModel tests
└── fakes/               # FakeTransactionRepository, FakeTransactionService
```

### Patterns:
- **Mocking**: `mocktail` (Mock classes, `when()`, `verify()`)
- **Fakes**: Classes in `test/fakes/` with a `shouldReturnError` flag
- **Names**: In English: `test('should return X when Y', ...)`
- **Setup**: `setUp()` to create mocks, `setUpAll()` for `registerFallbackValue`
- **ViewModels**: Always call `dispose()` at the end of the test
- **Commands**: Test the `running`, `completed`, `error` states
- **Groups**: Group by functionality: `group('SomeUseCase', () { ... })`

### Test example:
```dart
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  test('should return Result.ok with transactions', () async {
    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Result.ok([/* transactions */]));

    final result = await useCase();

    expect(result.isOk, isTrue);
    verify(() => mockRepository.getTransactions()).called(1);
  });
}
```

## Quick Reference
| Layer | Suffix | Tested with |
|--------|--------|-----------|
| Model | - | Directly (no mock) |
| UseCase | UseCase | Mock of the Repository |
| Repository | RepositoryImpl | Mock of the Service |
| Service | Service/LocalService | Fake or integration |
| ViewModel | ViewModel | Mock of the UseCases |

## Commands
```bash
flutter test                    # Run tests
flutter test --coverage         # With coverage
flutter analyze                 # Lint
```
