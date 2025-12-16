class Course {
  final String id;
  final String courseCode;
  final String courseName;
  final int creditHours;
  final int semester;

  Course({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.semester,
  });

  factory Course.fromJson(Map<String, dynamic> j) => Course(
        id: j['id'],
        courseCode: j['course_code'],
        courseName: j['course_name'],
        creditHours: j['credit_hours'],
        semester: j['semester'],
      );
}