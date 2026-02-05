# RichLudo - Agent Guidelines

## Architecture
Clean Architecture + MVVM (Flutter recommended patterns):
```
lib/
├── data/           # Implementações concretas
│   ├── local/      # DAO e DatabaseHelper (SQLite)
│   ├── repository/ # *RepositoryImpl
│   └── services/   # *Service (interface) + *LocalService (impl)
├── domain/         # Regras de negócio puras
│   ├── model/      # Entidades imutáveis com copyWith
│   ├── repository/ # Interfaces abstratas
│   └── usecase/    # Casos de uso (1 método call())
├── presentation/   # MVVM
│   ├── ui/         # View: screens/, widgets/, theme/, utils/
│   └── viewmodel/  # ViewModel: ChangeNotifier + Commands
└── utils/          # Result<T>, Command<T>
```
- **MVVM**: View (widgets) observa ViewModel via `Consumer`/`ListenableBuilder`
- **DI**: Provider no `main.dart` (Service → Repository → UseCase → ViewModel)
- **Result<T>**: Sealed class para error handling (`Ok<T>` | `Error<T>`)
- **Command<T>**: Encapsula async ops com estados `running`, `completed`, `error`

## Code Style
- **Models**: Imutáveis, `copyWith()`, `==` e `hashCode` implementados
- **Interfaces**: Classes abstratas em `domain/` (Repository, Service)
- **Widgets privados**: `_NomeWidget` quando usados apenas no mesmo arquivo
- **Documentação**: Apenas em classes/métodos públicos importantes (incluir link docs.flutter.dev quando relevante)
- **Valores monetários**: `int amountCents` (centavos), formatar com `formatMoney()`
- **Datas**: `targetMonth` (1-12), `targetYear`, `createdAt` (ms epoch)
- **Enums**: Usar para tipos finitos (`TransactionType`, `ExpenseCategory`)

OBS: Do not, ever, create a code duplication
Make sure that there is no string or other kinda of variables that is created more than one time

## Testing
Estrutura espelhada em `test/`:
```
test/
├── data/repository/     # Testes de RepositoryImpl
├── domain/usecase/      # Testes de UseCases
├── presentation/viewmodel/ # Testes de ViewModels
└── fakes/               # FakeTransactionRepository, FakeTransactionService
```

### Padrões:
- **Mocking**: `mocktail` (Mock classes, `when()`, `verify()`)
- **Fakes**: Classes em `test/fakes/` com `shouldReturnError` flag
- **Nomes**: Em português: `test('deve retornar X quando Y', ...)`
- **Setup**: `setUp()` para criar mocks, `setUpAll()` para `registerFallbackValue`
- **ViewModels**: Sempre chamar `dispose()` no final do teste
- **Commands**: Testar estados `running`, `completed`, `error`
- **Groups**: Agrupar por funcionalidade: `group('NomeUseCase', () { ... })`

### Exemplo de teste:
```dart
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  test('deve retornar Result.ok com transações', () async {
    when(() => mockRepository.getTransactions())
        .thenAnswer((_) async => Result.ok([/* transactions */]));
    
    final result = await useCase();
    
    expect(result.isOk, isTrue);
    verify(() => mockRepository.getTransactions()).called(1);
  });
}
```

## Quick Reference
| Camada | Sufixo | Teste com |
|--------|--------|-----------|
| Model | - | Direto (sem mock) |
| UseCase | UseCase | Mock do Repository |
| Repository | RepositoryImpl | Mock do Service |
| Service | Service/LocalService | Fake ou integração |
| ViewModel | ViewModel | Mock dos UseCases |

## Commands
```bash
flutter test                    # Rodar testes
flutter test --coverage         # Com cobertura
flutter analyze                 # Lint
```

