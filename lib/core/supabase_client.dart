import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    const supabaseUrl = String.fromEnvironment('https://wftwgjueaummssyqkcmc.supabase.co');
    const supabaseAnonKey = String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdHdnanVlYXVtbXNzeXFrY21jIiwicm9sZSI6ImFub');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase credentials. Provide them with --dart-define=SUPABASE_URL=... '
        'and --dart-define=SUPABASE_ANON_KEY=... when starting the app.',
      );
    }

    if (kDebugMode) {
      debugPrint('Connecting to Supabase project: $supabaseUrl');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
/*flutter run -d chrome `
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://wftwgjueaummssyqkcmc.supabase.co `
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdHdnanVlYXVtbXNzeXFrY21jIiwicm9sZSI6ImFub" */