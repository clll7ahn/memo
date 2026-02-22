import 'enums.dart';

/// 폴더 데이터 모델
class Folder {
  /// 고유 식별자 (UUID)
  final String id;

  /// 폴더 이름 (최대 50자)
  final String name;

  /// 폴더 색상
  final MemoColor color;

  /// 정렬 순서
  final int sortOrder;

  /// 기본 폴더 여부 (삭제 불가)
  final bool isDefault;

  /// 생성 일시
  final DateTime createdAt;

  /// 수정 일시
  final DateTime updatedAt;

  const Folder({
    required this.id,
    required this.name,
    this.color = MemoColor.blue,
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로부터 Folder 생성
  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      color: (json['color'] as String? ?? 'blue').toMemoColor(),
      sortOrder: json['sortOrder'] as int? ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Folder를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'sortOrder': sortOrder,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 일부 필드를 변경한 새 인스턴스 반환
  Folder copyWith({
    String? id,
    String? name,
    MemoColor? color,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Folder &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.sortOrder == sortOrder &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder, isDefault);

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, color: $color, isDefault: $isDefault)';
  }
}
