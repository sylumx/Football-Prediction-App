import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/predictions_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/prediction_analytics_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Predictions',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: Typography.material2018().white.copyWith(
              bodyLarge: TextStyle(color: Colors.grey[800]),
              bodyMedium: TextStyle(color: Colors.grey[800]),
              titleLarge: const TextStyle(color: Colors.indigo),
              titleMedium: const TextStyle(color: Colors.indigo),
              titleSmall: const TextStyle(color: Colors.indigo),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            textStyle: const TextStyle(fontSize: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[300],
          thickness: 1,
          space: 24,
        ),
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
          secondary: Colors.indigoAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return authProvider.isLoggedIn
              ? const PredictionsListScreen()
              : const LoginScreen();
        },
      ),
      routes: {
        '/predictions': (context) => const PredictionsListScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/prediction_analytics': (context) => const PredictionAnalyticsScreen(),
      },
    );
  }
}
