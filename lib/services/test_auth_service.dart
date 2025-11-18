// lib/services/test_auth_service.dart (Simplified MockUser)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // We often need this for colors/themes etc.

// We will use a function to return an object that only implements the absolute
// bare minimum properties needed by Firestore and the app for testing.
// This avoids all the complex abstract method overriding errors.

class MockUser implements User {
  @override
  final String uid;

  MockUser(this.uid);

  // We are ONLY implementing the 'uid' getter, which is all we need for Firestore.
  // All other methods/getters return null, throw an error, or are stubs.
  // This bypasses the complex override errors.

  @override
  // Stub out all other required abstract members
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }

  // Provide basic required getters to satisfy the compiler
  @override String get displayName => 'Test User';
  @override String get email => 'test@youmii.com';
  @override bool get emailVerified => true;
  @override bool get isAnonymous => false;
  @override List<UserInfo> get providerData => [];
}

class TestAuthService {
  static User? get currentUser {
    // Return a MockUser for testing when no real user is logged in
    return MockUser('TEST_USER_ID_12345');
  }
}