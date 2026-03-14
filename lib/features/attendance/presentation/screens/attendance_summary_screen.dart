import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/attendance_model.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  final AttendanceSession session;

  const AttendanceSummaryScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(),
            const SizedBox(height: 32),
            _buildStatGrid(),
            const SizedBox(height: 32),
            const Text('Absent Students', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 16),
            _buildAbsentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(session.timestamp),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                'Started at ${DateFormat('hh:mm a').format(session.timestamp)}',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Total', value: session.totalStudents.toString(), color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Present', value: session.presentCount.toString(), color: AppTheme.successColor)),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(label: 'Absent', value: (session.totalStudents - session.presentCount).toString(), color: AppTheme.errorColor)),
      ],
    );
  }

  Widget _buildAbsentList() {
    if (session.absentStudentIds.isEmpty) {
      return const Center(child: Text('Perfect Attendance! No students absent.'));
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: session.absentStudentIds.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.person_off, color: AppTheme.errorColor),
            title: Text('Student ID: ${session.absentStudentIds[index]}'),
            subtitle: const Text('Marked Absent'),
            trailing: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}
