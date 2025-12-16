import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registration.dart';

class RegistrationService {
  final _c = Supabase.instance.client;

  Future<List<Registration>> myRegistrations(String studentId) async {
    final data = await _c
        .from('registrations')
        .select('*, courses(*)')
        .eq('student_id', studentId);
    return (data as List).map((e) => Registration.fromJson(e)).toList();
  }

  Future<void> registerCourse({
    required String studentId,
    required String courseId,
  }) async {
    // unique constraint prevents duplicates; catch PostgREST error
    await _c.from('registrations').insert({
      'student_id': studentId,
      'course_id': courseId,
    });
  }

  Future<void> unregister(String registrationId) async {
    await _c.from('registrations').delete().eq('id', registrationId);
  }

  Future<List<Map<String, dynamic>>> allRegistrationsWithUsers() async {
    // For admin dashboard
    final data = await _c
        .from('registrations')
        .select('id, student_id, course_id, courses(*), profiles(name,email,role)');
    return (data as List).cast<Map<String, dynamic>>();
  }
}