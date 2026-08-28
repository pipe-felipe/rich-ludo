import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @formPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o campo abaixo:'**
  String get formPrompt;

  /// No description provided for @formTextfieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Campo de texto'**
  String get formTextfieldLabel;

  /// No description provided for @formSubmitButton.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get formSubmitButton;

  /// No description provided for @formCloseButtonDescription.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get formCloseButtonDescription;

  /// No description provided for @formDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get formDateLabel;

  /// No description provided for @formCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get formCategoryLabel;

  /// No description provided for @formQuantityLabel.
  ///
  /// In pt, this message translates to:
  /// **'R\$ Valor'**
  String get formQuantityLabel;

  /// No description provided for @formNotesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Notas'**
  String get formNotesLabel;

  /// No description provided for @formRecurringLabel.
  ///
  /// In pt, this message translates to:
  /// **'Repete'**
  String get formRecurringLabel;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get transactionTypeIncome;

  /// No description provided for @expenseCategoryTransport.
  ///
  /// In pt, this message translates to:
  /// **'Transporte'**
  String get expenseCategoryTransport;

  /// No description provided for @expenseCategoryGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get expenseCategoryGift;

  /// No description provided for @expenseCategoryRecurring.
  ///
  /// In pt, this message translates to:
  /// **'Recorrente'**
  String get expenseCategoryRecurring;

  /// No description provided for @expenseCategoryFood.
  ///
  /// In pt, this message translates to:
  /// **'Comida'**
  String get expenseCategoryFood;

  /// No description provided for @expenseCategoryMedicine.
  ///
  /// In pt, this message translates to:
  /// **'Remédio'**
  String get expenseCategoryMedicine;

  /// No description provided for @expenseCategoryClothes.
  ///
  /// In pt, this message translates to:
  /// **'Roupas'**
  String get expenseCategoryClothes;

  /// No description provided for @expenseCategoryHygiene.
  ///
  /// In pt, this message translates to:
  /// **'Higiene'**
  String get expenseCategoryHygiene;

  /// No description provided for @income.
  ///
  /// In pt, this message translates to:
  /// **'Renda'**
  String get income;

  /// No description provided for @saving.
  ///
  /// In pt, this message translates to:
  /// **'Economia'**
  String get saving;

  /// No description provided for @outgoing.
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get outgoing;

  /// No description provided for @incomeCategorySalary.
  ///
  /// In pt, this message translates to:
  /// **'Salário'**
  String get incomeCategorySalary;

  /// No description provided for @incomeCategoryGift.
  ///
  /// In pt, this message translates to:
  /// **'Presente'**
  String get incomeCategoryGift;

  /// No description provided for @incomeCategoryInvestment.
  ///
  /// In pt, this message translates to:
  /// **'Investimento'**
  String get incomeCategoryInvestment;

  /// No description provided for @incomeCategoryOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get incomeCategoryOther;

  /// No description provided for @labelInvalidNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número Inválido'**
  String get labelInvalidNumber;

  /// No description provided for @noTransaction.
  ///
  /// In pt, this message translates to:
  /// **'Sem transações para mostrar'**
  String get noTransaction;

  /// No description provided for @errorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar dados'**
  String get errorLoading;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @exportSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Backup exportado com sucesso!'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao exportar backup'**
  String get exportError;

  /// No description provided for @importSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Backup restaurado com sucesso!'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao restaurar backup'**
  String get importError;

  /// No description provided for @recurringDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deletar recorrente'**
  String get recurringDeleteTitle;

  /// No description provided for @recurringDeleteThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Apenas este mês'**
  String get recurringDeleteThisMonth;

  /// No description provided for @recurringDeleteBackwards.
  ///
  /// In pt, this message translates to:
  /// **'Este mês e anteriores'**
  String get recurringDeleteBackwards;

  /// No description provided for @recurringDeleteForwards.
  ///
  /// In pt, this message translates to:
  /// **'Este mês e futuros'**
  String get recurringDeleteForwards;

  /// No description provided for @recurringDeleteAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos os meses'**
  String get recurringDeleteAll;

  /// No description provided for @january.
  ///
  /// In pt, this message translates to:
  /// **'Janeiro'**
  String get january;

  /// No description provided for @february.
  ///
  /// In pt, this message translates to:
  /// **'Fevereiro'**
  String get february;

  /// No description provided for @march.
  ///
  /// In pt, this message translates to:
  /// **'Março'**
  String get march;

  /// No description provided for @april.
  ///
  /// In pt, this message translates to:
  /// **'Abril'**
  String get april;

  /// No description provided for @may.
  ///
  /// In pt, this message translates to:
  /// **'Maio'**
  String get may;

  /// No description provided for @june.
  ///
  /// In pt, this message translates to:
  /// **'Junho'**
  String get june;

  /// No description provided for @july.
  ///
  /// In pt, this message translates to:
  /// **'Julho'**
  String get july;

  /// No description provided for @august.
  ///
  /// In pt, this message translates to:
  /// **'Agosto'**
  String get august;

  /// No description provided for @september.
  ///
  /// In pt, this message translates to:
  /// **'Setembro'**
  String get september;

  /// No description provided for @october.
  ///
  /// In pt, this message translates to:
  /// **'Outubro'**
  String get october;

  /// No description provided for @november.
  ///
  /// In pt, this message translates to:
  /// **'Novembro'**
  String get november;

  /// No description provided for @december.
  ///
  /// In pt, this message translates to:
  /// **'Dezembro'**
  String get december;

  /// No description provided for @chartTitle.
  ///
  /// In pt, this message translates to:
  /// **'Despesas por categoria'**
  String get chartTitle;

  /// No description provided for @categoryUncategorized.
  ///
  /// In pt, this message translates to:
  /// **'Sem categoria'**
  String get categoryUncategorized;

  /// No description provided for @chartTotalExpense.
  ///
  /// In pt, this message translates to:
  /// **'Total de despesas'**
  String get chartTotalExpense;

  /// No description provided for @categoryCreateNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova categoria'**
  String get categoryCreateNew;

  /// No description provided for @categoryManagerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get categoryManagerTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get categoryNameLabel;

  /// No description provided for @categoryIconLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ícone'**
  String get categoryIconLabel;

  /// No description provided for @categoryColorLabel.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get categoryColorLabel;

  /// No description provided for @categorySave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get categorySave;

  /// No description provided for @categoryMineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Suas categorias'**
  String get categoryMineTitle;

  /// No description provided for @categoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não criou nenhuma categoria'**
  String get categoryEmpty;

  /// No description provided for @categoryDeleteTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Excluir categoria'**
  String get categoryDeleteTooltip;

  /// No description provided for @categoryErrorEmptyName.
  ///
  /// In pt, this message translates to:
  /// **'Informe um nome'**
  String get categoryErrorEmptyName;

  /// No description provided for @categoryErrorNameTooLong.
  ///
  /// In pt, this message translates to:
  /// **'Nome muito longo (máximo 30 caracteres)'**
  String get categoryErrorNameTooLong;

  /// No description provided for @categoryErrorDuplicateName.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma categoria com esse nome'**
  String get categoryErrorDuplicateName;

  /// No description provided for @categoryErrorSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a categoria'**
  String get categoryErrorSaveFailed;

  /// No description provided for @categoryDeleteInUse.
  ///
  /// In pt, this message translates to:
  /// **'{count} transações usam esta categoria. Não é possível excluir.'**
  String categoryDeleteInUse(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
