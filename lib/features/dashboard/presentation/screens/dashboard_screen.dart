import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/firebase_service/firebase_provider.dart';
import '../../../students/presentation/screens/student_upload_screen.dart';
import '../../../attendance/presentation/screens/attendance_camera_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseService = ref.watch(firebaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => firebaseService.signOut(),
            icon: const Icon(Icons.logout, color: AppTheme.errorColor),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, int>>(
        future: firebaseService.getDashboardStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {'total': 0, 'present': 0, 'absent': 0};
          
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(firebaseServiceProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(stats),
                  const SizedBox(height: 32),
                  const Text('Quick Actions', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(Map<String, int> stats) {
    return Column(
      children: [
        _StatCard(
          title: 'Total Students',
          value: stats['total'].toString(),
          icon: Icons.people_outline,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Present Today',
                value: stats['present'].toString(),
                icon: Icons.check_circle_outline,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Absent Today',
                value: stats['absent'].toString(),
                icon: Icons.cancel_outlined,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          title: 'Upload Students',
          subtitle: 'Add new or bulk upload via Excel',
          icon: Icons.cloud_upload_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentUploadScreen())),
        ),
        _ActionButton(
          title: 'Take Attendance',
          subtitle: 'Scan faces to mark attendance',
          icon: Icons.camera_alt_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceCameraScreen())),
        ),
        _ActionButton(
          title: 'Attendance Reports',
          subtitle: 'View history and exports',
          icon: Icons.analytics_outlined,
          onTap: () {}, // Implementation for reports
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.secondaryColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
