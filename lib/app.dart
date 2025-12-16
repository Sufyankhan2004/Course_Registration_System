import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/auth/splash_page.dart';
import 'features/admin/admin_dashboard_page.dart';
import 'features/student/student_dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Registration System by Usama Zafar',
      theme: AppTheme.lightTheme(),
      home: const SplashPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/admin': (_) => const AdminDashboardPage(),
        '/student': (_) => const StudentDashboardPage(),
      },
    );
  }
}