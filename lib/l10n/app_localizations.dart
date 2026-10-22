import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// The app's name.
  ///
  /// In en, this message translates to:
  /// **'Moon Cycle'**
  String get appTitle;

  /// No description provided for @phaseNewMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon'**
  String get phaseNewMoon;

  /// No description provided for @phaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get phaseWaxingCrescent;

  /// No description provided for @phaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get phaseFirstQuarter;

  /// No description provided for @phaseWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing Gibbous'**
  String get phaseWaxingGibbous;

  /// No description provided for @phaseFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon'**
  String get phaseFullMoon;

  /// No description provided for @phaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get phaseWaningGibbous;

  /// No description provided for @phaseLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last Quarter'**
  String get phaseLastQuarter;

  /// No description provided for @phaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get phaseWaningCrescent;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @illumination.
  ///
  /// In en, this message translates to:
  /// **'Illumination'**
  String get illumination;

  /// Share of the moon's disc that is lit, e.g. '78% lit'.
  ///
  /// In en, this message translates to:
  /// **'{percent} lit'**
  String illuminationValue(String percent);

  /// No description provided for @moonAge.
  ///
  /// In en, this message translates to:
  /// **'Moon age'**
  String get moonAge;

  /// Whole days since the last new moon.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Less than a day} =1{1 day} other{{days} days}}'**
  String moonAgeDays(int days);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @moonrise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get moonrise;

  /// No description provided for @moonset.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get moonset;

  /// No description provided for @noMoonrise.
  ///
  /// In en, this message translates to:
  /// **'No moonrise today'**
  String get noMoonrise;

  /// No description provided for @noMoonset.
  ///
  /// In en, this message translates to:
  /// **'No moonset today'**
  String get noMoonset;

  /// No description provided for @moonAlwaysUp.
  ///
  /// In en, this message translates to:
  /// **'The moon stays up all day'**
  String get moonAlwaysUp;

  /// No description provided for @moonAlwaysDown.
  ///
  /// In en, this message translates to:
  /// **'The moon stays below the horizon all day'**
  String get moonAlwaysDown;

  /// No description provided for @nextNewMoon.
  ///
  /// In en, this message translates to:
  /// **'Next new moon'**
  String get nextNewMoon;

  /// No description provided for @nextFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'Next first quarter'**
  String get nextFirstQuarter;

  /// No description provided for @nextFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Next full moon'**
  String get nextFullMoon;

  /// No description provided for @nextLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Next last quarter'**
  String get nextLastQuarter;

  /// How long until an event, in whole days.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today} =1{Tomorrow} other{In {days} days}}'**
  String inDays(int days);
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
