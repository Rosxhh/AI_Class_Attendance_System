import 'package:flutter/material.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Full Name'),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(hintText: 'Enter student name'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Roll Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'e.g. 101'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Class/Section'),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'e.g. 10-A'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _Label('Parent Name'),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(hintText: 'Enter parent name'),
        ),
        const SizedBox(height: 20),
        const _Label('Parent Phone'),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+1 234 567 890'),
        ),
        const SizedBox(height: 20),
        const _Label('Parent Email'),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'parent@example.com'),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }
}
