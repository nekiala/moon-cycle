// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Moon Cycle';

  @override
  String get phaseNewMoon => 'New Moon';

  @override
  String get phaseWaxingCrescent => 'Waxing Crescent';

  @override
  String get phaseFirstQuarter => 'First Quarter';

  @override
  String get phaseWaxingGibbous => 'Waxing Gibbous';

  @override
  String get phaseFullMoon => 'Full Moon';

  @override
  String get phaseWaningGibbous => 'Waning Gibbous';

  @override
  String get phaseLastQuarter => 'Last Quarter';

  @override
  String get phaseWaningCrescent => 'Waning Crescent';

  @override
  String get today => 'Today';

  @override
  String get illumination => 'Illumination';

  @override
  String illuminationValue(String percent) {
    return '$percent lit';
  }

  @override
  String get moonAge => 'Moon age';

  @override
  String moonAgeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: 'Less than a day',
    );
    return '$_temp0';
  }

  @override
  String get distance => 'Distance';

  @override
  String distanceKm(String distance) {
    return '$distance km';
  }

  @override
  String get moonrise => 'Moonrise';

  @override
  String get moonset => 'Moonset';

  @override
  String get noMoonrise => 'No moonrise today';

  @override
  String get noMoonset => 'No moonset today';

  @override
  String get moonAlwaysUp => 'The moon stays up all day';

  @override
  String get moonAlwaysDown => 'The moon stays below the horizon all day';

  @override
  String get nextNewMoon => 'Next new moon';

  @override
  String get nextFirstQuarter => 'Next first quarter';

  @override
  String get nextFullMoon => 'Next full moon';

  @override
  String get nextLastQuarter => 'Next last quarter';

  @override
  String inDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'In $days days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }
}
