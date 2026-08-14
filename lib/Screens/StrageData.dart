import 'package:hive_flutter/hive_flutter.dart';
import 'package:ksdevs/Screens/StudentModel.dart';
Box get appBox => Hive.box('appBox');

// ── Attendance helpers ──────────────────────────────────────────
String attendanceKey(String date, String lecture, [String? studentListKey]) {
  if (studentListKey == null || studentListKey.isEmpty) {
    return 'att_${date}_lec$lecture';
  }
  return 'att_${studentListKey}_date_${date}_lec$lecture';
}

void saveAttendance(
    String date, String lecture, List<Student> students, {
    String? studentListKey,
  }) {
  appBox.put(
    attendanceKey(date, lecture, studentListKey),
    students.map((s) => s.toMap()).toList(),
  );
}

void deleteStudentList(String key) {
  appBox.delete(key);
}

List<Student>? loadAttendance(
    String date,
    String lecture, {
    String? studentListKey,
  }) {
  final raw = appBox.get(attendanceKey(date, lecture, studentListKey));
  if (raw == null) return null;
  return (raw as List)
      .map((e) => Student.fromMap(Map.from(e)))
      .toList();
}

List<String> lecturesForDate(String date) {
  final List<String> found = [];
  for (var k in appBox.keys) {
    final s = k.toString();
    if (s.startsWith('att_${date}_lec')) {
      found.add(s.replaceFirst('att_${date}_lec', ''));
    }
  }
  found.sort();
  return found;
}

// ── Student list helpers ─────────────────────────────────────────
List<Student> loadStudentList(String key) {
  final raw = appBox.get(key);
  if (raw == null) return [];
  return (raw as List)
      .map((e) => Student.fromMap(Map.from(e)))
      .toList()
    ..sort((a, b) => a.rollNo.compareTo(b.rollNo));
}

void saveStudentList(String key, List<Student> students) {
  appBox.put(key, students.map((s) => s.toMap()).toList());
}

// ── Section helpers ──────────────────────────────────────────────
/// Sections are stored as a list of section names under a given namespace key.
List<String> loadSections(String nsKey) {
  final raw = appBox.get('sections_$nsKey');
  if (raw == null) return [];
  return List<String>.from(raw);
}

void saveSections(String nsKey, List<String> sections) {
  appBox.put('sections_$nsKey', sections);
}

// ── Student list key per section ────────────────────────────────
String sectionStudentKey(String nsKey, String sectionName) =>
    '${nsKey}_sect_$sectionName';

// ── Delete helper (used by SectionsScreen when deleting a section) ─
void deleteKey(String key) {
  appBox.delete(key);
}