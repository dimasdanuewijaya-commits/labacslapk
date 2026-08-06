// File generated for Firebase Project: labtrack-pro-b795e
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQZsoHooZZ52N9jYv1pX-zs9sJFLIbKTw',
    appId: '1:14455036485:web:8017ae84cbd27d7cade12c',
    messagingSenderId: '14455036485',
    projectId: 'labtrack-pro-b795e',
    authDomain: 'labtrack-pro-b795e.firebaseapp.com',
    storageBucket: 'labtrack-pro-b795e.firebasestorage.app',
    measurementId: 'G-5SZ8SH0CT6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQZsoHooZZ52N9jYv1pX-zs9sJFLIbKTw',
    appId: '1:14455036485:android:8017ae84cbd27d7cade12c',
    messagingSenderId: '14455036485',
    projectId: 'labtrack-pro-b795e',
    storageBucket: 'labtrack-pro-b795e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQZsoHooZZ52N9jYv1pX-zs9sJFLIbKTw',
    appId: '1:14455036485:ios:88aacf8c29ab9f5cade12c',
    messagingSenderId: '14455036485',
    projectId: 'labtrack-pro-b795e',
    storageBucket: 'labtrack-pro-b795e.firebasestorage.app',
    iosClientId: '14455036485-mr5qqhim0rgtggfnajk13p6ulpb48tk2.apps.googleusercontent.com',
    iosBundleId: 'com.acsl.labtrackPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQZsoHooZZ52N9jYv1pX-zs9sJFLIbKTw',
    appId: '1:14455036485:ios:88aacf8c29ab9f5cade12c',
    messagingSenderId: '14455036485',
    projectId: 'labtrack-pro-b795e',
    storageBucket: 'labtrack-pro-b795e.firebasestorage.app',
    iosClientId: '14455036485-mr5qqhim0rgtggfnajk13p6ulpb48tk2.apps.googleusercontent.com',
    iosBundleId: 'com.acsl.labtrackPro',
  );
}
