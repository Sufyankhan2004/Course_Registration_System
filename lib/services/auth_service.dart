import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final _c = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role, // 'admin' or 'student'
  }) async {
    final res = await _c.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user != null) {
      await _c.from('profiles').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'role': role,
      });
    }
    return res;
  }

  Future<AuthResponse> signIn(String email, String password) =>
      _c.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _c.auth.signOut();

  Future<Profile?> getProfile(String userId) async {
    final res =
        await _c.from('profiles').select().eq('id', userId).maybeSingle();
    if (res == null) return null;
    return Profile.fromJson(res);
  }
}