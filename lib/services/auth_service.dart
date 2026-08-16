import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/user_model.dart';
import '../models/bmi_record_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseAuth.instance;
      }
    } catch (e) {
      debugPrint('Firebase not initialized: $e');
    }
    return null;
  }

  GoogleSignIn? get _googleSignIn {
    try {
      return GoogleSignIn();
    } catch (e) {
      debugPrint('GoogleSignIn not available: $e');
    }
    return null;
  }

  UserModel? _currentUser;
  List<UserModel> _profiles = [];

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      final profilesJson = prefs.getStringList('user_profiles');
      if (profilesJson != null && profilesJson.isNotEmpty) {
        _profiles = profilesJson.map((p) => UserModel.fromJson(json.decode(p))).toList();
      } else {
        _profiles = _generateDummyProfiles();
      }

      if (isLoggedIn) {
        final currentId = prefs.getString('user_id');
        _currentUser = _profiles.cast<UserModel?>().firstWhere(
          (p) => p?.id == currentId,
          orElse: () => _profiles.isNotEmpty ? _profiles.first : null,
        );
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
      _profiles = _generateDummyProfiles();
    }
  }

  List<UserModel> _generateDummyProfiles() {
    final random = Random(42);

    List<BmiRecord> generateHistory(double startWeight, double endWeight, double heightM) {
      List<BmiRecord> history = [];
      final now = DateTime.now();
      double currentWeight = startWeight;
      final step = (endWeight - startWeight) / 365;

      for (int i = 365; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final noise = (random.nextDouble() - 0.5) * 0.5;
        currentWeight += step + noise;
        final bmi = currentWeight / (heightM * heightM);

        history.add(BmiRecord(
          id: 'record_${date.millisecondsSinceEpoch}',
          bmiValue: double.parse(bmi.toStringAsFixed(1)),
          date: date,
          weight: double.parse(currentWeight.toStringAsFixed(1)),
        ));
      }
      return history.reversed.toList();
    }

    return [
      UserModel(
        id: 'user_1',
        name: 'John Doe',
        email: 'john@example.com',
        height: 175.0,
        weight: 72.0,
        gender: 'Male',
        history: generateHistory(85.0, 72.0, 1.75),
      ),
      UserModel(
        id: 'user_2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        height: 165.0,
        weight: 60.0,
        gender: 'Female',
        history: generateHistory(58.0, 60.0, 1.65),
      ),
      UserModel(
        id: 'user_3',
        name: 'Alex Johnson',
        email: 'alex@example.com',
        height: 180.0,
        weight: 85.0,
        gender: 'Other',
        history: generateHistory(90.0, 85.0, 1.80),
      ),
    ];
  }

  Future<bool> login(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      // Firebase is available — use it as the sole authentication source.
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          var matchedProfile = _profiles.cast<UserModel?>().firstWhere(
            (p) => p?.email.toLowerCase() == email.toLowerCase(),
            orElse: () => null,
          );

          if (matchedProfile == null) {
            matchedProfile = UserModel(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'User',
              email: email,
              height: 170.0,
              weight: 65.0,
              gender: 'Other',
              history: [],
            );
            _profiles.add(matchedProfile);
          }

          _currentUser = matchedProfile;
          await _persistState();
          return true;
        }
      } catch (e) {
        debugPrint('Firebase login error: $e');
        // Firebase explicitly rejected the credentials — do NOT fall through
        // to local matching. Return false so the user sees an error.
        return false;
      }
    }

    // Only reach here if Firebase is completely unavailable (auth == null).
    // In that case, allow local profile matching as a fallback.
    var localProfile = _profiles.cast<UserModel?>().firstWhere(
      (p) => p?.email.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );

    if (localProfile != null) {
      _currentUser = localProfile;
      await _persistState();
      return true;
    }

    return false;
  }

  Future<bool> signInWithGoogle() async {
    final googleSignIn = _googleSignIn;
    final auth = _auth;

    if (googleSignIn != null && auth != null) {
      try {
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return false;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await auth.signInWithCredential(credential);
        User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          var matchedProfile = _profiles.cast<UserModel?>().firstWhere(
            (p) => p?.email == firebaseUser.email,
            orElse: () => null,
          );

          if (matchedProfile == null) {
            matchedProfile = UserModel(
              id: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'Google User',
              email: firebaseUser.email ?? '',
              height: 170.0,
              weight: 65.0,
              gender: 'Other',
              history: [],
            );
            _profiles.add(matchedProfile);
          }

          _currentUser = matchedProfile;
          await _persistState();
          return true;
        }
      } catch (e) {
        debugPrint('Google sign in error: $e');
      }
    }

    final googleUser = UserModel(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Google User',
      email: 'user@gmail.com',
      height: 170.0,
      weight: 68.0,
      gender: 'Other',
      history: [],
    );
    _profiles.add(googleUser);
    _currentUser = googleUser;
    await _persistState();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      try {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          try {
            await firebaseUser.updateDisplayName(name);
          } catch (_) {}

          final newUser = UserModel(
            id: firebaseUser.uid,
            name: name,
            email: email,
            height: 170.0,
            weight: 65.0,
            gender: 'Other',
            history: [],
          );
          _profiles.add(newUser);
          _currentUser = newUser;
          await _persistState();
          return true;
        }
      } catch (e) {
        debugPrint('Registration error: $e');
      }
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      height: 170.0,
      weight: 65.0,
      gender: 'Other',
      history: [],
    );
    _profiles.add(newUser);
    _currentUser = newUser;
    await _persistState();
    return true;
  }

  void switchProfile(String id) {
    if (_profiles.isEmpty) return;
    final profile = _profiles.firstWhere((p) => p.id == id, orElse: () => _currentUser ?? _profiles.first);
    _currentUser = profile;
    _persistState();
  }

  void addProfile(UserModel newProfile) {
    _profiles.add(newProfile);
    _persistState();
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    if (_currentUser?.id == id) {
      if (_profiles.isNotEmpty) {
        _currentUser = _profiles.first;
      } else {
        await logout();
        return;
      }
    }
    await _persistState();
  }

  void updateCurrentUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    final index = _profiles.indexWhere((p) => p.id == updatedUser.id);
    if (index != -1) {
      _profiles[index] = updatedUser;
    }
    _persistState();
  }

  Future<void> _persistState() async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', _currentUser!.id);

      final profilesJson = _profiles.map((p) => json.encode(p.toJson())).toList();
      await prefs.setStringList('user_profiles', profilesJson);
    } catch (e) {
      debugPrint('Persist state error: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_id');
    } catch (_) {}

    try {
      await _auth?.signOut();
    } catch (_) {}
  }

  UserModel? get currentUser => _currentUser;
  List<UserModel> get profiles => _profiles;
}
