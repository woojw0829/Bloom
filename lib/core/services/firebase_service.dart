import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Future.wait([
      _configureFirestore(),
      _configureCrashlytics(),
      _configureAnalytics(),
    ]);
  }

  static Future<void> _configureFirestore() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static Future<void> _configureCrashlytics() async {
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  static Future<void> _configureAnalytics() async {
    if (kReleaseMode) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    }
  }
}
