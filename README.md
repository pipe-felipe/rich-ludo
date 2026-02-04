# RichLudo

Aplicativo de controle financeiro pessoal, convertido do projeto RichPipi (Kotlin Multiplatform) para Flutter.

## Arquitetura

Este projeto segue **Clean Architecture** com as seguintes camadas:

### Domain Layer (Pura em Dart, sem dependências de framework)
- **Models**: `Transaction`, `TransactionType`
- **Repository Interfaces**: `TransactionRepository`
- **Use Cases**: `GetTransactionsUseCase`, `MakeTransactionUseCase`, `DeleteTransactionUseCase`

### Data Layer
- **Local Database**: SQLite via `sqflite`
- **DAO**: `TransactionDao`
- **Repository Implementation**: `TransactionRepositoryImpl`

### Presentation Layer
- **ViewModels**: `MainScreenViewModel`, `TransactionFormViewModel` (usando `ChangeNotifier`)
- **UI**: `MainScreen`, `TransactionDialog`
- **Theme**: Tema inspirado em Maltese Dog com suporte a modo claro/escuro

## Estrutura de Pastas

```
lib/
├── data/
│   ├── local/
│   │   ├── dao/
│   │   └── database/
│   └── repository/
├── domain/
│   ├── model/
│   ├── repository/
│   └── usecase/
├── l10n/
├── presentation/
│   ├── ui/
│   │   ├── screens/
│   │   ├── theme/
│   │   └── widgets/
│   └── viewmodel/
└── main.dart
```

## Funcionalidades

- ✅ Adicionar transações (receitas e despesas)
- ✅ Listar transações por mês
- ✅ Navegar entre meses
- ✅ Calcular totais de receitas, despesas e economia
- ✅ Suporte a transações recorrentes
- ✅ Categorias de despesas e receitas
- ✅ Persistência local com SQLite
- ✅ Tema claro/escuro automático
- ✅ Localização em Português

## Compilação

Este projeto está configurado para compilar **apenas para Android e iOS**.

### Executar

```bash
flutter run
```

### Build Android

```bash
flutter build apk
```

### Build iOS

```bash
flutter build ios
```

## Dependências

- `provider`: Gerenciamento de estado
- `sqflite`: Banco de dados SQLite
- `flutter_localizations`: Internacionalização
