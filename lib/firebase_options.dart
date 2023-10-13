// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyAjU_mrzeTli_g4V98zMeb_3uMD4Nu60XY',
    appId: '1:589578730909:web:16d9ecd67d9f10e8890374',
    messagingSenderId: '589578730909',
    projectId: 'pinkpapaya-6e06c',
    authDomain: 'pinkpapaya-6e06c.firebaseapp.com',
    storageBucket: 'pinkpapaya-6e06c.appspot.com',
    measurementId: 'G-EWRNEY7HZ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByGqyfPtxdZt6zVkfgZeBLmMLlgedl2ro',
    appId: '1:589578730909:android:6db7daa589046706890374',
    messagingSenderId: '589578730909',
    projectId: 'pinkpapaya-6e06c',
    storageBucket: 'pinkpapaya-6e06c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqBrfD5X8rjSnIPW7SmsIdQxeKKuKmdSE',
    appId: '1:589578730909:ios:e74641dbc1d2d5b9890374',
    messagingSenderId: '589578730909',
    projectId: 'pinkpapaya-6e06c',
    storageBucket: 'pinkpapaya-6e06c.appspot.com',
    iosBundleId: 'com.ott.pinkpapayaapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqBrfD5X8rjSnIPW7SmsIdQxeKKuKmdSE',
    appId: '1:589578730909:ios:e74641dbc1d2d5b9890374',
    messagingSenderId: '589578730909',
    projectId: 'pinkpapaya-6e06c',
    storageBucket: 'pinkpapaya-6e06c.appspot.com',
    iosBundleId: 'com.ott.pinkpapayaapp',
  );
}
