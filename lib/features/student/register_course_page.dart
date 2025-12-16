import 'package:flutter/material.dart';
import '../../services/registration_service.dart';
import '../../models/course.dart';
import '../../widgets/course_card.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Courses'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.secondary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${registrations.length} Registered',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error!,
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        'Available Courses',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select courses to register or unregister',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: widget.courses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 64,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses available',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                ),
                                itemCount: widget.courses.length,
                                itemBuilder: (context, index) {
                                  final course = widget.courses[index];
                                  final isRegistered = _isRegistered(course.id);
                                  
                                  return Stack(
                                    children: [
                                      CourseCard(
                                        course: course,
                                        trailing: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isRegistered)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(
                                                      Icons.check_circle,
                                                      size: 14,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Registered',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        left: 12,
                                        child: isRegistered
                                            ? OutlinedButton.icon(
                                                onPressed: () async {
                                                  final reg = registrations.firstWhere(
                                                      (r) => r.courseId == course.id);
                                                  await _regService.unregister(reg.id);
                                                  _load();
                                                },
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18,
                                                ),
                                                label: const Text('Unregister'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: colorScheme.error,
                                                  side: BorderSide(
                                                    color: colorScheme.error,
                                                  ),
                                                ),
                                              )
                                            : ElevatedButton.icon(
                                                onPressed: () async {
                                                  try {
                                                    await _regService.registerCourse(
                                                      studentId: user!.id,
                                                      courseId: course.id,
                                                    );
                                                    _load();
                                                  } catch (e) {
                                                    setState(() => error = e.toString());
                                                  }
                                                },
                                                icon: const Icon(Icons.add, size: 18),
                                                label: const Text('Register'),
                                              ),
                                      ),
                                    ],
                                  );
                                },
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