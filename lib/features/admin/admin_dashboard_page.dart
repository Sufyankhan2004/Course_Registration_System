import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/registration_service.dart';
import '../../models/course.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/course_card.dart';
import '../../widgets/stat_card.dart';
import '../../core/theme/app_theme.dart';
import 'screens/admin_profile_screen.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _courseService = CourseService();
  final _regService = RegistrationService();
  List<Course> courses = [];
  List<Map<String, dynamic>> registrations = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final c = await _courseService.getAll();
      final r = await _regService.allRegistrationsWithUsers();
      setState(() {
        courses = c;
        registrations = r;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void _openForm([Course? course]) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CourseFormPage(course: course)));
    _load();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Profile',
          onPressed: _openProfile,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await AuthService().signOut();
            if (mounted) Navigator.of(context).pushReplacementNamed('/login');
          },
        )
      ],
      floating: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Courses',
                          value: '${courses.length}',
                          icon: Icons.school,
                          gradient: AppTheme.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Total Registrations',
                          value: '${registrations.length}',
                          icon: Icons.assignment_turned_in,
                          gradient: AppTheme.accentGradient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _SectionHeader(title: 'Courses', count: courses.length),
                  const SizedBox(height: 12),
                  
                  courses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first course using the button below',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(
                              course: course,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _openForm(course),
                                    color: theme.colorScheme.primary,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Course'),
                                          content: Text(
                                            'Are you sure you want to delete ${course.courseName}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _courseService.deleteCourse(course.id);
                                        _load();
                                      }
                                    },
                                    color: theme.colorScheme.error,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                  
                  _SectionHeader(
                      title: 'All Registrations', count: registrations.length),
                  const SizedBox(height: 12),
                  Card(
                    child: registrations.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No registrations yet',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Student')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Course')),
                                DataColumn(label: Text('Code')),
                              ],
                              rows: registrations
                                  .map(
                                    (r) => DataRow(cells: [
                                      DataCell(Text(r['profiles']['name'] ??
                                          r['profiles']['email'] ??
                                          '')),
                                      DataCell(Text(r['profiles']['email'] ?? '')),
                                      DataCell(Text(r['courses']['course_name'] ?? '')),
                                      DataCell(Text(r['courses']['course_code'] ?? '')),
                                    ]),
                                  )
                                  .toList(),
                            ),
                          ),
                  )
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count',
              style:
                  TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
        )
      ],
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

class CourseFormPage extends StatefulWidget {
  final Course? course;
  const CourseFormPage({super.key, this.course});
  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  int _selectedCredit = 3; // Default credit hours
  int _selectedSemester = 1; // Default semester
  final _service = CourseService();
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _code.text = widget.course!.courseCode;
      _name.text = widget.course!.courseName;
      _selectedCredit = widget.course!.creditHours;
      _selectedSemester = widget.course!.semester;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;
    return AppScaffold(
      title: isEdit ? 'Edit Course' : 'Add Course',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _code,
                          decoration: const InputDecoration(labelText: 'Course Code'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Course Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _selectedCredit,
                          decoration: const InputDecoration(labelText: 'Credit Hours'),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1')),
                            DropdownMenuItem(value: 2, child: Text('2')),
                            DropdownMenuItem(value: 3, child: Text('3')),
                            DropdownMenuItem(value: 4, child: Text('4')),
                          ],
                          onChanged: (v) => setState(() => _selectedCredit = v ?? 3),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: _selectedSemester,
                          decoration: const InputDecoration(labelText: 'Semester'),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1')),
                            DropdownMenuItem(value: 2, child: Text('2')),
                            DropdownMenuItem(value: 3, child: Text('3')),
                            DropdownMenuItem(value: 4, child: Text('4')),
                            DropdownMenuItem(value: 5, child: Text('5')),
                            DropdownMenuItem(value: 6, child: Text('6')),
                            DropdownMenuItem(value: 7, child: Text('7')),
                            DropdownMenuItem(value: 8, child: Text('8')),
                          ],
                          onChanged: (v) => setState(() => _selectedSemester = v ?? 1),
                          validator: (v) => v == null ? 'Required' : null,
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
                                : Text(isEdit ? 'Update' : 'Create'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
      if (widget.course == null) {
        await _service.addCourse(
            code: _code.text, name: _name.text, creditHours: _selectedCredit, semester: _selectedSemester);
      } else {
        await _service.updateCourse(
            id: widget.course!.id,
            code: _code.text,
            name: _name.text,
            creditHours: _selectedCredit,
            semester: _selectedSemester);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}