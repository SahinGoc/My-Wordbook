import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:my_wordbook/services/ad_service.dart';
import 'package:my_wordbook/providers/language_operations.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:my_wordbook/providers/theme_operations.dart';
import 'package:my_wordbook/providers/word_operations.dart';
import 'package:my_wordbook/screens/dictionary_screen.dart';
import 'package:my_wordbook/screens/main_screen.dart';
import 'package:my_wordbook/screens/store_screen.dart';
import 'package:my_wordbook/screens/online_translator_screen.dart';
import 'package:my_wordbook/screens/quiz_screen.dart';
import 'package:my_wordbook/themes/dark_theme.dart';
import 'package:my_wordbook/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:my_wordbook/providers/dictionary_operations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  Intl.defaultLocale = 'tr_TR';
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => DictionaryOperations()),
      ChangeNotifierProvider(create: (context) => LanguageOperations()),
      ChangeNotifierProvider(create: (context) => ThemeOperations()),
      ChangeNotifierProvider(create: (context) => WordOperations()),
      ChangeNotifierProvider(create: (context) => StoreOperations()),
      ChangeNotifierProvider(create: (context) => AdService())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeOperations>(context, listen: false)
          .loadInitialThemeMode(context);
      Provider.of<StoreOperations>(context, listen: false).loadInitialAll();
      Provider.of<AdService>(context, listen: false).resetAdState();
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final themeOperations = Provider.of<ThemeOperations>(context);

    themeOperations.loadInitialThemeMode(context);

    return ScreenUtilInit(
        designSize: Size(393, 851),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            locale: Locale('tr', 'TR'),
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics)
            ],
            debugShowCheckedModeBanner: false,
            themeMode: themeOperations.themeMode,
            theme: lightTheme(context),
            darkTheme: darkTheme(context),
            initialRoute: "/",
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  );
                case '/dictionary':
                  final int? dictionaryId = settings.arguments as int?;
                  return MaterialPageRoute(
                    builder: (context) => DictionaryScreen(id: dictionaryId!),
                  );
                case '/online_translator':
                  return MaterialPageRoute(
                    builder: (context) => const OnlineTranslatorScreen(),
                  );
                case '/quiz':
                  final args = settings.arguments as Map<String, int>;
                  final int? dictionaryId = args['id'];
                  final int? numberOfQuestions = args['numberOfQuestions'];
                  final int? record = args['record'];
                  final int? order = args['order'];
                  final int? selectedDifficulty = args['selectedDifficulty'];
                  return MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      id: dictionaryId!,
                      numbersOfQuestions: numberOfQuestions!,
                      record: record!,
                      order: order!,
                      selectedDifficulty: selectedDifficulty!,
                    ),
                  );
                case '/store':
                  return MaterialPageRoute(
                      builder: (context) => const StoreScreen());
                default:
                  return MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  );
              }
            },
            title: 'My WordBook',
          );
        });
  }
}
