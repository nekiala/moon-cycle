import '../core/astronomy/astronomy.dart';
import 'app_localizations.dart';

extension MoonPhaseNameL10n on MoonPhaseName {
  String label(AppLocalizations l10n) => switch (this) {
    MoonPhaseName.newMoon => l10n.phaseNewMoon,
    MoonPhaseName.waxingCrescent => l10n.phaseWaxingCrescent,
    MoonPhaseName.firstQuarter => l10n.phaseFirstQuarter,
    MoonPhaseName.waxingGibbous => l10n.phaseWaxingGibbous,
    MoonPhaseName.fullMoon => l10n.phaseFullMoon,
    MoonPhaseName.waningGibbous => l10n.phaseWaningGibbous,
    MoonPhaseName.lastQuarter => l10n.phaseLastQuarter,
    MoonPhaseName.waningCrescent => l10n.phaseWaningCrescent,
  };
}
