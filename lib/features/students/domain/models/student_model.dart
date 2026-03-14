import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  final String studentId;
  final String parentPhone;
  final String parentEmail;
  final String profileImageUrl;
  final List<double>? faceEmbedding; // For AI matching

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.studentId,
    required this.parentPhone,
    required this.parentEmail,
    required this.profileImageUrl,
    this.faceEmbedding,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'studentId': studentId,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'profileImageUrl': profileImageUrl,
      'faceEmbedding': faceEmbedding,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      studentId: map['studentId'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      parentEmail: map['parentEmail'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      faceEmbedding: map['faceEmbedding'] != null 
          ? List<double>.from(map['faceEmbedding']) 
          : null,
    );
  }
}
