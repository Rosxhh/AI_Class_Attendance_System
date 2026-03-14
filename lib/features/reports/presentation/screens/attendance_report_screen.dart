import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/attendance_chart.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedClass = 'Grade 10-A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 32),
            Text('Attendance Trends', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: AttendanceChart(),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detailed Records', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClass,
                isExpanded: true,
                items: ['Grade 10-A', 'Grade 10-B', 'Grade 11-A']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedClass = v!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('Student Name ${index + 1}'),
            subtitle: Text('Roll No: ${100 + index}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: index % 4 == 0 ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                index % 4 == 0 ? 'ABSENT' : 'PRESENT',
                style: TextStyle(
                  color: index % 4 == 0 ? AppColors.error : AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
