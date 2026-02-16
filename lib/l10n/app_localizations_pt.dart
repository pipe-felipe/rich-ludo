// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get formPrompt => 'Preencha o campo abaixo:';

  @override
  String get formTextfieldLabel => 'Campo de texto';

  @override
  String get formSubmitButton => 'Enviar';

  @override
  String get formCloseButtonDescription => 'Fechar';

  @override
  String get formDateLabel => 'Data';

  @override
  String get formCategoryLabel => 'Categoria';

  @override
  String get formQuantityLabel => 'R\$ Valor';

  @override
  String get formNotesLabel => 'Notas';

  @override
  String get formRecurringLabel => 'Repete';

  @override
  String get transactionTypeExpense => 'Despesa';

  @override
  String get transactionTypeIncome => 'Receita';

  @override
  String get expenseCategoryTransport => 'Transporte';

  @override
  String get expenseCategoryGift => 'Presente';

  @override
  String get expenseCategoryRecurring => 'Recorrente';

  @override
  String get expenseCategoryFood => 'Comida';

  @override
  String get expenseCategoryStuff => 'Coisas';

  @override
  String get expenseCategoryMedicine => 'Remédio';

  @override
  String get expenseCategoryClothes => 'Roupas';

  @override
  String get income => 'Renda';

  @override
  String get saving => 'Economia';

  @override
  String get outgoing => 'Despesas';

  @override
  String get incomeCategorySalary => 'Salário';

  @override
  String get incomeCategoryGift => 'Presente';

  @override
  String get incomeCategoryInvestment => 'Investimento';

  @override
  String get incomeCategoryOther => 'Outro';

  @override
  String get labelInvalidNumber => 'Número Inválido';

  @override
  String get noTransaction => 'Sem transações para mostrar';

  @override
  String get errorLoading => 'Erro ao carregar dados';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get exportSuccess => 'Backup exportado com sucesso!';

  @override
  String get exportError => 'Erro ao exportar backup';

  @override
  String get importSuccess => 'Backup restaurado com sucesso!';

  @override
  String get importError => 'Erro ao restaurar backup';
}
