import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StrageData.dart';
import 'package:ksdevs/Screens/AttendanceScreen.dart';

// ─────────────────────────────────────────────────────────────────
//  TG DATE PICK SCREEN  (date only, no lecture dropdown)
// ─────────────────────────────────────────────────────────────────
class TGDatePickScreen extends StatefulWidget {
  const TGDatePickScreen({super.key});
  @override
  State<TGDatePickScreen> createState() => _TGDatePickScreenState();
}

class _TGDatePickScreenState extends State<TGDatePickScreen> {
  late DateTime _selectedDate;
  bool _isPastDate = false;
  bool _hasPastRecord = false;

  // Fixed lecture key "TG" for TG attendance (no lecture concept)
  static const _lec = 'TG';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _checkDate();
  }

  void _checkDate() {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final sel = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
    _isPastDate = sel.isBefore(today);
    if (_isPastDate) {
      final dateStr = DateFormat("dd MMM yyyy").format(_selectedDate);
      _hasPastRecord = loadAttendance(dateStr, _lec) != null;
    } else {
      _hasPastRecord = false;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _checkDate();
      });
    }
  }

  void _proceed() {
    final dateStr = DateFormat("dd MMM yyyy").format(_selectedDate);
    final students = loadStudentList('tgStudents');
    final saved = loadAttendance(dateStr, _lec);

    if (saved == null && students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No students found. Please add students first.")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          studentListKey: 'tgStudents',
          initialLecture: _lec,
          initialDate: dateStr,
          isTGMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat("dd MMM yyyy").format(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text("TG Attendance")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon header
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.green.withValues(alpha: 0.12),
                    child: const Icon(Icons.calendar_month,
                        size: 36, color: AppTheme.green),
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Date",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Pick a date to mark or view attendance",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 28),

                  // Date picker row
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(dateStr,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const Icon(Icons.edit, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),

                  // Info banners
                  if (_isPastDate && !_hasPastRecord)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "No attendance recorded for this date.",
                                style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_isPastDate && _hasPastRecord)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Past date: viewing existing attendance.",
                                style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(_isPastDate
                          ? Icons.visibility
                          : Icons.play_arrow),
                      label: Text(
                        _isPastDate
                            ? "VIEW ATTENDANCE"
                            : "START ATTENDANCE",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _proceed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}