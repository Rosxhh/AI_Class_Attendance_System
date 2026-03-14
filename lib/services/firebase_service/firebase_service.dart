import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/students/domain/models/student_model.dart';
import '../../features/attendance/domain/models/attendance_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Students
  Future<void> addStudent(StudentModel student, File imageFile) async {
    // 1. Upload Image
    final ref = _storage.ref().child('students/${student.studentId}.jpg');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    // 2. Save to Firestore
    final studentData = student.toMap();
    studentData['profileImageUrl'] = imageUrl;
    
    await _firestore.collection('students').doc(student.id).set(studentData);
  }

  Stream<List<StudentModel>> getStudents() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudentModel.fromMap(doc.data())).toList();
    });
  }

  // Attendance
  Future<void> saveAttendanceSession(AttendanceSession session) async {
    await _firestore.collection('attendance_history').doc(session.id).set(session.toMap());
  }

  Stream<List<AttendanceSession>> getAttendanceHistory() {
    return _firestore
        .collection('attendance_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AttendanceSession.fromMap(doc.data())).toList();
    });
  }

  Future<Map<String, int>> getDashboardStats() async {
    final studentsQuery = await _firestore.collection('students').get();
    final totalStudents = studentsQuery.docs.length;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final attendanceQuery = await _firestore
        .collection('attendance_history')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    int presentToday = 0;
    if (attendanceQuery.docs.isNotEmpty) {
      // Logic for present today (most recent session or sum of unique presents)
      // For simplicity, take the last session's present count
      presentToday = attendanceQuery.docs.last.data()['presentCount'] ?? 0;
    }

    return {
      'total': totalStudents,
      'present': presentToday,
      'absent': totalStudents - presentToday,
    };
  }
}
