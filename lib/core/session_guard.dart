import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});
  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  Profile? me;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    final profile = await AuthService().getProfile(user.id);
    setState(() {
      me = profile;
      loading = false;
    });
    if (profile == null) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    if (mounted) {
      if (profile.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        Navigator.of(context).pushReplacementNamed('/student');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return widget.child;
  }
}