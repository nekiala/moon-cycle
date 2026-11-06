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

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @backToNow.
  ///
  /// In en, this message translates to:
  /// **'Back to now'**
  String get backToNow;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the moon to move through time'**
  String get dragHint;

  /// Screen reader label for the moon picture.
  ///
  /// In en, this message translates to:
  /// **'{phase}, {percent} lit'**
  String moonPictureLabel(String phase, String percent);

  /// No description provided for @lunarCycle.
  ///
  /// In en, this message translates to:
  /// **'Lunar cycle'**
  String get lunarCycle;

  /// Length of the current lunation, e.g. 'A 29.5-day cycle, new moon to new moon'.
  ///
  /// In en, this message translates to:
  /// **'A {length}-day cycle, new moon to new moon'**
  String cycleLength(String length);

  /// No description provided for @comingUp.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUp;

  /// No description provided for @moonUp.
  ///
  /// In en, this message translates to:
  /// **'Above the horizon'**
  String get moonUp;

  /// No description provided for @moonDown.
  ///
  /// In en, this message translates to:
  /// **'Below the horizon'**
  String get moonDown;

  /// No description provided for @riseSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Moonrise and moonset'**
  String get riseSetTitle;

  /// No description provided for @locationPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'See moonrise and moonset where you are'**
  String get locationPromptTitle;

  /// No description provided for @locationPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Moon Cycle uses an approximate location, kept only on this device.'**
  String get locationPromptBody;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locating;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update location'**
  String get updateLocation;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access was declined.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is off for Moon Cycle. You can turn it on in Settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device.'**
  String get locationServiceOff;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Your location couldn\'t be found. Please try again.'**
  String get locationFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @latitudeNorth.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° N'**
  String latitudeNorth(String degrees);

  /// No description provided for @latitudeSouth.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° S'**
  String latitudeSouth(String degrees);

  /// No description provided for @longitudeEast.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° E'**
  String longitudeEast(String degrees);

  /// No description provided for @longitudeWest.
  ///
  /// In en, this message translates to:
  /// **'{degrees}° W'**
  String longitudeWest(String degrees);

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get noLocation;
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
