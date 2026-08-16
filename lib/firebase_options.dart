import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDY8cqu7C1g5nSo59SMCBhe2x1eDfUI5r4',
    appId: '1:388920600244:android:81c5356fec2dac742099e1',
    messagingSenderId: '388920600244',
    projectId: 'bmirfff',
    storageBucket: 'bmirfff.firebasestorage.app',
  );
}
