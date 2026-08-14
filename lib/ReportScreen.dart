import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ksdevs/Screens/AppTheme.dart';
import 'package:ksdevs/Screens/StudentModel.dart';
import 'package:share_plus/share_plus.dart';

// ─────────────────────────────────────────────────────────────────
// REPORT SCREEN
// ─────────────────────────────────────────────────────────────────
class ReportScreen extends StatelessWidget {
  final List<Student> students;
  final String lecture;
  final String date;

  const ReportScreen({
    super.key,
    required this.students,
    required this.lecture,
    required this.date,
  });

  // ───────────────────────────────────────────────────────────────
  // ATTENDANCE LISTS
  // ───────────────────────────────────────────────────────────────

  List<Student> get _present =>
      students.where((s) => s.status == AttendanceStatus.present).toList();

  List<Student> get _pod =>
      students.where((s) => s.status == AttendanceStatus.pod).toList();

  List<Student> get _absent =>
      students.where((s) => s.status == AttendanceStatus.absent).toList();

  // ───────────────────────────────────────────────────────────────
  // PRESENT + POD TEXT
  // ───────────────────────────────────────────────────────────────

  String _presentPodText() {
    String t = "Lecture: $lecture\nDate: $date\n\nPresent:\n";

    for (var s in _present) {
      t += "${s.rollNo}  ${s.name}\n";
    }

    if (_pod.isNotEmpty) {
      t += "\nPOD:\n";

      for (var s in _pod) {
        t += "${s.rollNo}  ${s.name}\n";
      }
    }

    return t;
  }

  // ───────────────────────────────────────────────────────────────
  // ABSENT TEXT
  // ───────────────────────────────────────────────────────────────

  String _absentText() {
    String t = "Lecture: $lecture\nDate: $date\n\nAbsent:\n";

    for (var s in _absent) {
      t += "${s.rollNo}  ${s.name}\n";
    }

    return t;
  }

  // ───────────────────────────────────────────────────────────────
  // COPY + SHARE
  // ───────────────────────────────────────────────────────────────

  Future<void> _copyAndShare(String text) async {
    // Copy data to clipboard
    await Clipboard.setData(
      ClipboardData(text: text),
    );

    // Open system share sheet
    await SharePlus.instance.share(
      ShareParams(
        text: text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = students.length;

    final presentPod = _present.length + _pod.length;

    final pct = total > 0
        ? (presentPod / total * 100).toStringAsFixed(1)
        : "0";

    return Scaffold(
      backgroundColor: AppTheme.bg,

      // ───────────────────────────────────────────────────────────
      // APP BAR
      // ───────────────────────────────────────────────────────────

      appBar: AppBar(
        title: const Text("Attendance Report"),
        centerTitle: true,
      ),

      // ───────────────────────────────────────────────────────────
      // BODY
      // ───────────────────────────────────────────────────────────

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ─────────────────────────────────────────────────────
            // SUMMARY CARD
            // ─────────────────────────────────────────────────────

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    Text(
                      "Lecture $lecture",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _statPill(
                          "Present",
                          _present.length,
                          Colors.green,
                        ),

                        _statPill(
                          "POD",
                          _pod.length,
                          Colors.orange,
                        ),

                        _statPill(
                          "Absent",
                          _absent.length,
                          Colors.red,
                        ),

                        _statPill(
                          "Total",
                          total,
                          AppTheme.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Attendance Progress
                    LinearProgressIndicator(
                      value: total > 0
                          ? presentPod / total
                          : 0,

                      backgroundColor:
                          Colors.red.shade100,

                      color: Colors.green,

                      minHeight: 8,

                      borderRadius:
                          BorderRadius.circular(4),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "$pct% Attendance",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────
            // PRESENT + POD SECTION
            // ─────────────────────────────────────────────────────

            _sectionCard(
              title: "Present & POD",
              count: _present.length + _pod.length,
              color: Colors.green,

              children: [
                ..._present.map(
                  (s) => _studentRow(s),
                ),

                if (_pod.isNotEmpty) ...[
                  const Divider(),

                  ..._pod.map(
                    (s) => _studentRow(
                      s,
                      isPod: true,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────
            // ABSENT SECTION
            // ─────────────────────────────────────────────────────

            _sectionCard(
              title: "Absent",
              count: _absent.length,
              color: Colors.red,

              children: _absent
                  .map(
                    (s) => _studentRow(s),
                  )
                  .toList(),
            ),
          ],
        ),
      ),

      

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Row(
            children: [
              // ─────────────────────────────────────────────────
              // PRESENT + POD BUTTON
              // ─────────────────────────────────────────────────

              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.black,
                  ),

                  label: const Text(
                    "Present + POD",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {
                    _copyAndShare(
                      _presentPodText(),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // ─────────────────────────────────────────────────
              // ABSENT BUTTON
              // ─────────────────────────────────────────────────

              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Absent",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: () {
                    _copyAndShare(
                      _absentText(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // STAT PILL
  // ───────────────────────────────────────────────────────────────

  Widget _statPill(
    String label,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Text(
            value.toString(),

            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SECTION CARD
  // ───────────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required int count,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                CircleAvatar(
                  radius: 14,

                  backgroundColor: color,

                  child: Text(
                    count.toString(),

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...children,
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // STUDENT ROW
  // ───────────────────────────────────────────────────────────────

  Widget _studentRow(
    Student s, {
    bool isPod = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 3,
      ),

      child: Row(
        children: [
          if (isPod)
            const Padding(
              padding: EdgeInsets.only(right: 6),

              child: Icon(
                Icons.work,
                size: 14,
                color: Colors.orange,
              ),
            ),

          Text(
            "${s.rollNo}  ${s.name}",

            style: TextStyle(
              fontSize: 14,

              color: isPod
                  ? Colors.orange
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}