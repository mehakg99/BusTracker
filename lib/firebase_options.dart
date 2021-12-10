// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpdqxl5Swf6wtRGncTxD2RKK-tp8hrL5c',
    appId: '1:375720614595:android:be0c40215a9100fce7e076',
    messagingSenderId: '375720614595',
    projectId: 'bustracker-5fa9d',
    databaseURL: 'https://bustracker-5fa9d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bustracker-5fa9d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALPRCJEz2odMz_tfu0F0whKDMzqJsAiNc',
    appId: '1:375720614595:ios:3e7f74703ca8ec41e7e076',
    messagingSenderId: '375720614595',
    projectId: 'bustracker-5fa9d',
    databaseURL: 'https://bustracker-5fa9d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bustracker-5fa9d.appspot.com',
    iosClientId: '375720614595-jtm0hdq657q95kd706c9polctcmostio.apps.googleusercontent.com',
    iosBundleId: 'com.misp.app',
  );
}
