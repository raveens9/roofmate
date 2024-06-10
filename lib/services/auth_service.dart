import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;

  User? get user => _user;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChangesStreamListener);
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    _user = _firebaseAuth.currentUser;
    if (_user != null) {
      print("Current user UID: ${_user!.uid}");
    } else {
      print("No user is currently signed in.");
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _user = credential.user;
        print("Signed in: ${_user!.uid}");
        return true;
      }
    } catch (e) {
      print("Error signing in: $e");
    }
    return false;
  }

  Future<bool> signup(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _user = credential.user;
        print("Signed up: ${_user!.uid}");
        return true;
      } else {
        print('User registration failed: User object is null');
        return false;
      }
    } catch (e) {
      print('User registration failed: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      print("Signed out");
      return true;
    } catch (e) {
      print("Error signing out: $e");
    }
    return false;
  }

  void authStateChangesStreamListener(User? user) {
    if (user != null) {
      _user = user;
      print("AuthService: User UID updated: ${user.uid}");
    } else {
      _user = null;
      print("AuthService: No user signed in");
    }
  }
}
