import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_flat/core/navigation/app_router.dart';
import 'package:smart_flat/features/auth/providers/auth_provider.dart';
import 'package:smart_flat/features/shopping_item/providers/shopping_item_provider.dart';
import 'package:smart_flat/features/task/providers/task_provider.dart';
import 'package:smart_flat/features/user_profile/providers/user_profile_provider.dart';
import 'features/living_space/providers/living_space_provider.dart';
import 'infrastructure/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (_) => UserProfileProvider(),
          update: (_, auth, profile) => profile!..update(auth.currentUser?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LivingSpaceProvider>(
          create: (_) => LivingSpaceProvider(),
          update: (_, auth, space) => space!..update(auth.currentUser?.uid),
        ),
        ChangeNotifierProxyProvider<LivingSpaceProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, space, task) => task!..update(space.activeSpaceId),
        ),
        ChangeNotifierProxyProvider<LivingSpaceProvider, ShoppingItemProvider>(
          create: (_) => ShoppingItemProvider(),
          update: (_, space, task) => task!..update(space.activeSpaceId),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = AppRouter.createRouter(context);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Flat',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF7C3AED),
          onPrimary: Colors.white,
          secondary: Color(0xFF22D3EE),
          onSecondary: Colors.black,
          tertiary: Color(0xFFFB7185),
          surface: Color(0xFFF8FAFC),
          onSurface: Color(0xFF0F172A),
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
    );
  }
}
