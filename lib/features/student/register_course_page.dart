import 'package:flutter/material.dart';
import '../../services/registration_service.dart';
import '../../models/course.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterCoursePage extends StatefulWidget {
  final List<Course> courses;
  const RegisterCoursePage({super.key, required this.courses});
  @override
  State<RegisterCoursePage> createState() => _RegisterCoursePageState();
}

class _RegisterCoursePageState extends State<RegisterCoursePage> {
  final _regService = RegistrationService();
  final user = Supabase.instance.client.auth.currentUser;
  bool loading = true;
  String? error;
  List registrations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (user == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final regs = await _regService.myRegistrations(user!.id);
      setState(() => registrations = regs);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  bool _isRegistered(String courseId) {
    return registrations.any((r) => r.courseId == courseId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Register for Courses')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error != null)
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: widget.courses
                              .map((c) {
                                final regd = _isRegistered(c.id);
                                return SizedBox(
                                  width: 340,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${c.courseCode} - ${c.courseName}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              _Chip(label: 'Credit: ${c.creditHours}'),
                                              const SizedBox(width: 8),
                                              _Chip(label: 'Sem: ${c.semester}'),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: regd
                                                ? OutlinedButton.icon(
                                                    onPressed: () async {
                                                      final reg = registrations
                                                          .firstWhere((r) => r.courseId == c.id);
                                                      await _regService.unregister(reg.id);
                                                      _load();
                                                    },
                                                    icon: const Icon(Icons.remove_circle),
                                                    label: const Text('Unregister'),
                                                  )
                                                : ElevatedButton.icon(
                                                    onPressed: () async {
                                                      try {
                                                        await _regService.registerCourse(
                                                            studentId: user!.id,
                                                            courseId: c.id);
                                                        _load();
                                                      } catch (e) {
                                                        setState(() => error = e.toString());
                                                      }
                                                    },
                                                    icon: const Icon(Icons.check),
                                                    label: const Text('Register'),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
    );
  }
}