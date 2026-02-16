import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];
  String get formPrompt;
  String get formTextfieldLabel;
  String get formSubmitButton;
  String get formCloseButtonDescription;
  String get formDateLabel;
  String get formCategoryLabel;
  String get formQuantityLabel;
  String get formNotesLabel;
  String get formRecurringLabel;
  String get transactionTypeExpense;
  String get transactionTypeIncome;
  String get expenseCategoryTransport;
  String get expenseCategoryGift;
  String get expenseCategoryRecurring;
  String get expenseCategoryFood;
  String get expenseCategoryStuff;
  String get expenseCategoryMedicine;
  String get expenseCategoryClothes;
  String get income;
  String get saving;
  String get outgoing;
  String get incomeCategorySalary;
  String get incomeCategoryGift;
  String get incomeCategoryInvestment;
  String get incomeCategoryOther;
  String get labelInvalidNumber;
  String get noTransaction;
  String get errorLoading;
  String get tryAgain;
  String get exportSuccess;
  String get exportError;
  String get importSuccess;
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
