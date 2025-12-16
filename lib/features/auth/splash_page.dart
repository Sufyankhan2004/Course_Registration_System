import 'package:flutter/material.dart';
import '../../core/session_guard.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SessionGuard(child: SizedBox.shrink()),
    );
  }
}