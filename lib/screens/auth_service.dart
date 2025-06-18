import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'email_sender.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final CollectionReference otpCollection = _firestore.collection('otps');
  static const int otpExpiryMinutes = 5;

  // ✅ Check if username and email are available
  static Future<bool> checkUsernameAndEmailAvailable(String username, String email) async {
    final emailExists = await _firestore.collection('users').where('email_id', isEqualTo: email).get();
    final usernameExists = await _firestore.collection('users').where('username', isEqualTo: username).get();
    return emailExists.docs.isEmpty && usernameExists.docs.isEmpty;
  }

  // ✅ Send OTP to user's email
  static Future<bool> sendOtpToEmail(String email) async {
    final otp = (100000 + Random().nextInt(900000)).toString();
    final expirationTime = DateTime.now().add(const Duration(minutes: otpExpiryMinutes));

    try {
      await otpCollection.doc(email).set({
        'otp': otp,
        'expirationTime': expirationTime,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final emailSent = await EmailSender.sendOtpEmail(
        recipientEmail: email,
        otpCode: otp,
        otpExpiryMinutes: otpExpiryMinutes,
      );

      if (!emailSent) {
        await otpCollection.doc(email).delete();
        return false;
      }

      return true;
    } catch (e) {
      try {
        await otpCollection.doc(email).delete();
      } catch (_) {}
      return false;
    }
  }

  // ✅ Verify OTP
  static Future<bool> verifyOtp(String email, String enteredOtp) async {
    try {
      final otpDoc = await otpCollection.doc(email).get();
      if (!otpDoc.exists) return false;

      final storedOtp = otpDoc['otp'] as String;
      final expirationTime = (otpDoc['expirationTime'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expirationTime)) {
        await otpCollection.doc(email).delete();
        return false;
      }

      if (storedOtp != enteredOtp) return false;

      await otpCollection.doc(email).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ✅ Register user
  static Future<void> registerUser(String username, String email, String password) async {
  try {
    // 1. Create user using Firebase Authentication
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // 2. Create user document in Firestore with all desired fields
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'bio': '', // initially empty
      'profileImageUrl': '', // initially empty
      'createdAt': FieldValue.serverTimestamp(),
      'logoutAt': '', // will be updated on logout
      'favouriteRecipes': [], // empty list to start with
    });

    // ignore: avoid_print
    print("User registered and Firestore data created.");
   const SnackBar(
      content: Text("User registered successfully!",style: TextStyle(color: Colors.white),),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Email already in use.',
      );
    }
    rethrow;
  } catch (e) {
    rethrow;
  }
}


  // ✅ Login
  static Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      try {
        await otpCollection.doc(email).delete();
      } catch (_) {}
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ✅ Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ✅ Send Password Reset
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // ✅ Confirm Password Reset
  static Future<bool> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}
