import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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

  /// No description provided for @expenseCategoryStuff.
  ///
  /// In pt, this message translates to:
  /// **'Coisas'**
  String get expenseCategoryStuff;

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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
