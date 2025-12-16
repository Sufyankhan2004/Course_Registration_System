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
  String? errorMessage;

  void _redirect(String route) {
    if (!mounted) return;
    Future<void>.delayed(Duration.zero, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage = null;
        });
        _redirect('/login');
        return;
      }

      final profile = await AuthService().getProfile(user.id);
      if (!mounted) return;

      setState(() {
        me = profile;
        loading = false;
        errorMessage = null;
      });

      if (profile == null) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) _redirect('/login');
        return;
      }

      if (profile.role == 'admin') {
        _redirect('/admin');
      } else {
        _redirect('/student');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load session\n$errorMessage', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                  errorMessage = null;
                });
                _load();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return widget.child;
  }
}