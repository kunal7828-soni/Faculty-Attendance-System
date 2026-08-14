import 'package:flutter/material.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StrageData.dart';
import 'package:ksdevs/Screens/AttendanceScreen.dart';
import 'package:intl/intl.dart';
import 'package:ksdevs/Screens/manageStudentScreen.dart';

// ─────────────────────────────────────────────────────────────────
//  SECTION DETAIL SCREEN  (students + take attendance)
// ─────────────────────────────────────────────────────────────────
class SectionDetailScreen extends StatelessWidget {
  final String nsKey;
  final String sectionName;
  const SectionDetailScreen(
      {super.key, required this.nsKey, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    final studentKey = sectionStudentKey(nsKey, sectionName);
    return Scaffold(
      appBar: AppBar(title: Text("Section: $sectionName")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            context,
            icon: Icons.people,
            title: "Manage Students",
            subtitle: "Add or remove students in this section",
            color: AppTheme.primary,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ManageStudentsScreen(
                        listKey: studentKey,
                        title: '$sectionName · Students'))),
          ),
          const SizedBox(height: 16),
          _card(
            context,
            icon: Icons.fact_check,
            title: "Take Attendance",
            subtitle: "Mark attendance for a lecture in this section",
            color: AppTheme.green,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AttendanceScreen(
                        studentListKey: studentKey,
                        initialLecture: '1',
                        initialDate: DateFormat('dd MMM yyyy').format(DateTime.now()),
                      ))),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context,
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
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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

