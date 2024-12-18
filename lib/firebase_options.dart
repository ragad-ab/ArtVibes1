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
    apiKey: 'AIzaSyB2sHU-Hfd9EaeT0pCdYCw0d3vPkO3w8io',
    appId: '1:57207556984:web:1ee931aa288fc44351d68d',
    messagingSenderId: '57207556984',
    projectId: 'fir-2-d7965',
    authDomain: 'fir-2-d7965.firebaseapp.com',
    storageBucket: 'fir-2-d7965.appspot.com',
    measurementId: 'G-PY468ZV6J6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvVQpvinIX8wUx2Dxazv0f8dUjIDfuFdY',
    appId: '1:57207556984:android:17405da9c3898a8451d68d',
    messagingSenderId: '57207556984',
    projectId: 'fir-2-d7965',
    storageBucket: 'fir-2-d7965.appspot.com',
  );
}
