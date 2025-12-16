import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_badge.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth > 720;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      if (wide)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Course Registration System'
                                  'by Usama',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Manage courses and registrations with a clean, modern dashboard for Admins and Students.',
                                  style: TextStyle(fontSize: 15, height: 1.4),
                                ),
                                SizedBox(height: 16),
                                RoleBadge(role: 'admin'),
                                SizedBox(height: 8),
                                RoleBadge(role: 'student'),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Text('Welcome Back',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text('Sign in to continue',
                                    style: TextStyle(
                                        color: scheme.onSurfaceVariant)),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _email,
                                  decoration: const InputDecoration(
                                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                                  validator: (v) =>
                                      v != null && v.contains('@') ? null : 'Enter valid email',
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _password,
                                  decoration: const InputDecoration(
                                      labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                                  obscureText: true,
                                  validator: (v) =>
                                      v != null && v.length >= 6 ? null : 'Min 6 characters',
                                ),
                                const SizedBox(height: 14),
                                if (error != null)
                                  Text(error!, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: loading ? null : _submit,
                                    child: loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Text('Login'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushReplacementNamed('/signup'),
                                  child: const Text("Don't have an account? Sign up"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await AuthService().signIn(_email.text.trim(), _password.text.trim());
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}