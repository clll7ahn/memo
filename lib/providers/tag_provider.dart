import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/tag.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 태그 상태 관리 Provider
class TagProvider extends ChangeNotifier {
  final StorageService storageService;
  static const _uuid = Uuid();

  /// 태그 목록
  List<Tag> _tags = [];

  TagProvider({required this.storageService});

  // ============================
  // Getters
  // ============================

  /// 전체 태그 목록 (이름 순)
  List<Tag> get tags {
    final sorted = List<Tag>.from(_tags);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// ID로 태그 조회
  Tag? getTagById(String id) {
    try {
      return _tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ID 목록으로 태그 목록 조회
  List<Tag> getTagsByIds(List<String> ids) {
    return _tags.where((t) => ids.contains(t.id)).toList();
  }

  // ============================
  // 초기화
  // ============================

  /// 태그 데이터 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    _tags = await storageService.loadTags();
    notifyListeners();
  }

  // ============================
  // 태그 CRUD
  // ============================

  /// 태그 추가
  Future<void> addTag({
    required String name,
    MemoColor color = MemoColor.blue,
  }) async {
    final tag = Tag(
      id: _uuid.v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    _tags.add(tag);
    await storageService.saveTags(_tags);
    notifyListeners();
  }

  /// 태그 수정
  Future<void> updateTag(Tag tag) async {
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
      await storageService.saveTags(_tags);
      notifyListeners();
    }
  }

  /// 태그 삭제
  Future<void> deleteTag(String id) async {
    _tags.removeWhere((t) => t.id == id);
    await storageService.saveTags(_tags);
    notifyListeners();
  }
}
