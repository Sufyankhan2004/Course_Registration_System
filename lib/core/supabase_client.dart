import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static final SupabaseClient client = Supabase.instance.client;

  
  static Future<void> init() async {
  const supabaseUrl = 'https://wftwgjueaummssyqkcmc.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdHdnanVlYXVtbXNzeXFrY21jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4MDkyMTIsImV4cCI6MjA4MTM4NTIxMn0.AQ5x3O9sljTDEDZd9dgQEC1ATkhaWREBBDCg2XHxDnE';

  await Supabase. initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}
   
}
/*flutter run -d chrome `
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://wftwgjueaummssyqkcmc.supabase.co `
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdHdnanVlYXVtbXNzeXFrY21jIiwicm9sZSI6ImFub" */

