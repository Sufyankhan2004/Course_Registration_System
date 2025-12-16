class Profile {
  final String id;
  final String? name;
  final String? email;
  final String role;
  Profile({required this.id, this.name, this.email, required this.role});

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        name: j['name'] as String?,
        email: j['email'] as String?,
        role: j['role'] as String,
      );
}