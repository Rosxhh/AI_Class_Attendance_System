import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String section;
  final DateTime date;
  final bool isPresent;
  final String? markedBy;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.section,
    required this.date,
    required this.isPresent,
    this.markedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'section': section,
      'date': Timestamp.fromDate(date),
      'isPresent': isPresent,
      'markedBy': markedBy,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      classId: map['classId'] ?? '',
      section: map['section'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isPresent: map['isPresent'] ?? false,
      markedBy: map['markedBy'],
    );
  }
}
