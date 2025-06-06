// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFQW3yIAibyRwJn1buKgRW1aMEfWIbfgE',
    appId: '1:541223169130:android:f1302df83c8f8a93e72e13',
    messagingSenderId: '541223169130',
    projectId: 'homespice-fd024',
    storageBucket: 'homespice-fd024.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHWlasy81tgcw1jcBqkTYv04-WYKSaU8k',
    appId: '1:541223169130:web:92832288f716dccfe72e13',
    messagingSenderId: '541223169130',
    projectId: 'homespice-fd024',
    authDomain: 'homespice-fd024.firebaseapp.com',
    storageBucket: 'homespice-fd024.firebasestorage.app',
    measurementId: 'G-2LN4G4LJ85',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCHWlasy81tgcw1jcBqkTYv04-WYKSaU8k',
    appId: '1:541223169130:web:d5c56bf8af06fd62e72e13',
    messagingSenderId: '541223169130',
    projectId: 'homespice-fd024',
    authDomain: 'homespice-fd024.firebaseapp.com',
    storageBucket: 'homespice-fd024.firebasestorage.app',
    measurementId: 'G-3WVM04SHPQ',
  );

}