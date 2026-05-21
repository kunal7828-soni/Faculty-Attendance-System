// This is a basic Flutter widget test for the CR Attendance ERP app.
// It verifies that the app starts with the SetupScreen when no credentials exist.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ksdevs/main.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // Initialize Hive in a temporary directory for the test environment
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('appBox');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App starts with FacultyDashboard when launched', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AttendanceApp());
    await tester.pumpAndSettle();

    // Verify that the Faculty Dashboard screen is displayed.
    expect(find.text('Faculty Dashboard'), findsOneWidget);
    expect(find.text('TG Attendance'), findsOneWidget);
    expect(find.text('Lecture Attendance'), findsOneWidget);
  });
}
