import 'package:flutter/material.dart';
import 'views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Cấu hình màu sắc theo FigmaUI.txt
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7), // Primary
          primary: const Color(0xFF0284C7),
          surface: const Color(0xFFF8FAFC), // Background
          error: const Color(0xFFEF4444), // Danger
          onSurface: const Color(0xFF0F172A), // Text Dark
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        
        // Cấu hình font và style chung
        fontFamily: 'Inter', // Hoặc font bạn đã cài đặt
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // bo góc xl
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}
