import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shuffler/database/entities.dart';
import 'package:shuffler/home_page.dart';
import 'package:shuffler/api_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    developer.log(
      record.message,
      name: record.loggerName,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      level: record.level.value,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
  GetIt.instance.registerSingleton<AppDatabase>(AppDatabase());
  try {
    GetIt.instance.registerSingleton<APIUtils>(APIUtils(await APIClient().getClient()));
  } catch (e) {
    Logger("Shuffler/main").severe('Error getting OAuth2 client: $e');
  }
  GetIt.instance.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  GetIt.instance.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
  Color colorSeed = await getPreferenceColor();
  Brightness brightness = await getPreferenceBrightness();
  runApp(MyApp(ColorScheme.fromSeed(seedColor: colorSeed, brightness: brightness)));
}

Future<Color> getPreferenceColor() async {
  return Color(GetIt.instance<SharedPreferences>().getInt('colorSeed') ?? 0xff062b16);
}

Future<Brightness> getPreferenceBrightness() async {
  return GetIt.instance<SharedPreferences>().getBool('isDark') ?? true ? Brightness.dark : Brightness.light;
}

Future<void> setPreferenceBrightness(Brightness brightness) async {
  await GetIt.instance<SharedPreferences>().setBool('isDark', brightness == Brightness.dark);
}

Future<void> setPreferenceColor(Color color) async {
  await GetIt.instance<SharedPreferences>().setInt('colorSeed', color.value);
}

class MyApp extends StatefulWidget {
  final ColorScheme colorScheme;
  const MyApp(this.colorScheme, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ColorScheme? colorScheme;

  void setAppColorScheme(ColorScheme colorScheme) {
    setState(() {
      this.colorScheme = colorScheme;
    });
  }

  @override
  void initState() {
    super.initState();
    setAppColorScheme(widget.colorScheme);
  }

  @override
  void dispose() async {
    super.dispose();
    await GetIt.I<AppDatabase>().close();
  }

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
      home: MyHomePage(),
    );
  }
}
