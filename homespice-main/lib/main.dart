import 'package:flutter/material.dart';
import 'package:homespice/screens/edit_profile.dart';
import 'package:homespice/screens/forgot_password.dart';
import 'package:homespice/screens/otp_verify.dart';
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
import 'package:homespice/screens/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
       ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Spice',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
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
        '/otp_verify': (context) => const OtpVerificationScreen(emailOrPhone: '', from: '',),
        '/forgot_password': (context) => ForgotPassword(),
        '/edit_profile': (context) => EditProfileScreen(),
      },
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
