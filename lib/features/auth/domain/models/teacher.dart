class Teacher {
  final String id;
  final String name;
  final String email;
  final String schoolId;
  final List<String> classIds;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.schoolId,
    required this.classIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'schoolId': schoolId,
      'classIds': classIds,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      schoolId: map['schoolId'] ?? '',
      classIds: List<String>.from(map['classIds'] ?? []),
    );
  }
}
