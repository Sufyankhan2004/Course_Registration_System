class Registration {
  final String id;
  final String studentId;
  final String courseId;
  final Map<String, dynamic>? course; // joined course
  Registration({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.course,
  });

  factory Registration.fromJson(Map<String, dynamic> j) => Registration(
        id: j['id'],
        studentId: j['student_id'],
        courseId: j['course_id'],
        course: j['courses'] as Map<String, dynamic>?,
      );
}