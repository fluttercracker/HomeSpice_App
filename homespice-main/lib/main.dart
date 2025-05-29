import 'package:flutter/material.dart';
import 'package:homespice/screens/auth_wrapper.dart';
import 'package:homespice/screens/edit_profile.dart';
import 'package:homespice/screens/forgot_password.dart';
import 'package:homespice/screens/notes.dart';
import 'package:homespice/screens/terms_and_condition_page.dart';
import 'package:homespice/screens/ai_bot.dart';
import 'package:homespice/screens/favourites.dart';
import 'package:homespice/screens/home.dart';
import 'package:homespice/screens/login.dart';
import 'package:homespice/screens/privacy_policy.dart';
import 'package:homespice/screens/profile.dart';
import 'package:homespice/screens/recipes.dart';
import 'package:homespice/screens/settings.dart';
import 'package:homespice/screens/signup.dart';
import 'package:homespice/screens/splash.dart';
import 'package:homespice/screens/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

// Load saved theme mode from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDarkMode') ?? false;
  runApp(
    MyApp(initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light),
  );
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   late ThemeMode _themeMode;

   @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

   void toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      toggleTheme: toggleTheme,
      child: Builder(
        builder: (context) {
          final provider = ThemeProvider.of(context);
          return MaterialApp(
            themeMode: provider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/recipes': (context) => const Recipes(),
        '/aibot': (context) => const AIBot(),
        '/favourites': (context) => const Favourites(),
        '/profile': (context) => const Profile(),
        '/settings': (context) => const Settings(),
        '/privacy': (context) => const PrivacyPolicy(),
        '/terms': (context) => const TermsAndConditionsPage(),
        '/forgot_password': (context) => ForgotPassword(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/AuthWrapper': (context) => const AuthWrapper(),
        '/Notes': (context) => const NoteWidget(),
      },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
