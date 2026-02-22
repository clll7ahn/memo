import 'package:flutter/material.dart';

import '../models/memo.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 메모 필터 조건 클래스
class MemoFilter {
  final String? folderId;
  final List<String> tagIds;
  final MemoColor? color;
  final bool? isPinned;
  final bool? isFavorite;
  final DateTime? startDate;
  final DateTime? endDate;

  const MemoFilter({
    this.folderId,
    this.tagIds = const [],
    this.color,
    this.isPinned,
    this.isFavorite,
    this.startDate,
    this.endDate,
  });

  /// 필터가 비어있는지 여부
  bool get isEmpty =>
      folderId == null &&
      tagIds.isEmpty &&
      color == null &&
      isPinned == null &&
      isFavorite == null &&
      startDate == null &&
      endDate == null;

  MemoFilter copyWith({
    Object? folderId = _undefined,
    List<String>? tagIds,
    Object? color = _undefined,
    Object? isPinned = _undefined,
    Object? isFavorite = _undefined,
    Object? startDate = _undefined,
    Object? endDate = _undefined,
  }) {
    return MemoFilter(
      folderId: folderId == _undefined ? this.folderId : folderId as String?,
      tagIds: tagIds ?? this.tagIds,
      color: color == _undefined ? this.color : color as MemoColor?,
      isPinned: isPinned == _undefined ? this.isPinned : isPinned as bool?,
      isFavorite:
          isFavorite == _undefined ? this.isFavorite : isFavorite as bool?,
      startDate:
          startDate == _undefined ? this.startDate : startDate as DateTime?,
      endDate: endDate == _undefined ? this.endDate : endDate as DateTime?,
    );
  }
}

const _undefined = Object();

/// 메모 상태 관리 Provider
class MemoProvider extends ChangeNotifier {
  final StorageService _storageService;

  /// 전체 메모 목록 (소프트 삭제 포함)
  List<Memo> _memos = [];

  /// 현재 뷰 타입 (리스트/그리드)
  ViewType _viewType = ViewType.list;

  /// 선택된 폴더 ID (null = 전체)
  String? _selectedFolderId;

  /// 현재 필터 조건
  MemoFilter _filter = const MemoFilter();

  /// 현재 정렬 기준
  SortField _sortField = SortField.updatedAt;

  /// 현재 정렬 순서
  SortOrder _sortOrder = SortOrder.descending;

  /// 다중 선택 모드 여부
  bool _isMultiSelectMode = false;

  /// 선택된 메모 ID 목록
  Set<String> _selectedMemoIds = {};

  /// 초기화 완료 여부
  bool _initialized = false;

  MemoProvider(this._storageService);

  // ============================
  // Getters
  // ============================

  bool get initialized => _initialized;

  /// 활성 메모 목록 (삭제되지 않은 메모, 필터/정렬 적용)
  List<Memo> get memos {
    var list = _memos.where((m) => !m.isDeleted).toList();

    // 폴더 필터 적용
    if (_selectedFolderId != null) {
      list = list.where((m) => m.folderId == _selectedFolderId).toList();
    }

    // 추가 필터 적용
    if (!_filter.isEmpty) {
      list = _applyFilter(list, _filter);
    }

    // 정렬 적용
    list = _applySorting(list);

    return list;
  }

  /// 고정된 메모 목록
  List<Memo> get pinnedMemos => memos.where((m) => m.isPinned).toList();

  /// 고정되지 않은 메모 목록
  List<Memo> get unpinnedMemos => memos.where((m) => !m.isPinned).toList();

  /// 즐겨찾기 메모 목록
  List<Memo> get favoriteMemos => memos.where((m) => m.isFavorite).toList();

  /// 휴지통 메모 목록 (삭제된 메모)
  List<Memo> get deletedMemos {
    final list = _memos.where((m) => m.isDeleted).toList();
    list.sort((a, b) =>
        (b.deletedAt ?? DateTime(0)).compareTo(a.deletedAt ?? DateTime(0)));
    return list;
  }

  /// 현재 뷰 타입
  ViewType get viewType => _viewType;

  /// 선택된 폴더 ID
  String? get selectedFolderId => _selectedFolderId;

  /// 현재 필터
  MemoFilter get filter => _filter;

  /// 현재 정렬 기준
  SortField get sortField => _sortField;

  /// 현재 정렬 순서
  SortOrder get sortOrder => _sortOrder;

  /// 다중 선택 모드 여부
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// 선택된 메모 ID 목록
  Set<String> get selectedMemoIds => Set.unmodifiable(_selectedMemoIds);

  /// 특정 폴더의 메모 개수
  int memoCountByFolder(String? folderId) {
    if (folderId == null) {
      return _memos.where((m) => !m.isDeleted).length;
    }
    return _memos
        .where((m) => !m.isDeleted && m.folderId == folderId)
        .length;
  }

  /// 특정 태그의 메모 개수
  int memoCountByTag(String tagId) {
    return _memos
        .where((m) => !m.isDeleted && m.tagIds.contains(tagId))
        .length;
  }

  // ============================
  // 초기화
  // ============================

  /// 메모 데이터 초기화 (앱 시작 시 호출)
  Future<void> init({
    SortField sortField = SortField.updatedAt,
    SortOrder sortOrder = SortOrder.descending,
    ViewType viewType = ViewType.list,
  }) async {
    if (_initialized) return;
    _sortField = sortField;
    _sortOrder = sortOrder;
    _viewType = viewType;
    await _storageService.initialize();
    _memos = await _storageService.loadMemos();
    // 30일 경과 메모 자동 영구 삭제
    await _autoDeleteExpiredMemos();
    _initialized = true;
    notifyListeners();
  }

  // ============================
  // 메모 CRUD
  // ============================

  /// 메모 추가
  Future<void> addMemo(Memo memo) async {
    _memos.add(memo);
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 메모 수정
  Future<void> updateMemo(Memo memo) async {
    final index = _memos.indexWhere((m) => m.id == memo.id);
    if (index != -1) {
      _memos[index] = memo.copyWith(updatedAt: DateTime.now());
      await _storageService.saveMemos(_memos);
      notifyListeners();
    }
  }

  /// ID로 메모 조회
  Memo? getMemoById(String id) {
    try {
      return _memos.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 메모 소프트 삭제 (휴지통으로 이동)
  Future<void> deleteMemo(String id) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      final now = DateTime.now();
      _memos[index] = _memos[index].copyWith(
        isDeleted: true,
        deletedAt: now,
        updatedAt: now,
      );
      await _storageService.saveMemos(_memos);
      notifyListeners();
    }
  }

  /// 다중 메모 소프트 삭제
  Future<void> deleteMultipleMemos(List<String> ids) async {
    final now = DateTime.now();
    for (final id in ids) {
      final index = _memos.indexWhere((m) => m.id == id);
      if (index != -1) {
        _memos[index] = _memos[index].copyWith(
          isDeleted: true,
          deletedAt: now,
          updatedAt: now,
        );
      }
    }
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 메모 복구 (휴지통에서 복원)
  Future<void> restoreMemo(String id) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(
        isDeleted: false,
        deletedAt: null,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveMemos(_memos);
      notifyListeners();
    }
  }

  /// 전체 메모 복구
  Future<void> restoreAllMemos() async {
    final now = DateTime.now();
    for (int i = 0; i < _memos.length; i++) {
      if (_memos[i].isDeleted) {
        _memos[i] = _memos[i].copyWith(
          isDeleted: false,
          deletedAt: null,
          updatedAt: now,
        );
      }
    }
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 메모 영구 삭제
  Future<void> permanentlyDeleteMemo(String id) async {
    _memos.removeWhere((m) => m.id == id);
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 휴지통 전체 비우기 (영구 삭제)
  Future<void> emptyTrash() async {
    _memos.removeWhere((m) => m.isDeleted);
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  // ============================
  // 토글 기능
  // ============================

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(
        isFavorite: !_memos[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveMemos(_memos);
      notifyListeners();
    }
  }

  /// 고정(핀) 토글
  Future<void> togglePin(String id) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(
        isPinned: !_memos[index].isPinned,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveMemos(_memos);
      notifyListeners();
    }
  }

  // ============================
  // 날짜별 메모 조회
  // ============================

  /// 특정 날짜의 메모 목록 반환
  List<Memo> getMemosByDate(DateTime date) {
    return _memos.where((m) {
      if (m.isDeleted) return false;
      if (m.startDate == null) return false;

      final start = DateTime(
          m.startDate!.year, m.startDate!.month, m.startDate!.day);
      final target = DateTime(date.year, date.month, date.day);

      if (m.endDate != null) {
        // 날짜 범위 메모: target이 start~end 사이인지 확인
        final end =
            DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day);
        return !target.isBefore(start) && !target.isAfter(end);
      } else {
        // 단일 날짜 메모
        return start == target;
      }
    }).toList();
  }

  /// 날짜 범위 내 메모 목록 반환
  List<Memo> getMemosByDateRange(DateTime start, DateTime end) {
    return _memos.where((m) {
      if (m.isDeleted) return false;
      if (m.startDate == null) return false;

      final memoStart = DateTime(
          m.startDate!.year, m.startDate!.month, m.startDate!.day);
      final memoEnd = m.endDate != null
          ? DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day)
          : memoStart;

      final rangeStart = DateTime(start.year, start.month, start.day);
      final rangeEnd = DateTime(end.year, end.month, end.day);

      // 겹치는 구간 여부
      return !memoEnd.isBefore(rangeStart) && !memoStart.isAfter(rangeEnd);
    }).toList();
  }

  /// 특정 월의 날짜별 메모 맵 반환 (캘린더용)
  Map<DateTime, List<Memo>> getMemosByMonth(int year, int month) {
    final result = <DateTime, List<Memo>>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dayMemos = getMemosByDate(date);
      if (dayMemos.isNotEmpty) {
        result[date] = dayMemos;
      }
    }
    return result;
  }

  // ============================
  // 검색
  // ============================

  /// 검색어로 메모 목록 검색 (필터 옵션 포함)
  List<Memo> searchMemos(String query, {MemoFilter? additionalFilter}) {
    var list = _memos.where((m) => !m.isDeleted).toList();

    // 검색어 적용
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      list = list.where((m) {
        return m.title.toLowerCase().contains(lowerQuery) ||
            m.content.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // 추가 필터 적용
    if (additionalFilter != null && !additionalFilter.isEmpty) {
      list = _applyFilter(list, additionalFilter);
    }

    // 정렬 적용
    list = _applySorting(list);
    return list;
  }

  // ============================
  // 필터/정렬 상태 변경
  // ============================

  /// 뷰 타입 변경
  void setViewType(ViewType viewType) {
    _viewType = viewType;
    notifyListeners();
  }

  /// 선택된 폴더 변경
  void setSelectedFolder(String? folderId) {
    _selectedFolderId = folderId;
    notifyListeners();
  }

  /// 정렬 기준 변경
  void setSortField(SortField field) {
    _sortField = field;
    notifyListeners();
  }

  /// 정렬 순서 변경
  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  /// 필터 업데이트
  void setFilter(MemoFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  /// 필터 초기화
  void clearFilter() {
    _filter = const MemoFilter();
    notifyListeners();
  }

  // ============================
  // 다중 선택 모드
  // ============================

  /// 다중 선택 모드 시작
  void enterMultiSelectMode(String firstId) {
    _isMultiSelectMode = true;
    _selectedMemoIds = {firstId};
    notifyListeners();
  }

  /// 다중 선택 모드 종료
  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedMemoIds = {};
    notifyListeners();
  }

  /// 메모 선택 토글
  void toggleMemoSelection(String id) {
    if (_selectedMemoIds.contains(id)) {
      _selectedMemoIds.remove(id);
    } else {
      _selectedMemoIds.add(id);
    }
    notifyListeners();
  }

  /// 전체 선택
  void selectAll() {
    _selectedMemoIds = memos.map((m) => m.id).toSet();
    notifyListeners();
  }

  /// 선택된 메모 일괄 삭제
  Future<void> deleteSelectedMemos() async {
    await deleteMultipleMemos(_selectedMemoIds.toList());
    exitMultiSelectMode();
  }

  // ============================
  // 폴더/태그 관련 업데이트
  // ============================

  /// 특정 폴더의 메모들을 null 폴더(전체)로 이동
  Future<void> removeFolderFromMemos(String folderId) async {
    final now = DateTime.now();
    for (int i = 0; i < _memos.length; i++) {
      if (_memos[i].folderId == folderId) {
        _memos[i] = _memos[i].copyWith(
          folderId: null,
          updatedAt: now,
        );
      }
    }
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 특정 태그를 메모에서 제거
  Future<void> removeTagFromMemos(String tagId) async {
    final now = DateTime.now();
    for (int i = 0; i < _memos.length; i++) {
      if (_memos[i].tagIds.contains(tagId)) {
        final newTagIds =
            _memos[i].tagIds.where((id) => id != tagId).toList();
        _memos[i] = _memos[i].copyWith(
          tagIds: newTagIds,
          updatedAt: now,
        );
      }
    }
    await _storageService.saveMemos(_memos);
    notifyListeners();
  }

  /// 전체 데이터 초기화 후 재로딩
  Future<void> reload() async {
    _memos = await _storageService.loadMemos();
    notifyListeners();
  }

  // ============================
  // 내부 헬퍼
  // ============================

  /// 필터 적용
  List<Memo> _applyFilter(List<Memo> list, MemoFilter filter) {
    var result = list;

    if (filter.folderId != null) {
      result =
          result.where((m) => m.folderId == filter.folderId).toList();
    }

    if (filter.tagIds.isNotEmpty) {
      result = result
          .where((m) => filter.tagIds.every((t) => m.tagIds.contains(t)))
          .toList();
    }

    if (filter.color != null) {
      result = result.where((m) => m.color == filter.color).toList();
    }

    if (filter.isPinned != null) {
      result = result.where((m) => m.isPinned == filter.isPinned).toList();
    }

    if (filter.isFavorite != null) {
      result =
          result.where((m) => m.isFavorite == filter.isFavorite).toList();
    }

    if (filter.startDate != null || filter.endDate != null) {
      final start = filter.startDate ?? DateTime(1900);
      final end = filter.endDate ?? DateTime(2100);
      result = result.where((m) {
        if (m.startDate == null) return false;
        return !m.startDate!.isBefore(start) && !m.startDate!.isAfter(end);
      }).toList();
    }

    return result;
  }

  /// 정렬 적용
  List<Memo> _applySorting(List<Memo> list) {
    final sorted = List<Memo>.from(list);
    sorted.sort((a, b) {
      int compare;
      switch (_sortField) {
        case SortField.updatedAt:
          compare = a.updatedAt.compareTo(b.updatedAt);
        case SortField.createdAt:
          compare = a.createdAt.compareTo(b.createdAt);
        case SortField.title:
          compare = a.title.compareTo(b.title);
        case SortField.startDate:
          if (a.startDate == null && b.startDate == null) {
            compare = 0;
          } else if (a.startDate == null) {
            compare = 1;
          } else if (b.startDate == null) {
            compare = -1;
          } else {
            compare = a.startDate!.compareTo(b.startDate!);
          }
      }
      return _sortOrder == SortOrder.descending ? -compare : compare;
    });
    return sorted;
  }

  /// 30일 경과 메모 자동 영구 삭제
  Future<void> _autoDeleteExpiredMemos() async {
    final expireDate = DateTime.now().subtract(const Duration(days: 30));
    final before = _memos.length;
    _memos.removeWhere(
      (m) =>
          m.isDeleted &&
          m.deletedAt != null &&
          m.deletedAt!.isBefore(expireDate),
    );
    if (_memos.length != before) {
      await _storageService.saveMemos(_memos);
    }
  }
}
