/// 체크리스트 항목 모델
class ChecklistItem {
  /// 고유 식별자 (UUID)
  final String id;

  /// 항목 텍스트
  final String text;

  /// 체크 여부
  final bool isChecked;

  /// 정렬 순서
  final int sortOrder;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
    required this.sortOrder,
  });

  /// JSON으로부터 ChecklistItem 생성
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// ChecklistItem을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isChecked': isChecked,
      'sortOrder': sortOrder,
    };
  }

  /// 일부 필드를 변경한 새 인스턴스 반환
  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isChecked,
    int? sortOrder,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItem &&
        other.id == id &&
        other.text == text &&
        other.isChecked == isChecked &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode => Object.hash(id, text, isChecked, sortOrder);

  @override
  String toString() {
    return 'ChecklistItem(id: $id, text: $text, isChecked: $isChecked, sortOrder: $sortOrder)';
  }
}
