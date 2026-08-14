import 'package:flutter/material.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StrageData.dart';
import 'package:intl/intl.dart';
import 'package:ksdevs/Screens/AttendanceScreen.dart';
// ─────────────────────────────────────────────────────────────────
//  SECTIONS SCREEN  (add/delete/navigate sections)
// ─────────────────────────────────────────────────────────────────
class SectionsScreen extends StatefulWidget {
  final String nsKey;
  final String title;
  const SectionsScreen({super.key, required this.nsKey, required this.title});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  late List<String> _sections;

  @override
  void initState() {
    super.initState();
    _sections = loadSections(widget.nsKey);
  }

  void _addSection() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Section"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: "Section Name",
            hintText: "e.g. CSE-A, IT-B",
            prefixIcon: Icon(Icons.label_outline),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim().toUpperCase();
              if (name.isNotEmpty && !_sections.contains(name)) {
                setState(() => _sections.add(name));
                saveSections(widget.nsKey, _sections);
                Navigator.pop(context);
              } else if (_sections.contains(name)) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Section already exists")));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deleteSection(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Section"),
        content: Text("Delete section '$name' and all its students?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              setState(() => _sections.remove(name));
              saveSections(widget.nsKey, _sections);
              // Remove student list for this section
              deleteStudentList(
                sectionStudentKey(widget.nsKey, name),
              );
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
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Section",
            onPressed: _addSection,
          ),
        ],
      ),
      body: _sections.isEmpty
          ? const Center(
              child: Text("No sections yet.\nTap + to add a section.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _sections.length,
              itemBuilder: (ctx, i) {
                final sec = _sections[i];
                final studentKey = sectionStudentKey(widget.nsKey, sec);
                final count = loadStudentList(studentKey).length;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withValues(alpha: 0.15),
                      child: const Icon(Icons.layers, color: Colors.indigo),
                    ),
                    title: Text(sec,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$count students"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_right),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.red),
                          onPressed: () => _deleteSection(sec),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AttendanceScreen(
                                  studentListKey: studentKey,
                                  initialLecture: '1',
                                  initialDate: DateFormat('dd MMM yyyy').format(DateTime.now()),
                                  studentTitle: '$sec · Students',
                                ))),
                  ),
                );
              },
            ),
    );
  }
}

