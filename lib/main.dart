import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/homePage.dart';
import 'package:shuffler/apiUtils.dart';
import 'package:get_it/get_it.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  GetIt.instance.registerSingleton<AppDatabase>(AppDatabase());
  GetIt.instance.registerSingleton<Logger>(Logger('Shuffler'));
  GetIt.instance.registerSingleton<oauth2.Client>(await APIClient().getClient());
  GetIt.instance.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  Color colorSeed = await getPreferenceColor();
  Brightness brightness = await getPreferenceBrightness();
  runApp(MyApp(ColorScheme.fromSeed(seedColor: colorSeed, brightness: brightness)));
}

Future<Color> getPreferenceColor() async {
  return await SharedPreferences.getInstance().then((prefs) {
    return Color(prefs.getInt('colorSeed') ?? 0xff062b16);
  });
}

Future<Brightness> getPreferenceBrightness() async {
  return await SharedPreferences.getInstance().then((prefs) {
    return prefs.getBool('isDark') ?? true ? Brightness.dark : Brightness.light;
  });
}

Future<void> setPreferenceBrightness(Brightness brightness) async {
  return await SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('isDark', brightness == Brightness.dark);
  });
}

Future<void> setPreferenceColor(Color color) async {
  return await SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('colorSeed', color.value);
  });
}

class MyApp extends StatelessWidget {
  final ColorScheme colorScheme;
  const MyApp(this.colorScheme, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shuffler',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
