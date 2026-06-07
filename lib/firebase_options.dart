// IMPORTANT — This file contains placeholder values.
//
// Before running the app, replace this file by executing:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Select your Firebase project when prompted. The generated file will
// populate the correct API keys, app IDs, and project identifiers for
// Android and iOS.
//
// Documentation: https://firebase.flutter.dev/docs/overview#initialization

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Bloom does not support Web. Run `flutterfire configure` to generate '
        'the correct DefaultFirebaseOptions for Android and iOS.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}. Run `flutterfire configure`.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REDACTED_FIREBASE_ANDROID_API_KEY',
    appId: '1:448983161339:android:4d0f370fb0855e088c935e',
    messagingSenderId: '448983161339',
    projectId: 'bloom-371e1',
    storageBucket: 'bloom-371e1.firebasestorage.app',
  );

  // Replace all REPLACE_WITH_* values using `flutterfire configure`.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REDACTED_FIREBASE_IOS_API_KEY',
    appId: '1:448983161339:ios:27b741acbf4a84c38c935e',
    messagingSenderId: '448983161339',
    projectId: 'bloom-371e1',
    storageBucket: 'bloom-371e1.firebasestorage.app',
    iosBundleId: 'com.wony.bloom',
  );

  // Replace all REPLACE_WITH_* values using `flutterfire configure`.
}