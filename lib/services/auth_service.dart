import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan data user yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // Mendeteksi perubahan status (login/logout) secara realtime
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi Login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi Daftar Akun Baru
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}