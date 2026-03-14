import 'dart:io';
import 'package:excel/excel.dart';
import '../models/student.dart';
import 'package:uuid/uuid.dart';

class BulkImportService {
  Future<List<Student>> importFromExcel(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<Student> students = [];

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]!.rows;
      // Assume first row is header
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.isEmpty) continue;

        students.add(Student(
          id: const Uuid().v4(),
          name: row[0]?.value.toString() ?? '',
          rollNumber: row[1]?.value.toString() ?? '',
          classId: row[2]?.value.toString() ?? '',
          section: row[3]?.value.toString() ?? '',
          parentName: row[4]?.value.toString() ?? '',
          parentPhone: row[5]?.value.toString() ?? '',
          parentEmail: row[6]?.value.toString() ?? '',
        ));
      }
    }
    return students;
  }
}
