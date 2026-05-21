import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_flat/features/auth/gate/auth_gate.dart';
import 'infrastructure/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Flat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF7C3AED),
          // deep purple
          onPrimary: Colors.white,

          secondary: Color(0xFF22D3EE),
          // cyan accent
          onSecondary: Colors.black,

          tertiary: Color(0xFFFB7185),

          // soft pink accent
          surface: Color(0xFFF8FAFC),
          // very light gray-blue
          onSurface: Color(0xFF0F172A),

          // dark slate
          error: Color(0xFFEF4444),

          onError: Colors.white,

          outline: Color(0xFFE2E8F0),
          shadow: Color(0x1A000000),
        ),

        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        ),

        scaffoldBackgroundColor: const Color(0xFFF1F5F9),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          foregroundColor: Colors.black,
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}
