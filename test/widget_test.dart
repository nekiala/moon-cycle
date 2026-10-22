import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/app.dart';
import 'package:moon_cycle/core/theme/app_theme.dart';
import 'package:moon_cycle/features/home/home_screen.dart';
import 'package:moon_cycle/l10n/app_localizations.dart';

void main() {
  testWidgets('the app starts in English', (tester) async {
    await tester.pumpWidget(const MoonCycleApp(locale: Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Moon Cycle'), findsOneWidget);
    expect(find.textContaining('lit'), findsOneWidget);
  });

  testWidgets('the app starts in French', (tester) async {
    await tester.pumpWidget(const MoonCycleApp(locale: Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Cycle lunaire'), findsOneWidget);
    expect(find.textContaining('éclairée'), findsOneWidget);
  });

  Widget home(Locale locale, DateTime now) => MaterialApp(
    theme: AppTheme.dark(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: HomeScreen(now: now),
  );

  testWidgets('shows the phase of a known full moon', (tester) async {
    final fullMoon = DateTime.utc(2025, 3, 14, 6, 55);
    await tester.pumpWidget(home(const Locale('en'), fullMoon));
    expect(find.text('Full Moon'), findsOneWidget);
    expect(find.text('100% lit'), findsOneWidget);

    await tester.pumpWidget(home(const Locale('fr'), fullMoon));
    await tester.pumpAndSettle();
    expect(find.text('Pleine lune'), findsOneWidget);
  });

  test('every locale translates every phase', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.phaseWaningGibbous, isNotEmpty);
    }
  });
}
