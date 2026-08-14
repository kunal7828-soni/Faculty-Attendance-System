import 'package:flutter/material.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StrageData.dart';
import 'package:ksdevs/Screens/StudentModel.dart';

// ─────────────────────────────────────────────────────────────────
//  MANAGE STUDENTS SCREEN  (Add / Delete / CSV import)
// ─────────────────────────────────────────────────────────────────
class ManageStudentsScreen extends StatefulWidget {
  final String listKey;
  final String title;
  const ManageStudentsScreen(
      {super.key, required this.listKey, required this.title});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  late List<Student> _students;
  bool _deleteMode = false;
  final Set<Student> _selected = {};

  @override
  void initState() {
    super.initState();
    _students = loadStudentList(widget.listKey);
  }

  void _save() {
    saveStudentList(widget.listKey, _students);
    setState(() {});
  }

  // ── Add single student ───────────────────────────────────────
  void _showAddDialog() {
    final rollCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rollCtrl,
              decoration: const InputDecoration(
                  labelText: "Roll Number",
                  prefixIcon: Icon(Icons.confirmation_number)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: "Student Name", prefixIcon: Icon(Icons.person)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final roll = rollCtrl.text.trim();
              final name = nameCtrl.text.trim().toUpperCase();
              if (roll.isNotEmpty && name.isNotEmpty) {
                // Duplicate check
                if (_students.any((s) => s.rollNo == roll)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Roll number already exists")));
                  return;
                }
                setState(() {
                  _students.add(Student(roll, name));
                  _students.sort((a, b) => a.rollNo.compareTo(b.rollNo));
                });
                _save();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ── CSV / Excel-like paste import ────────────────────────────
  void _showCsvImportDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Paste CSV Data"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                "Format: ROLL,NAME (one per line)\n"
                "Example:\n  0537CS241061,Kunal Soni",
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Paste your CSV data here...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final lines = ctrl.text
                  .trim()
                  .split('\n')
                  .where((l) => l.trim().contains(','))
                  .toList();
              int added = 0, skipped = 0;
              for (var line in lines) {
                final parts = line.split(',');
                if (parts.length >= 2) {
                  final roll = parts[0].trim();
                  final name = parts.sublist(1).join(',').trim().toUpperCase();
                  if (roll.isNotEmpty && name.isNotEmpty) {
                    if (_students.any((s) => s.rollNo == roll)) {
                      skipped++;
                    } else {
                      _students.add(Student(roll, name));
                      added++;
                    }
                  }
                }
              }
              _students.sort((a, b) => a.rollNo.compareTo(b.rollNo));
              _save();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "$added students added${skipped > 0 ? ', $skipped duplicates skipped' : ''}")));
            },
            child: const Text("Import"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    if (_selected.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Students"),
        content: Text("Delete ${_selected.length} selected student(s)?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              setState(() {
                _students.removeWhere((s) => _selected.contains(s));
                _selected.clear();
                _deleteMode = false;
              });
              _save();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ── Edit student name ────────────────────────────────────────
  void _showEditDialog(Student s) {
    final nameCtrl = TextEditingController(text: s.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: "Student Name", prefixIcon: Icon(Icons.person)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim().toUpperCase();
              if (newName.isNotEmpty) {
                setState(() {
                  final idx = _students.indexOf(s);
                  _students[idx] = Student(s.rollNo, newName, status: s.status);
                });
                _save();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: "Import CSV",
              onPressed: _showCsvImportDialog),
          IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: "Add Student",
              onPressed: _showAddDialog),
          if (!_deleteMode)
            IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: "Delete Mode",
                onPressed: () => setState(() => _deleteMode = true)),
          if (_deleteMode)
            IconButton(
                icon: const Icon(Icons.check),
                tooltip: "Confirm Delete",
                onPressed: _confirmDelete),
          if (_deleteMode)
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                      _deleteMode = false;
                      _selected.clear();
                    })),
        ],
      ),
      body: _students.isEmpty
          ? const Center(
              child: Text("No students yet.\nAdd manually or import CSV.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)))
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text("Total: ${_students.length} students",
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      if (_deleteMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            "${_selected.length} selected",
                            style: const TextStyle(
                                color: AppTheme.red, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _students.length,
                    itemBuilder: (ctx, i) {
                      final s = _students[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: _deleteMode
                              ? Checkbox(
                                  value: _selected.contains(s),
                                  onChanged: (v) => setState(() =>
                                      v! ? _selected.add(s) : _selected.remove(s)),
                                )
                              : CircleAvatar(
                                  backgroundColor:
                                      AppTheme.accent.withValues(alpha: 0.2),
                                  child: Text(
                                    s.rollNo.length >= 3
                                        ? s.rollNo.substring(
                                            s.rollNo.length - 3)
                                        : s.rollNo,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary),
                                  ),
                                ),
                          title: Text(s.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text("Roll: ${s.rollNo}"),
                          trailing: !_deleteMode
                              ? IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: Colors.grey),
                                  onPressed: () => _showEditDialog(s),
                                )
                              : null,
                          onLongPress: !_deleteMode
                              ? () => setState(() {
                                    _deleteMode = true;
                                    _selected.add(s);
                                  })
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
