// New file: lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Call this after successful login or registration
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners(); // Notify widgets listening to this provider
  }

  // Call this when updating profile info
  void updateUser({String? name, String? email, String? phone, String? profileImageUrl}) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id, // Keep the original ID
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );
      notifyListeners();
    }
  }

  // Call this on logout
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}