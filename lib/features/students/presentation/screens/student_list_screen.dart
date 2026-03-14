import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/firebase_service/firebase_provider.dart';
import '../../domain/models/student_model.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StudentModel>>(
              stream: ref.watch(firebaseServiceProvider).getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final students = snapshot.data ?? [];
                final filteredStudents = students.where((s) => 
                  s.name.toLowerCase().contains(_searchQuery) || 
                  s.rollNumber.toLowerCase().contains(_searchQuery)
                ).toList();

                if (filteredStudents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No students found', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _StudentCard(student: student);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: student.profileImageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person)),
            errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person)),
          ),
        ),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Roll: ${student.rollNumber} | ID: ${student.studentId}'),
            Text('Parent: ${student.parentPhone}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // View detailed profile
        },
      ),
    );
  }
}
