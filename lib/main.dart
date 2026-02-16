import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

import 'data/services/export_local_service.dart';
import 'data/services/export_service.dart';
import 'data/services/transaction_service.dart';
import 'data/services/transaction_local_service.dart';
import 'data/repository/transaction_repository_impl.dart';
import 'domain/repository/transaction_repository.dart';
import 'domain/usecase/delete_transaction_usecase.dart';
import 'domain/usecase/export_database_usecase.dart';
import 'domain/usecase/get_transactions_usecase.dart';
import 'domain/usecase/import_database_usecase.dart';
import 'domain/usecase/make_transaction_usecase.dart';
import 'presentation/ui/theme/app_theme.dart';
import 'presentation/ui/screens/main_screen.dart';
import 'presentation/viewmodel/main_screen_viewmodel.dart';
import 'presentation/viewmodel/transaction_form_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RichLudoApp());
}

class RichLudoApp extends StatelessWidget {
  const RichLudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TransactionService>(
          create: (_) => TransactionLocalService(),
        ),
        Provider<ExportService>(
          create: (_) => ExportLocalService(),
        ),
        
        Provider<TransactionRepository>(
          create: (context) => TransactionRepositoryImpl(
            service: context.read<TransactionService>(),
          ),
        ),
        
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            context.read<TransactionRepository>(),
          ),
        ),
        Provider<MakeTransactionUseCase>(
          create: (context) => MakeTransactionUseCase(
            context.read<TransactionRepository>(),
          ),
        ),
        Provider<DeleteTransactionUseCase>(
          create: (context) => DeleteTransactionUseCase(
            context.read<TransactionRepository>(),
          ),
        ),
        Provider<ExportDatabaseUseCase>(
          create: (context) => ExportDatabaseUseCase(
            context.read<ExportService>(),
          ),
        ),
        Provider<ImportDatabaseUseCase>(
          create: (context) => ImportDatabaseUseCase(
            context.read<ExportService>(),
          ),
        ),
        
        ChangeNotifierProvider<MainScreenViewModel>(
          create: (context) => MainScreenViewModel(
            getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
            exportDatabaseUseCase: context.read<ExportDatabaseUseCase>(),
            importDatabaseUseCase: context.read<ImportDatabaseUseCase>(),
          ),
        ),
        ChangeNotifierProvider<TransactionFormViewModel>(
          create: (context) => TransactionFormViewModel(
            makeTransactionUseCase: context.read<MakeTransactionUseCase>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RichLudo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', ''),
          Locale('en', ''),
        ],
        locale: const Locale('pt', ''),
        home: const MainScreen(),
      ),
    );
  }
}
