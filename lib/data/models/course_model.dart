class Course {
  final String id;
  final String name;
  final String code;
  final String lecturer;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.lecturer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'lecturer': lecturer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String? ?? '',
      lecturer: map['lecturer'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? lecturer,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      lecturer: lecturer ?? this.lecturer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
