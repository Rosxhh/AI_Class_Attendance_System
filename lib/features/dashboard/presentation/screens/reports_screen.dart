import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildAttendanceChart(),
            const SizedBox(height: 32),
            _buildReportCard('Weekly Report', 'View attendance trends for the last 7 days', Icons.show_chart),
            _buildReportCard('Monthly Report', 'Detailed monthly attendance breakdown', Icons.calendar_month),
            _buildReportCard('Export Data', 'Download attendance as CSV or Excel', Icons.download),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(color: AppTheme.successColor, value: 75, title: '75%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            PieChartSectionData(color: AppTheme.errorColor, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
