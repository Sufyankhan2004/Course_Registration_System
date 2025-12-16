import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../services/registration_service.dart';
import '../../models/course.dart';
import '../../widgets/app_scaffold.dart';

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
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
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  _SectionHeader(title: 'Courses', count: courses.length),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: courses
                        .map((c) => SizedBox(
                              width: 360,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(c.courseCode,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16)),
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () => _openForm(c),
                                                  icon: const Icon(Icons.edit)),
                                              IconButton(
                                                  onPressed: () async {
                                                    await _courseService
                                                        .deleteCourse(c.id);
                                                    _load();
                                                  },
                                                  icon: const Icon(Icons.delete)),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(c.courseName,
                                          style: const TextStyle(fontSize: 15)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _Chip(label: 'Credit: ${c.creditHours}'),
                                          const SizedBox(width: 8),
                                          _Chip(label: 'Sem: ${c.semester}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _SectionHeader(
                      title: 'All Registrations', count: registrations.length),
                  const SizedBox(height: 8),
                  Card(
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
  final _credit = TextEditingController();
  final _semester = TextEditingController();
  final _service = CourseService();
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _code.text = widget.course!.courseCode;
      _name.text = widget.course!.courseName;
      _credit.text = widget.course!.creditHours.toString();
      _semester.text = widget.course!.semester.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;
    return AppScaffold(
      title: isEdit ? 'Edit Course' : 'Add Course',
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
                    TextFormField(
                      controller: _credit,
                      decoration:
                          const InputDecoration(labelText: 'Credit Hours (int)'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          int.tryParse(v ?? '') != null ? null : 'Number required',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _semester,
                      decoration: const InputDecoration(labelText: 'Semester (int)'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          int.tryParse(v ?? '') != null ? null : 'Number required',
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
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final credit = int.parse(_credit.text);
      final sem = int.parse(_semester.text);
      if (widget.course == null) {
        await _service.addCourse(
            code: _code.text, name: _name.text, creditHours: credit, semester: sem);
      } else {
        await _service.updateCourse(
            id: widget.course!.id,
            code: _code.text,
            name: _name.text,
            creditHours: credit,
            semester: sem);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}