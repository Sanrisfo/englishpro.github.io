/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Configuration for EnglishPro
class FirebaseConfig {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkDNaHizZ_Pb8a-4WpvNbv4a1qFwN0_Wc',
    appId: '1:103693190371:android:08acb9c7b38c74957d71d6',
    messagingSenderId: '103693190371',
    projectId: 'englishpro-137f6',
    storageBucket: 'englishpro-137f6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkDNaHizZ_Pb8a-4WpvNbv4a1qFwN0_Wc',
    appId: '1:103693190371:ios:PLACEHOLDER',
    messagingSenderId: '103693190371',
    projectId: 'englishpro-137f6',
    storageBucket: 'englishpro-137f6.firebasestorage.app',
    iosBundleId: 'com.englishpro.englishproApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCkDNaHizZ_Pb8a-4WpvNbv4a1qFwN0_Wc',
    appId: '1:103693190371:web:0ea39c7606cfecbf7d71d6',
    messagingSenderId: '103693190371',
    projectId: 'englishpro-137f6',
    authDomain: 'englishpro-137f6.firebaseapp.com',
    storageBucket: 'englishpro-137f6.firebasestorage.app',
  );

  /// Get Firebase options based on current platform
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Initialize Firebase
  static Future<void> initialize() async {
    // Check if Firebase is already initialized
    try {
      await Firebase.initializeApp(
        options: currentPlatform,
      );
    } catch (e) {
      // Firebase already initialized, ignore error
      if (e.toString().contains('duplicate-app')) {
        // App already initialized, this is fine
        return;
      }
      // Re-throw other errors
      rethrow;
    }
  }
}*/
