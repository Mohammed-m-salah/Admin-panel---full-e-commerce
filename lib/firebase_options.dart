import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7FBsLEYAr3zTGHcjm_I-c_hwqarsy9hs',
    appId: '1:287504862160:web:ebce4582ed484a917947d5',
    messagingSenderId: '287504862160',
    projectId: 'testfirbase-1f25a',
    authDomain: 'testfirbase-1f25a.firebaseapp.com',
    storageBucket: 'testfirbase-1f25a.firebasestorage.app',
    measurementId: 'G-NMFGPXJQ6L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA628-vlKQPXtNHoXAd5ggBpJ_lWSjSi2k',
    appId: '1:287504862160:android:7287f8e0e920c1647947d5',
    messagingSenderId: '287504862160',
    projectId: 'testfirbase-1f25a',
    storageBucket: 'testfirbase-1f25a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhe2ng7P9dPZ8c7kybBOQ5LsS3Zk2JtAg',
    appId: '1:287504862160:ios:b10dffc6cdb7a9d97947d5',
    messagingSenderId: '287504862160',
    projectId: 'testfirbase-1f25a',
    storageBucket: 'testfirbase-1f25a.firebasestorage.app',
    iosBundleId: 'com.example.coreDashboard',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhe2ng7P9dPZ8c7kybBOQ5LsS3Zk2JtAg',
    appId: '1:287504862160:ios:b10dffc6cdb7a9d97947d5',
    messagingSenderId: '287504862160',
    projectId: 'testfirbase-1f25a',
    storageBucket: 'testfirbase-1f25a.firebasestorage.app',
    iosBundleId: 'com.example.coreDashboard',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7FBsLEYAr3zTGHcjm_I-c_hwqarsy9hs',
    appId: '1:287504862160:web:ebce4582ed484a917947d5',
    messagingSenderId: '287504862160',
    projectId: 'testfirbase-1f25a',
    authDomain: 'testfirbase-1f25a.firebaseapp.com',
    storageBucket: 'testfirbase-1f25a.firebasestorage.app',
    measurementId: 'G-NMFGPXJQ6L',
  );
}
