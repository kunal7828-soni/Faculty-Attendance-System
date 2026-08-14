import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/facultyDashboard.dart';


// ─────────────────────────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appBox');
  runApp(const AttendanceApp());
}



// ─────────────────────────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────────────────────────
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CR Attendance ERP',
      theme: AppTheme.theme,
      home: const RootRouter(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  ROOT ROUTER  — checks setup & session
// ─────────────────────────────────────────────────────────────────
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return const FacultyDashboard();
  }
}



