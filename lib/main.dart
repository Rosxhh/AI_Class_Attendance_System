import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/students/presentation/screens/student_list_screen.dart';
import 'features/attendance/presentation/screens/attendance_history_screen.dart';
import 'features/dashboard/presentation/screens/reports_screen.dart';
import 'services/firebase_service/firebase_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: AttendanceApp(),
    ),
  );
}

class AttendanceApp extends ConsumerWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'AI Smart Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user != null) return const MainNavigationWrapper();
          return const LoginScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const Scaffold(body: Center(child: Text('Error initializing app'))),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentListScreen(),
    const AttendanceHistoryScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(Icons.person_outline, 'Profile Settings'),
          _buildSettingsTile(Icons.notifications_none, 'Notification Prefs'),
          _buildSettingsTile(Icons.security, 'Security & Privacy'),
          _buildSettingsTile(Icons.help_outline, 'Help & Support'),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Logout', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
            onTap: () => ProviderScope.containerOf(context).read(firebaseServiceProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
