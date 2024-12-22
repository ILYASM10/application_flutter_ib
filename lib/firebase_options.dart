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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSguIMEOar7kyVEaLL8rb7bexEVqK4Va4',
    appId: '1:721395147753:web:e39a1c0d2946887e96e178',
    messagingSenderId: '721395147753',
    projectId: 'appcouple-8647b',
    authDomain: 'appcouple-8647b.firebaseapp.com',
    databaseURL: 'https://appcouple-8647b-default-rtdb.firebaseio.com',
    storageBucket: 'appcouple-8647b.appspot.com',
    measurementId: 'G-PMH96Y1MDJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-TtwSJ6B1rsPPCMA_rLO2eF1vWWqFy88',
    appId: '1:721395147753:android:0a7e84f28bbcdaa896e178',
    messagingSenderId: '721395147753',
    projectId: 'appcouple-8647b',
    databaseURL: 'https://appcouple-8647b-default-rtdb.firebaseio.com',
    storageBucket: 'appcouple-8647b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxY0l6R02TL17r7sSP6DNASkd29veGRmY',
    appId: '1:721395147753:ios:eb12190ed1951af096e178',
    messagingSenderId: '721395147753',
    projectId: 'appcouple-8647b',
    databaseURL: 'https://appcouple-8647b-default-rtdb.firebaseio.com',
    storageBucket: 'appcouple-8647b.appspot.com',
    iosBundleId: 'com.example.applicationCouple2',
  );
}
