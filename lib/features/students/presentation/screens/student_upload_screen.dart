import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/firebase_service/firebase_provider.dart';
import '../../domain/models/student_model.dart';

class StudentUploadScreen extends ConsumerStatefulWidget {
  const StudentUploadScreen({super.key});

  @override
  ConsumerState<StudentUploadScreen> createState() => _StudentUploadScreenState();
}

class _StudentUploadScreenState extends ConsumerState<StudentUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        var bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          // Skip header row
          bool isHeader = true;
          for (var row in excel.tables[table]!.rows) {
            if (isHeader) {
              isHeader = false;
              continue;
            }
            
            // Assuming columns: Name, Roll, StudentID, ParentPhone, ParentEmail
            final student = StudentModel(
              id: const Uuid().v4(),
              name: row[0]?.value.toString() ?? '',
              rollNumber: row[1]?.value.toString() ?? '',
              studentId: row[2]?.value.toString() ?? '',
              parentPhone: row[3]?.value.toString() ?? '',
              parentEmail: row[4]?.value.toString() ?? '',
              profileImageUrl: '', // Needs a photo later
            );
            
            // Note: Excel upload usually lacks photos. 
            // In a real app, you'd handle "missing photo" state.
            // For now, we add them to Firestore.
            await ref.read(firebaseServiceProvider).addStudent(student, File('')); // Placeholder empty file logic or handle differently
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk upload completed')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and capture a photo')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final student = StudentModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        rollNumber: _rollController.text.trim(),
        studentId: _idController.text.trim(),
        parentPhone: _phoneController.text.trim(),
        parentEmail: _emailController.text.trim(),
        profileImageUrl: '', 
      );

      await ref.read(firebaseServiceProvider).addStudent(student, _imageFile!);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student added successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        actions: [
          TextButton.icon(
            onPressed: _pickExcel,
            icon: const Icon(Icons.file_present),
            label: const Text('Bulk Upload'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _imageFile == null 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: AppTheme.primaryColor),
                            SizedBox(height: 8),
                            Text('Capture Face', style: TextStyle(fontSize: 12)),
                          ],
                        ) 
                      : null,
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_rollController, 'Roll Number', Icons.numbers)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_idController, 'Student ID', Icons.badge_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Parent Phone', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Parent Email', Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 40),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Register Student'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
