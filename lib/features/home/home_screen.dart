import 'package:flutter/material.dart';

import '../../core/astronomy/astronomy.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/moon_phase_l10n.dart';

/// Placeholder home screen that proves the theme, fonts, translations and
/// moon engine are wired together. Phase 2 replaces it with the moon screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.now});

  /// The instant to show, for tests. Null means the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = const MoonCalculator().stateAt(now ?? DateTime.now());
    final percent = (state.illuminatedFraction * 100).round();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.skyGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.appTitle, style: theme.textTheme.labelLarge),
                const SizedBox(height: 24),
                Text(
                  state.phaseName.label(l10n),
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.illuminationValue('$percent%'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.moonAgeDays(state.age.inDays),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
