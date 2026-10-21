// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cycle lunaire';

  @override
  String get phaseNewMoon => 'Nouvelle lune';

  @override
  String get phaseWaxingCrescent => 'Premier croissant';

  @override
  String get phaseFirstQuarter => 'Premier quartier';

  @override
  String get phaseWaxingGibbous => 'Gibbeuse croissante';

  @override
  String get phaseFullMoon => 'Pleine lune';

  @override
  String get phaseWaningGibbous => 'Gibbeuse décroissante';

  @override
  String get phaseLastQuarter => 'Dernier quartier';

  @override
  String get phaseWaningCrescent => 'Dernier croissant';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get illumination => 'Illumination';

  @override
  String illuminationValue(String percent) {
    return '$percent éclairée';
  }

  @override
  String get moonAge => 'Âge de la lune';

  @override
  String moonAgeDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
      zero: 'Moins d\'un jour',
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
  String get moonrise => 'Lever de lune';

  @override
  String get moonset => 'Coucher de lune';

  @override
  String get noMoonrise => 'Pas de lever de lune aujourd\'hui';

  @override
  String get noMoonset => 'Pas de coucher de lune aujourd\'hui';

  @override
  String get moonAlwaysUp => 'La lune reste levée toute la journée';

  @override
  String get moonAlwaysDown => 'La lune reste sous l\'horizon toute la journée';

  @override
  String get nextNewMoon => 'Prochaine nouvelle lune';

  @override
  String get nextFirstQuarter => 'Prochain premier quartier';

  @override
  String get nextFullMoon => 'Prochaine pleine lune';

  @override
  String get nextLastQuarter => 'Prochain dernier quartier';

  @override
  String inDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dans $days jours',
      one: 'Demain',
      zero: 'Aujourd\'hui',
    );
    return '$_temp0';
  }
}
