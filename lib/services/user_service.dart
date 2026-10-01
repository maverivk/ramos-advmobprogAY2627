import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LoginType { firebase, dummyJson, none }

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  LoginType _loginType = LoginType.none;
  LoginType get loginType => _loginType;

  Map<String, dynamic>? _dummyUserData;

  // --- FIREBASE AUTH ---
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _loginType = LoginType.firebase;
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    _loginType = LoginType.firebase;
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (_loginType == LoginType.firebase) {
      await firebaseAuth.signOut();
    }
    _loginType = LoginType.none;
    _dummyUserData = null;
  }

  Future<void> updateUsername({required String username}) async {
    if (_loginType == LoginType.firebase) {
      await currentUser!.updateDisplayName(username);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'username': username});
    } else if (_loginType == LoginType.dummyJson && _dummyUserData != null) {
      _dummyUserData!['username'] = username;
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final uid = currentUser!.uid;
    await currentUser!.reauthenticateWithCredential(credential);
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await currentUser!.delete();
    await firebaseAuth.signOut();
    _loginType = LoginType.none;
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  // --- DUMMYJSON AUTH ---
  Future<bool> dummyJsonLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        _dummyUserData = jsonDecode(response.body);
        _loginType = LoginType.dummyJson;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('DummyJSON Login Error: $e');
      return false;
    }
  }

  // --- GET USER DATA ---
  Future<Map<String, dynamic>?> getUserData() async {
    // DummyJSON
    if (_loginType == LoginType.dummyJson && _dummyUserData != null) {
      return _dummyUserData;
    }

    // Firebase — fetch from Firestore
    if (_loginType == LoginType.firebase && currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['uid'] = data['uid'] ?? currentUser!.uid; // ensure uid
          return data;
        }
      } catch (e) {
        debugPrint('Error fetching user from Firestore: $e');
      }

      // Fallback
      return {
        'uid': currentUser!.uid,
        'firstName': currentUser!.displayName?.split(' ').first ?? 'User',
        'lastName': currentUser!.displayName?.split(' ').last ?? '',
        'email': currentUser!.email ?? 'N/A',
        'username': currentUser!.displayName ?? 'User',
        'age': 'N/A',
        'contactNo': 'N/A',
      };
    }

    return null;
  }
}