import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init();
  runApp(const MyApp());
}