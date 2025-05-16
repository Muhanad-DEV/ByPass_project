import 'package:flutter/foundation.dart';
import 'mock_firebase_service.dart';

// Flag to determine if we should use mock services - always true since we don't have real Firebase
const bool USE_MOCK = true;

// Authentication service interface
abstract class AuthService {
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  User? get currentUser;
}

// Database service interface
abstract class DatabaseService {
  DatabaseReference ref(String path);
}

// User model to abstract away Firebase or mock implementation details
class User {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;

  User({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
  });
}

// UserCredential model to abstract away implementation details
class UserCredential {
  final User user;

  UserCredential({required this.user});
}

// DatabaseReference model for consistent interface
class DatabaseReference {
  final dynamic _ref; // Can be Firebase or Mock reference

  DatabaseReference(this._ref);

  // Add key property
  String? get key {
    if (_ref is MockDatabaseReference) {
      return (_ref as MockDatabaseReference).key;
    }
    return null;
  }

  DatabaseReference child(String path) {
    if (_ref is MockDatabaseReference) {
      return DatabaseReference((_ref as MockDatabaseReference).child(path));
    }
    throw UnimplementedError('Unsupported reference type');
  }

  DatabaseReference push() {
    if (_ref is MockDatabaseReference) {
      return DatabaseReference((_ref as MockDatabaseReference).push());
    }
    throw UnimplementedError('Unsupported reference type');
  }

  Future<void> set(Map<String, dynamic> data) {
    if (_ref is MockDatabaseReference) {
      return (_ref as MockDatabaseReference).set(data);
    }
    throw UnimplementedError('Unsupported reference type');
  }

  Future<void> update(Map<String, dynamic> data) {
    if (_ref is MockDatabaseReference) {
      return (_ref as MockDatabaseReference).update(data);
    }
    throw UnimplementedError('Unsupported reference type');
  }

  Stream<Event> get onValue {
    if (_ref is MockDatabaseReference) {
      return (_ref as MockDatabaseReference)
          .onValue
          .map((event) => Event(DataSnapshot(event.snapshot)));
    }
    throw UnimplementedError('Unsupported reference type');
  }
}

// Event and DataSnapshot classes to abstract implementation details
class Event {
  final DataSnapshot snapshot;

  Event(this.snapshot);
}

class DataSnapshot {
  final dynamic _snapshot; // Can be Firebase or mock snapshot

  DataSnapshot(this._snapshot);

  dynamic get value {
    if (_snapshot is MockDataSnapshot) {
      return (_snapshot as MockDataSnapshot).value;
    }
    return null;
  }

  String? get key {
    if (_snapshot is MockDataSnapshot) {
      return (_snapshot as MockDataSnapshot).key;
    }
    return null;
  }
}

// Mock implementation
class MockAuthService implements AuthService {
  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final result = await MockFirebase.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserCredential(
      user: User(
        uid: result.user.uid,
        email: result.user.email,
        phoneNumber: result.user.phoneNumber,
        displayName: result.user.displayName,
      ),
    );
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    final result = await MockFirebase.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserCredential(
      user: User(
        uid: result.user.uid,
        email: result.user.email,
        phoneNumber: result.user.phoneNumber,
        displayName: result.user.displayName,
      ),
    );
  }

  @override
  Future<void> signOut() {
    return MockFirebase.auth.signOut();
  }

  @override
  User? get currentUser {
    final user = MockFirebase.auth.currentUser;
    if (user == null) return null;
    return User(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
    );
  }
}

class MockDatabaseService implements DatabaseService {
  @override
  DatabaseReference ref(String path) {
    return DatabaseReference(MockFirebase.database.ref(path));
  }
}

// Service locator for easy access to our services
class FirebaseServiceLocator {
  static final FirebaseServiceLocator _instance = FirebaseServiceLocator._();
  static FirebaseServiceLocator get instance => _instance;

  late final AuthService auth;
  late final DatabaseService database;
  bool _initialized = false;

  FirebaseServiceLocator._();

  Future<void> initialize() async {
    if (_initialized) return;

    // Always use mock implementation
    await MockFirebase.initializeApp();
    auth = MockAuthService();
    database = MockDatabaseService();

    _initialized = true;
  }
} 