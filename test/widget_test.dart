import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_class_attendance_system/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  // Mock Firebase if necessary for tests, 
  // but for a simple smoke test we just check if the App builds.
  
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Note: In a real environment with Firebase, you'd need to mock it.
    // This test might fail if Firebase.initializeApp() is called without a mock.
    
    await tester.pumpWidget(
      const ProviderScope(
        child: AttendanceApp(),
      ),
    );

    // Verify that login screen components are present
    // Based on the generated LoginScreen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
