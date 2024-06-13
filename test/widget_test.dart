// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuffler/database/entities.dart';

import 'package:shuffler/main.dart';

class MockLogger extends Mock implements Logger {}

class MockClient extends Mock implements oauth2.Client {}

class MockPackageInfo extends Mock implements PackageInfo {}

void main() {
  setUp(
    () async => {
      SharedPreferences.setMockInitialValues({'colorSeed': 0x1, 'isDark': true}),
      GetIt.instance.registerSingleton<AppDatabase>(AppDatabase.customExecutor(NativeDatabase.memory())),
      GetIt.instance.registerSingleton<Logger>(MockLogger()),
      GetIt.instance.registerSingleton<oauth2.Client>(MockClient()),
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

  tearDown(() async {
    GetIt.instance
        .unregister(instance: GetIt.instance<AppDatabase>(), disposingFunction: (AppDatabase db) => db.close());
    GetIt.instance.reset();
  });
}
