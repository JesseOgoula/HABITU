import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/habit.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await AuthService.initialize();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());

  // Initialize providers
  final authProvider = AuthProvider();
  final habitProvider = HabitProvider();
  final themeProvider = ThemeProvider();

  await Future.wait([
    authProvider.init(),
    habitProvider.init(),
    themeProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: habitProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const HabituApp(),
    ),
  );
}

class HabituApp extends StatelessWidget {
  const HabituApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'HABITU',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(homeScreen: HomeScreen()),
        );
      },
    );
  }
}
