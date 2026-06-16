import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'views/login_screen.dart';
import 'views/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình kích thước cửa sổ cho Desktop (Windows/macOS/Linux)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(390, 844), // Kích thước tương đương iPhone 13/14
      minimumSize: Size(390, 844), // Không thể thu nhỏ hơn
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: "MedAlert",
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
          error: AppColors.danger,
          onSurface: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        
        // Cấu hình font và style chung
        fontFamily: 'Inter', // Hoặc font bạn đã cài đặt
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
          fillColor: AppColors.cardWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}
