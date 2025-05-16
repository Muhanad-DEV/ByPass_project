import 'dart:async';
import 'dart:math';

// Mock Firebase model classes
class MockUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
  });
}

class MockUserCredential {
  final MockUser user;
  
  MockUserCredential({required this.user});
}

class MockDatabaseReference {
  final String key;
  final Map<String, dynamic> _data;
  final MockFirebaseDatabase _database;
  
  MockDatabaseReference(this._database, this.key, [Map<String, dynamic>? initialData]) 
    : _data = initialData ?? {};
  
  MockDatabaseReference child(String path) {
    final newKey = key == '' ? path : '$key/$path';
    return MockDatabaseReference(_database, newKey, _database._getDataAt(newKey));
  }
  
  MockDatabaseReference push() {
    final randomKey = Random().nextInt(10000000).toString();
    return child(randomKey);
  }
  
  Future<void> set(Map<String, dynamic> data) async {
    _database._setDataAt(key, data);
    _database._notifyListeners(key, data);
    return Future.delayed(Duration(milliseconds: 200));
  }
  
  Future<void> update(Map<String, dynamic> data) async {
    final currentData = _database._getDataAt(key) ?? {};
    currentData.addAll(data);
    _database._setDataAt(key, currentData);
    _database._notifyListeners(key, currentData);
    return Future.delayed(Duration(milliseconds: 200));
  }
  
  Stream<MockEvent> get onValue => _database._getStreamFor(key);
}

class MockEvent {
  final MockDataSnapshot snapshot;
  
  MockEvent(this.snapshot);
}

class MockDataSnapshot {
  final dynamic value;
  final String key;
  
  MockDataSnapshot(this.key, this.value);
}

// Mock Firebase Auth
class MockFirebaseAuth {
  static final MockFirebaseAuth _instance = MockFirebaseAuth._();
  static MockFirebaseAuth get instance => _instance;
  
  MockUser? _currentUser;
  final _users = <String, Map<String, dynamic>>{
    'user@example.com': {
      'password': 'password123',
      'uid': 'user-uid-123',
      'displayName': 'Test User',
      'phoneNumber': '+123456789',
    },
    // Added test user for easy testing
    'test@test.com': {
      'password': 'test123',
      'uid': 'test-uid-123',
      'displayName': 'Test Account',
      'phoneNumber': '+9876543210',
    }
  };
  
  MockFirebaseAuth._();
  
  MockUser? get currentUser => _currentUser;
  
  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    final userInfo = _users[email];
    if (userInfo == null || userInfo['password'] != password) {
      throw Exception('Invalid email or password');
    }
    
    _currentUser = MockUser(
      uid: userInfo['uid'],
      email: email,
      phoneNumber: userInfo['phoneNumber'],
      displayName: userInfo['displayName'],
    );
    
    return MockUserCredential(user: _currentUser!);
  }
  
  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw Exception('Email already in use');
    }
    
    final uid = 'user-${DateTime.now().millisecondsSinceEpoch}';
    _users[email] = {
      'password': password,
      'uid': uid,
      'displayName': email.split('@').first,
      'phoneNumber': null,
    };
    
    _currentUser = MockUser(
      uid: uid,
      email: email,
      phoneNumber: null,
      displayName: email.split('@').first,
    );
    
    return MockUserCredential(user: _currentUser!);
  }
  
  Future<void> signOut() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }
}

// Mock Firebase Database
class MockFirebaseDatabase {
  static final MockFirebaseDatabase _instance = MockFirebaseDatabase._();
  static MockFirebaseDatabase get instance => _instance;
  
  final Map<String, Map<String, dynamic>> _data = {};
  final Map<String, StreamController<MockEvent>> _controllers = {};
  
  MockFirebaseDatabase._() {
    // Initialize with some mock data
    _data['orders'] = {
      'ord-001': {
        'customer': 'John Doe',
        'pickup': 'Al Khuwair, Muscat',
        'dropoff': 'Qurum Beach, Muscat',
        'status': 'Pending',
        'amount': '3.500 OMR',
        'distance': '5.2 km',
        'time': '15 min',
      },
      'ord-002': {
        'customer': 'Jane Smith',
        'pickup': 'Muttrah Corniche',
        'dropoff': 'Grand Mall, Muscat',
        'status': 'In Progress',
        'amount': '4.250 OMR',
        'distance': '8.3 km',
        'time': '22 min',
      },
    };
    
    _data['users'] = {
      'user-uid-123': {
        'name': 'Test User',
        'email': 'user@example.com',
        'phone': '+123456789',
        'userType': 'client',
      },
      'test-uid-123': {
        'name': 'Test Account',
        'email': 'test@test.com',
        'phone': '+9876543210',
        'userType': 'driver',
      },
    };
  }
  
  MockDatabaseReference ref([String path = '']) {
    return MockDatabaseReference(this, path);
  }
  
  Map<String, dynamic>? _getDataAt(String path) {
    if (path.isEmpty) return null;
    
    final parts = path.split('/');
    if (parts.length == 1) {
      return _data[parts[0]] as Map<String, dynamic>?;
    }
    
    final rootData = _data[parts[0]];
    if (rootData == null) return null;
    
    if (parts.length == 2) {
      return rootData[parts[1]] as Map<String, dynamic>?;
    }
    
    // This is a simplification, a real implementation would handle deeper paths
    return null;
  }
  
  void _setDataAt(String path, Map<String, dynamic> value) {
    if (path.isEmpty) return;
    
    final parts = path.split('/');
    if (parts.length == 1) {
      _data[parts[0]] = value;
      return;
    }
    
    if (!_data.containsKey(parts[0])) {
      _data[parts[0]] = {};
    }
    
    if (parts.length == 2) {
      _data[parts[0]]![parts[1]] = value;
      return;
    }
    
    // This is a simplification, a real implementation would handle deeper paths
  }
  
  Stream<MockEvent> _getStreamFor(String path) {
    if (!_controllers.containsKey(path)) {
      _controllers[path] = StreamController<MockEvent>.broadcast();
      
      // If there's data, emit it immediately
      final data = _getDataAt(path);
      if (data != null) {
        _controllers[path]!.add(MockEvent(MockDataSnapshot(path, data)));
      } else if (path.contains('/')) {
        // If it's a collection path, construct response
        final parts = path.split('/');
        if (parts.length >= 1 && _data.containsKey(parts[0])) {
          final collectionData = _data[parts[0]]!;
          _controllers[path]!.add(MockEvent(MockDataSnapshot(path, collectionData)));
        }
      }
    }
    
    return _controllers[path]!.stream;
  }
  
  void _notifyListeners(String path, dynamic data) {
    if (_controllers.containsKey(path)) {
      _controllers[path]!.add(MockEvent(MockDataSnapshot(path, data)));
    }
    
    // Also notify parent paths
    final parts = path.split('/');
    if (parts.length > 1) {
      final parentPath = parts.take(parts.length - 1).join('/');
      if (_controllers.containsKey(parentPath)) {
        // We need to reconstruct parent data
        final parentData = _getDataAt(parentPath);
        if (parentData != null) {
          _controllers[parentPath]!.add(MockEvent(MockDataSnapshot(parentPath, parentData)));
        }
      }
    }
  }
}

// Main Firebase mock class
class MockFirebase {
  static final auth = MockFirebaseAuth.instance;
  static final database = MockFirebaseDatabase.instance;
  
  static Future<void> initializeApp({dynamic options}) async {
    // Simulate initialization delay
    await Future.delayed(Duration(milliseconds: 500));
    print('Mock Firebase initialized successfully');
  }
} 