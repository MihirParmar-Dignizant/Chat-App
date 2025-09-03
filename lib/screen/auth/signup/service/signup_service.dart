import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  SignUpService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> signUp({
    required String fullName,
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw Exception("Password do not match.");
    }

    final existingUsername =
        await _firestore
            .collection('users')
            .where('userName', isEqualTo: userName)
            .get();

    if (existingUsername.docs.isNotEmpty) {
      throw Exception("Username is already taken.");
    }

    final existingEmail =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (existingEmail.docs.isNotEmpty) {
      throw Exception('Email is already taken.');
    }

    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception("User creation failed.");
    }

    final fcmToken = await _messaging.getToken();

    await _firestore.collection('users').doc(user.uid).set({
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'createdAt': DateTime.now(),
      'fcmToken': fcmToken,
    });
  }
}
