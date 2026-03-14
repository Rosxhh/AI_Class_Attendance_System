import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSession {
  final String id;
  final DateTime timestamp;
  final int totalStudents;
  final int presentCount;
  final List<String> presentStudentIds;
  final List<String> absentStudentIds;

  AttendanceSession({
    required this.id,
    required this.timestamp,
    required this.totalStudents,
    required this.presentCount,
    required this.presentStudentIds,
    required this.absentStudentIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'presentStudentIds': presentStudentIds,
      'absentStudentIds': absentStudentIds,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      totalStudents: map['totalStudents'] ?? 0,
      presentCount: map['presentCount'] ?? 0,
      presentStudentIds: List<String>.from(map['presentStudentIds'] ?? []),
      absentStudentIds: List<String>.from(map['absentStudentIds'] ?? []),
    );
  }
}
