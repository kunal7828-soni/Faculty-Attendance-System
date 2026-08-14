import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/AttendanceScreen.dart';
import 'package:ksdevs/Screens/screenSection.dart';
// ─────────────────────────────────────────────────────────────────
//  FACULTY DASHBOARD
// ─────────────────────────────────────────────────────────────────
class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _dashCard(
            context,
            icon: Icons.fact_check,
            title: "TG Attendance",
            subtitle: "Manage students & mark attendance",
            color: AppTheme.green,
             onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceScreen(
                    studentListKey: 'tgStudents',
                    initialLecture: 'TG',
                    initialDate: dateStr,
                    isTGMode: true,
                    studentTitle: 'Manage TG Students',
                  ),
                ),
              ),
          ),
          const SizedBox(height: 16),
          _dashCard(
            context,
            icon: Icons.menu_book,
            title: "Lecture Attendance",
            subtitle: "Manage sections & take lecture attendance",
            color: Colors.indigo,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SectionsScreen(
                        nsKey: 'lectureAttendance',
                        title: 'Lecture Sections'))),
          ),
        ],
      ),
    );
  }

  Widget _dashCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}