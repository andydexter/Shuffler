// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuffler/api_utils.dart';
import 'package:shuffler/database/entities.dart';

import 'package:shuffler/main.dart';
import 'theme_changer_test.mocks.dart';

class MockPackageInfo extends Mock implements PackageInfo {}

@GenerateMocks([APIUtils])
void main() {
  setUp(
    () async => {
      SharedPreferences.setMockInitialValues({'colorSeed': 0x1, 'isDark': true}),
      GetIt.instance.registerSingleton<AppDatabase>(AppDatabase.customExecutor(NativeDatabase.memory())),
      GetIt.instance.registerSingleton<APIUtils>(MockAPIUtils()),
      GetIt.instance.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance()),
      GetIt.instance.registerSingleton<PackageInfo>(MockPackageInfo()),
    },
  );

  testWidgets('Color Scheme Initialisation Test', (WidgetTester tester) async {
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0x00000001), brightness: Brightness.dark);

    await tester.pumpWidget(MyApp(colorScheme));

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.colorScheme, colorScheme);
  });

  testWidgets('Color Scheme First Run Initialisation Test', (WidgetTester tester) async {
    await GetIt.instance<SharedPreferences>().remove('colorSeed');
    await GetIt.instance<SharedPreferences>().remove('isDark');
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xff062b16), brightness: Brightness.dark);

    await tester.pumpWidget(MyApp(colorScheme));

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.colorScheme, colorScheme);
  });

  testWidgets('Color Scheme Change Test', (WidgetTester tester) async {
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xff062b16), brightness: Brightness.dark);
    ColorScheme schemeToChange = ColorScheme.fromSeed(seedColor: const Color(0xff123456), brightness: Brightness.light);

    await tester.pumpWidget(MyApp(colorScheme));

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.colorScheme, colorScheme);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Change Theme"));
    await tester.pumpAndSettle();

    ColorPicker cp = find.byType(ColorPicker).evaluate().first.widget as ColorPicker;

    cp.onColorChanged(const Color(0xff123456));

    Switch dm = find.byType(Switch).evaluate().first.widget as Switch;

    dm.onChanged!(false);

    await tester.pumpAndSettle();

    await tester.tap(find.text("Preview"));

    await tester.pumpAndSettle();

    expect((find.byType(AppBar).evaluate().first.widget as AppBar).backgroundColor, schemeToChange.primary);

    await tester.tap(find.text("Submit"));

    await tester.pumpAndSettle();

    expect(GetIt.instance<SharedPreferences>().getInt('colorSeed'), 0xff123456);
    expect(GetIt.instance<SharedPreferences>().getBool('isDark'), false);
  });

  testWidgets('Color Scheme Cancel Test', (WidgetTester tester) async {
    await GetIt.instance<SharedPreferences>().setInt('colorSeed', 0xff062b16);
    await GetIt.instance<SharedPreferences>().setBool('isDark', true);
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xff062b16), brightness: Brightness.dark);
    ColorScheme schemeToChange = ColorScheme.fromSeed(seedColor: const Color(0xff123456), brightness: Brightness.light);

    await tester.pumpWidget(MyApp(colorScheme));

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.colorScheme, colorScheme);

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Change Theme"));
    await tester.pumpAndSettle();

    ColorPicker cp = find.byType(ColorPicker).evaluate().first.widget as ColorPicker;

    cp.onColorChanged(const Color(0xff123456));

    Switch dm = find.byType(Switch).evaluate().first.widget as Switch;

    dm.onChanged!(false);

    await tester.pumpAndSettle();

    await tester.tap(find.text("Preview"));

    await tester.pumpAndSettle();

    expect((find.byType(AppBar).evaluate().first.widget as AppBar).backgroundColor, schemeToChange.primary);

    await tester.tap(find.text("Cancel"));

    await tester.pumpAndSettle();

    expect(GetIt.instance<SharedPreferences>().getInt('colorSeed'), 0xff062b16);
    expect(GetIt.instance<SharedPreferences>().getBool('isDark'), true);

    expect((find.byType(AppBar).evaluate().first.widget as AppBar).backgroundColor, colorScheme.primary);
  });

  tearDown(() async {
    GetIt.instance.reset();
  });
}
