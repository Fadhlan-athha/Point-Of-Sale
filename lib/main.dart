import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 

// Import file-file yang sudah kita buat sebelumnya
import 'providers/cart_provider.dart';
import 'screens/pos_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan mesin Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee POS Cloud',
      
      // -- PENGATURAN TEMA DARK MODE & ORANYE --
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF6F00),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6F00),
          surface: Color(0xFF1E1E1E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6F00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
          ),
        ),
      ),

      // -- PENJAGA PINTU (AUTH WRAPPER) --
      // Mengecek apakah kasir sudah login atau belum
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          // Jika aplikasi sedang loading mengecek status login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator())
            );
          }
          // Jika ada data user (berarti SUDAH LOGIN), arahkan ke menu kasir
          if (snapshot.hasData) {
            return const PosScreen(); 
          }
          // Jika tidak ada data user (berarti BELUM LOGIN), arahkan ke halaman login
          return const LoginScreen(); 
        },
      ),
    );
  }
}