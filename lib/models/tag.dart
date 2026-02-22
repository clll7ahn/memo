import 'enums.dart';

/// 태그 데이터 모델
class Tag {
  /// 고유 식별자 (UUID)
  final String id;

  /// 태그 이름 (최대 30자)
  final String name;

  /// 태그 색상
  final MemoColor color;

  /// 생성 일시
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.color = MemoColor.blue,
    required this.createdAt,
  });

  /// JSON으로부터 Tag 생성
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: (json['color'] as String? ?? 'blue').toMemoColor(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Tag를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 일부 필드를 변경한 새 인스턴스 반환
  Tag copyWith({
    String? id,
    String? name,
    MemoColor? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, name, color);

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color)';
  }
}
