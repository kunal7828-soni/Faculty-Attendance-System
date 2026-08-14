import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ksdevs/ReportScreen.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StrageData.dart';
import 'package:ksdevs/Screens/StudentModel.dart';
import 'package:ksdevs/Screens/manageStudentScreen.dart';

// ─────────────────────────────────────────────────────────────────
//  ATTENDANCE SCREEN
//  Date, lecture and default attendance mode are configured from the
//  Drawer. A saved record is loaded automatically for the selected
//  date + lecture; otherwise the master student list is used.
// ─────────────────────────────────────────────────────────────────
class AttendanceScreen extends StatefulWidget {
  final String studentListKey;
  final String initialLecture;
  final String initialDate;
  final bool isTGMode;
  final String? studentTitle;

  const AttendanceScreen({
    super.key,
    required this.studentListKey,
    required this.initialLecture,
    required this.initialDate,
    this.isTGMode = false,
    this.studentTitle,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Student> students = [];
  bool deleteMode = false;
  final Set<Student> selectedStudents = {};

  late String _selectedDateStr;
  late String _selectedLecture;
  AttendanceStatus _currentMode = AttendanceStatus.absent;

  @override
  void initState() {
    super.initState();
    _selectedDateStr = widget.initialDate;
    _selectedLecture = widget.isTGMode ? 'TG' : widget.initialLecture;
    _loadStudentsForCurrentConfig();
  }

  // Summary counts
  int get _presentCount =>
      students.where((s) => s.status == AttendanceStatus.present).length;
  int get _podCount =>
      students.where((s) => s.status == AttendanceStatus.pod).length;
  int get _absentCount =>
      students.where((s) => s.status == AttendanceStatus.absent).length;

  void _loadStudentsForCurrentConfig() {
    final saved = loadAttendance(
      _selectedDateStr,
      _selectedLecture,
      studentListKey: widget.studentListKey,
    );
    final master = loadStudentList(widget.studentListKey);

    setState(() {
      deleteMode = false;
      selectedStudents.clear();

      // The section/TG master list is the source of truth for which
      // students belong to this attendance session. Saved attendance
      // only supplies the status of students that are still in that list.
      final savedByRoll = <String, Student>{
        if (saved != null)
          for (final student in saved) student.rollNo: student,
      };

      students = master.map((masterStudent) {
        final savedStudent = savedByRoll[masterStudent.rollNo];
        return Student(
          masterStudent.rollNo,
          masterStudent.name,
          status: savedStudent?.status ?? _currentMode,
        );
      }).toList();
    });
  }

  void _syncStudentsWithMaster() {
    final master = loadStudentList(widget.studentListKey);
    final currentByRoll = <String, Student>{
      for (final student in students) student.rollNo: student,
    };

    setState(() {
      students = master.map((masterStudent) {
        final current = currentByRoll[masterStudent.rollNo];
        return Student(
          masterStudent.rollNo,
          masterStudent.name,
          status: current?.status ?? _currentMode,
        );
      }).toList();
      selectedStudents.clear();
      deleteMode = false;
    });
  }

  Future<void> _openManageStudents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageStudentsScreen(
          listKey: widget.studentListKey,
          title: widget.studentTitle ??
              (widget.isTGMode ? 'TG Students' : 'Manage Students'),
        ),
      ),
    );
    if (mounted) {
      _syncStudentsWithMaster();
    }
  }

  Future<void> _pickDate() async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd MMM yyyy').parse(_selectedDateStr);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    final newDate = DateFormat('dd MMM yyyy').format(picked);
    if (newDate == _selectedDateStr) return;

    setState(() => _selectedDateStr = newDate);
    _loadStudentsForCurrentConfig();
  }

  void _changeLecture(String lecture) {
    if (_selectedLecture == lecture) return;

    setState(() => _selectedLecture = lecture);
    _loadStudentsForCurrentConfig();
  }

  void _changeAttendanceMode(AttendanceStatus newMode) {
    if (_currentMode == newMode) return;

    final hasChanges = students.any((s) => s.status != _currentMode);

    if (hasChanges) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Change Mode?"),
          content: const Text(
              "Changing the mode will reset all student marks to the default of the new mode. Proceed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentMode = newMode;
                  for (final student in students) {
                    student.status = newMode;
                  }
                });
                Navigator.pop(context);
                Navigator.pop(context); // Close drawer after applying mode.
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _currentMode = newMode;
        for (final student in students) {
          student.status = newMode;
        }
      });
    }
  }

  Widget _modeButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? color : Colors.grey.shade500, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? color : Colors.black87,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? color.withValues(alpha: 0.8)
                            : Colors.grey.shade600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Attendance Configuration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1A3F51B5),
                  child: Icon(Icons.people_alt_outlined, color: AppTheme.primary),
                ),
                title: Text(
                  widget.studentTitle ?? (widget.isTGMode ? 'Manage TG Students' : 'Manage Students'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Add, edit or remove students from the master list'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openManageStudents,
              ),
            ),
            const Text('Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_selectedDateStr,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Lecture',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            if (widget.isTGMode)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.08),
                  border: Border.all(
                      color: AppTheme.green.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.groups, color: AppTheme.green),
                    SizedBox(width: 10),
                    Text('TG Attendance',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedLecture,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const ['1', '2', '3', '4', '5', '6']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text('Lecture $e'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _changeLecture(value);
                },
              ),
            const SizedBox(height: 22),
            const Text('Default Status Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            _modeButton(
              title: 'Absent',
              subtitle: 'All Absent',
              icon: Icons.cancel,
              color: AppTheme.red,
              isSelected: _currentMode == AttendanceStatus.absent,
              onTap: () =>
                  _changeAttendanceMode(AttendanceStatus.absent),
            ),
            const SizedBox(height: 10),
            _modeButton(
              title: 'Present',
              subtitle: 'All Present',
              icon: Icons.check_circle,
              color: AppTheme.green,
              isSelected: _currentMode == AttendanceStatus.present,
              onTap: () =>
                  _changeAttendanceMode(AttendanceStatus.present),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final rollCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(
                    labelText: "Roll Number",
                    prefixIcon: Icon(Icons.confirmation_number))),
            const SizedBox(height: 12),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: "Student Name",
                    prefixIcon: Icon(Icons.person))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (rollCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                final roll = rollCtrl.text.trim();
                final name = nameCtrl.text.trim().toUpperCase();

                final master = loadStudentList(widget.studentListKey);
                if (master.any((s) => s.rollNo == roll)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Roll number already exists")),
                  );
                  return;
                }

                master.add(Student(roll, name));
                saveStudentList(widget.studentListKey, master);
                Navigator.pop(context);
                _syncStudentsWithMaster();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete() {
    if (selectedStudents.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Students"),
        content: Text("Delete ${selectedStudents.length} selected student(s)?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              final master = loadStudentList(widget.studentListKey);
              final selectedRolls =
                  selectedStudents.map((s) => s.rollNo).toSet();

              master.removeWhere((s) => selectedRolls.contains(s.rollNo));
              saveStudentList(widget.studentListKey, master);

              setState(() {
                students.removeWhere((s) => selectedRolls.contains(s.rollNo));
                selectedStudents.clear();
                deleteMode = false;
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(widget.isTGMode ? 'TG Attendance' : 'Attendance'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            color: AppTheme.primary.withValues(alpha: 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryChip(Icons.check_circle, "$_presentCount P", Colors.green),
                _summaryChip(Icons.work, "$_podCount POD", Colors.orange),
                _summaryChip(Icons.cancel, "$_absentCount A", Colors.red),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Add Student",
            onPressed: _showAddStudentDialog,
          ),
          if (!deleteMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete Mode",
              onPressed: () => setState(() {
                deleteMode = true;
                selectedStudents.clear();
              }),
            ),
          if (deleteMode)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: "Delete Selected",
              onPressed: _confirmBulkDelete,
            ),
          if (deleteMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: "Cancel Delete",
              onPressed: () => setState(() {
                deleteMode = false;
                selectedStudents.clear();
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          // Read-only current configuration bar.
          Builder(
            builder: (barContext) => Material(
              elevation: 2,
              color: Colors.white,
              child: InkWell(
                onTap: () => Scaffold.of(barContext).openDrawer(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_selectedDateStr  •  ${widget.isTGMode ? 'TG Attendance' : 'Lecture $_selectedLecture'}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.edit, size: 18, color: Colors.grey),
                  ],
                ),
                ),
              ),
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Student'),
                      onPressed: _openManageStudents,
                    ),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final shortRoll = student.rollNo.length >= 3
                          ? student.rollNo.substring(student.rollNo.length - 3)
                          : student.rollNo;

                      Color color;
                      String text;
                      IconData icon;
                      switch (student.status) {
                        case AttendanceStatus.present:
                          color = Colors.green;
                          text = "P";
                          icon = Icons.check_circle;
                          break;
                        case AttendanceStatus.pod:
                          color = Colors.orange;
                          text = "POD";
                          icon = Icons.work;
                          break;
                        default:
                          color = Colors.red;
                          text = "A";
                          icon = Icons.cancel;
                      }

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Row(
                            children: [
                              if (deleteMode)
                                Checkbox(
                                  value: selectedStudents.contains(student),
                                  onChanged: (v) => setState(() => v!
                                      ? selectedStudents.add(student)
                                      : selectedStudents.remove(student)),
                                ),
                              Container(
                                width: 45,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(shortRoll,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(student.name,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  minimumSize: const Size(90, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: Icon(icon, color: Colors.white),
                                label: Text(text,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  if (deleteMode) return;
                                  setState(() {
                                    if (student.status ==
                                        AttendanceStatus.absent) {
                                      student.status = AttendanceStatus.present;
                                    } else if (student.status ==
                                        AttendanceStatus.present) {
                                      student.status = AttendanceStatus.pod;
                                    } else {
                                      student.status = AttendanceStatus.absent;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.done),
        label: const Text("Done"),
        backgroundColor: AppTheme.green,
        onPressed: () {
          saveAttendance(_selectedDateStr, _selectedLecture, students, studentListKey: widget.studentListKey);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportScreen(
                students: students,
                lecture: _selectedLecture,
                date: _selectedDateStr,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
