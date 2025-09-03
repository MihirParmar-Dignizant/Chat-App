import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  SignInService({
    FirebaseAuth? firebaseAuth,
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> signInWithEmail(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.clear();

      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("userEmail", user.email ?? "");
      await prefs.setString("userId", user.uid);

      final fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _firestore.collection("users").doc(user.uid).update({
          "fcmToken": fcmToken,
        });
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        await _firestore.collection("users").doc(user.uid).update({
          "fcmToken": newToken,
        });
      });
    }
  }

  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).update({
        "fcmToken": FieldValue.delete(), // remove token on logout
      });
    }

    await _firebaseAuth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }
}
