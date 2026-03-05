import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggle antara Login dan Daftar

  void _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong!"), backgroundColor: Colors.red)
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (_isLoginMode) {
        // Proses Login
        await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        // Proses Daftar Baru
        await _authService.signUp(_emailController.text.trim(), _passwordController.text.trim());
      }
      // Jika sukses, main.dart otomatis memindahkan Anda ke PosScreen
    } catch (e) {
      // --- LOGIKA TERJEMAHAN ERROR FIREBASE ---
      String pesanError = "Terjadi kesalahan.";
      String errorAwal = e.toString().toLowerCase();

      if (errorAwal.contains('invalid-credential') || errorAwal.contains('user-not-found') || errorAwal.contains('wrong-password')) {
        pesanError = "Email atau Password salah! (Atau akun belum didaftarkan)";
      } else if (errorAwal.contains('email-already-in-use')) {
        pesanError = "Email ini sudah terdaftar. Silakan ganti ke mode Login.";
      } else if (errorAwal.contains('weak-password')) {
        pesanError = "Password terlalu lemah. Harus minimal 6 karakter.";
      } else if (errorAwal.contains('invalid-email')) {
        pesanError = "Format email salah. Gunakan @ dan .com (contoh: kasir@toko.com)";
      } else if (errorAwal.contains('network-request-failed')) {
        pesanError = "Koneksi internet terputus. Pastikan device online.";
      } else {
        pesanError = e.toString(); // Munculkan error asli jika tidak dikenali
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesanError), backgroundColor: Colors.red, duration: const Duration(seconds: 4))
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.coffee_maker, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                _isLoginMode ? "Login Kasir" : "Daftar Akun", 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(_isLoginMode ? "MASUK" : "DAFTAR", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                child: Text(
                  _isLoginMode ? "Belum punya akun? Daftar di sini" : "Sudah punya akun? Login di sini",
                  style: const TextStyle(color: Colors.orange),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}