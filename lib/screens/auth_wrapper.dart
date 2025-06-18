import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homespice/screens/home.dart';
import 'package:homespice/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> isFullyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // 👇 Add FutureBuilder to wait for shared pref
          return FutureBuilder<bool>(
            future: isFullyLoggedIn(),
            builder: (context, loggedInSnap) {
              if (!loggedInSnap.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (loggedInSnap.data == true) {
                return const Home(); // ✅ Firebase + manual flag = logged in
              } else {
                return const LoginPage(); // ❌ Firebase session exists but user didn't finish OTP flow
              }
            },
          );
        } else {
          return const LoginPage(); // no user
        }
      },
    );
  }
}
