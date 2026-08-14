enum AttendanceStatus { present, absent, pod }

class Student {
  final String rollNo;
  final String name;
  AttendanceStatus status;

  Student(this.rollNo, this.name, {this.status = AttendanceStatus.absent});

  Map<String, dynamic> toMap() =>
      {'rollNo': rollNo, 'name': name, 'status': status.index};

  static Student fromMap(Map map) => Student(
        map['rollNo'],
        map['name'],
        status: AttendanceStatus.values[map['status']],
      );
}