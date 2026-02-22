import 'checklist_item.dart';
import 'enums.dart';

/// 메모 데이터 모델
class Memo {
  /// 고유 식별자 (UUID)
  final String id;

  /// 제목 (최대 100자)
  final String title;

  /// 내용 (마크다운, 최대 50,000자)
  final String content;

  /// 메모 색상
  final MemoColor color;

  /// 폴더 ID (null = 전체)
  final String? folderId;

  /// 태그 ID 목록
  final List<String> tagIds;

  /// 고정(핀) 여부
  final bool isPinned;

  /// 즐겨찾기 여부
  final bool isFavorite;

  /// 시작 날짜
  final DateTime? startDate;

  /// 종료 날짜
  final DateTime? endDate;

  /// 알림 일시
  final DateTime? reminderAt;

  /// 반복 알림 설정
  final ReminderRepeat reminderRepeat;

  /// 알림 메시지 (null이면 제목 사용)
  final String? reminderMessage;

  /// 체크리스트 항목 목록
  final List<ChecklistItem> checklist;

  /// 소프트 삭제 여부
  final bool isDeleted;

  /// 삭제 일시
  final DateTime? deletedAt;

  /// 생성 일시
  final DateTime createdAt;

  /// 수정 일시
  final DateTime updatedAt;

  const Memo({
    required this.id,
    this.title = '',
    this.content = '',
    this.color = MemoColor.white,
    this.folderId,
    this.tagIds = const [],
    this.isPinned = false,
    this.isFavorite = false,
    this.startDate,
    this.endDate,
    this.reminderAt,
    this.reminderRepeat = ReminderRepeat.none,
    this.reminderMessage,
    this.checklist = const [],
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로부터 Memo 생성
  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      color: (json['color'] as String? ?? 'white').toMemoColor(),
      folderId: json['folderId'] as String?,
      tagIds: (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPinned: json['isPinned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      reminderAt: json['reminderAt'] != null
          ? DateTime.parse(json['reminderAt'] as String)
          : null,
      reminderRepeat:
          (json['reminderRepeat'] as String? ?? 'none').toReminderRepeat(),
      reminderMessage: json['reminderMessage'] as String?,
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Memo를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value,
      'folderId': folderId,
      'tagIds': tagIds,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'reminderRepeat': reminderRepeat.value,
      'reminderMessage': reminderMessage,
      'checklist': checklist.map((e) => e.toJson()).toList(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 일부 필드를 변경한 새 인스턴스 반환
  Memo copyWith({
    String? id,
    String? title,
    String? content,
    MemoColor? color,
    Object? folderId = _undefined,
    List<String>? tagIds,
    bool? isPinned,
    bool? isFavorite,
    Object? startDate = _undefined,
    Object? endDate = _undefined,
    Object? reminderAt = _undefined,
    ReminderRepeat? reminderRepeat,
    Object? reminderMessage = _undefined,
    List<ChecklistItem>? checklist,
    bool? isDeleted,
    Object? deletedAt = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      folderId: folderId == _undefined ? this.folderId : folderId as String?,
      tagIds: tagIds ?? this.tagIds,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      startDate:
          startDate == _undefined ? this.startDate : startDate as DateTime?,
      endDate: endDate == _undefined ? this.endDate : endDate as DateTime?,
      reminderAt:
          reminderAt == _undefined ? this.reminderAt : reminderAt as DateTime?,
      reminderRepeat: reminderRepeat ?? this.reminderRepeat,
      reminderMessage: reminderMessage == _undefined
          ? this.reminderMessage
          : reminderMessage as String?,
      checklist: checklist ?? this.checklist,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt:
          deletedAt == _undefined ? this.deletedAt : deletedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 체크리스트 완료율 (0.0 ~ 1.0)
  double get checklistProgress {
    if (checklist.isEmpty) return 0.0;
    final checked = checklist.where((item) => item.isChecked).length;
    return checked / checklist.length;
  }

  /// 체크리스트 완료 개수
  int get checklistCheckedCount =>
      checklist.where((item) => item.isChecked).length;

  /// 리마인더 설정 여부
  bool get hasReminder => reminderAt != null;

  /// 날짜 설정 여부
  bool get hasDate => startDate != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Memo &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.color == color &&
        other.folderId == folderId &&
        other.isPinned == isPinned &&
        other.isFavorite == isFavorite &&
        other.isDeleted == isDeleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        content,
        color,
        folderId,
        isPinned,
        isFavorite,
        isDeleted,
        createdAt,
        updatedAt,
      );

  @override
  String toString() {
    return 'Memo(id: $id, title: $title, color: $color, isPinned: $isPinned, isDeleted: $isDeleted)';
  }
}

/// copyWith에서 null과 미지정을 구분하기 위한 sentinel 객체
const _undefined = Object();
