// File generated for Firebase initialization.
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
    apiKey: 'AIzaSyDgNPaGgX6L4f7f3kaKgXDSz800qY6VVRQ',
    appId: '1:524694824239:android:897cdc00c102e007ff6dda',
    messagingSenderId: '524694824239',
    projectId: 'scrola-111',
    storageBucket: 'scrola-111.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgNPaGgX6L4f7f3kaKgXDSz800qY6VVRQ',
    appId: '1:524694824239:web:897cdc00c102e007ff6dda',
    messagingSenderId: '524694824239',
    projectId: 'scrola-111',
    storageBucket: 'scrola-111.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgNPaGgX6L4f7f3kaKgXDSz800qY6VVRQ',
    appId: '1:524694824239:ios:897cdc00c102e007ff6dda',
    messagingSenderId: '524694824239',
    projectId: 'scrola-111',
    storageBucket: 'scrola-111.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgNPaGgX6L4f7f3kaKgXDSz800qY6VVRQ',
    appId: '1:524694824239:ios:897cdc00c102e007ff6dda',
    messagingSenderId: '524694824239',
    projectId: 'scrola-111',
    storageBucket: 'scrola-111.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgNPaGgX6L4f7f3kaKgXDSz800qY6VVRQ',
    appId: '1:524694824239:web:897cdc00c102e007ff6dda',
    messagingSenderId: '524694824239',
    projectId: 'scrola-111',
    storageBucket: 'scrola-111.firebasestorage.app',
  );
}
