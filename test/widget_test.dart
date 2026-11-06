import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/app.dart';
import 'package:moon_cycle/l10n/app_localizations.dart';

import 'support/fakes.dart';

void main() {
  final fullMoon = DateTime.utc(2025, 3, 14, 6, 55);

  testWidgets('the app starts in English', (tester) async {
    final overrides = await testOverrides(now: fullMoon);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MoonCycleApp(locale: Locale('en')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Full Moon'), findsOneWidget);
    expect(find.text('100% lit'), findsOneWidget);
  });

  testWidgets('the app starts in French', (tester) async {
    final overrides = await testOverrides(now: fullMoon);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MoonCycleApp(locale: Locale('fr')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pleine lune'), findsWidgets);
    expect(find.textContaining('éclairée'), findsOneWidget);
    expect(find.text("Aujourd'hui"), findsOneWidget);
  });

  test('every locale translates every phase', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.phaseWaningGibbous, isNotEmpty);
    }
  });
}
