import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class CourseService {
  final _c = Supabase.instance.client;

  Future<List<Course>> getAll() async {
    final data = await _c.from('courses').select().order('course_code');
    return (data as List).map((e) => Course.fromJson(e)).toList();
  }

  Future<void> addCourse({
    required String code,
    required String name,
    required int creditHours,
    required int semester,
  }) async {
    await _c.from('courses').insert({
      'course_code': code,
      'course_name': name,
      'credit_hours': creditHours,
      'semester': semester,
    });
  }

  Future<void> updateCourse({
    required String id,
    required String code,
    required String name,
    required int creditHours,
    required int semester,
  }) async {
    await _c.from('courses').update({
      'course_code': code,
      'course_name': name,
      'credit_hours': creditHours,
      'semester': semester,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteCourse(String id) async {
    await _c.from('courses').delete().eq('id', id);
  }
}