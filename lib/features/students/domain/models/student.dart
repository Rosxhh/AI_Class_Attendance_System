class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String classId;
  final String section;
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final String? profileImageUrl;
  final List<double>? faceEmbedding;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.classId,
    required this.section,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
    this.profileImageUrl,
    this.faceEmbedding,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'classId': classId,
      'section': section,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'profileImageUrl': profileImageUrl,
      'faceEmbedding': faceEmbedding,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      classId: map['classId'] ?? '',
      section: map['section'] ?? '',
      parentName: map['parentName'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      parentEmail: map['parentEmail'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      faceEmbedding: map['faceEmbedding'] != null 
          ? List<double>.from(map['faceEmbedding']) 
          : null,
    );
  }
}
