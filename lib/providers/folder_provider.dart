import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// 폴더 상태 관리 Provider
class FolderProvider extends ChangeNotifier {
  final StorageService storageService;
  static const _uuid = Uuid();

  /// 폴더 목록
  List<Folder> _folders = [];

  FolderProvider({required this.storageService});

  // ============================
  // Getters
  // ============================

  /// 전체 폴더 목록 (정렬 순서 기준)
  List<Folder> get folders {
    final sorted = List<Folder>.from(_folders);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// ID로 폴더 조회
  Folder? getFolderById(String id) {
    try {
      return _folders.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============================
  // 초기화
  // ============================

  /// 폴더 데이터 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    _folders = await storageService.loadFolders();
    // 폴더가 없으면 기본 폴더 생성
    if (_folders.isEmpty) {
      _folders = storageService.createDefaultFolders();
      await storageService.saveFolders(_folders);
    }
    notifyListeners();
  }

  // ============================
  // 폴더 CRUD
  // ============================

  /// 폴더 추가
  Future<void> addFolder({
    required String name,
    MemoColor color = MemoColor.blue,
  }) async {
    final now = DateTime.now();
    final folder = Folder(
      id: _uuid.v4(),
      name: name,
      color: color,
      sortOrder: _folders.length,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
    _folders.add(folder);
    await storageService.saveFolders(_folders);
    notifyListeners();
  }

  /// 폴더 수정
  Future<void> updateFolder(Folder folder) async {
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      _folders[index] = folder.copyWith(updatedAt: DateTime.now());
      await storageService.saveFolders(_folders);
      notifyListeners();
    }
  }

  /// 폴더 삭제 (기본 폴더는 삭제 불가)
  Future<void> deleteFolder(String id) async {
    final folder = getFolderById(id);
    if (folder == null || folder.isDefault) return;
    _folders.removeWhere((f) => f.id == id);
    await storageService.saveFolders(_folders);
    notifyListeners();
  }

  /// 폴더 순서 변경
  Future<void> reorderFolders(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final folder = _folders.removeAt(oldIndex);
    _folders.insert(newIndex, folder);
    // 정렬 순서 재설정
    for (int i = 0; i < _folders.length; i++) {
      _folders[i] = _folders[i].copyWith(sortOrder: i);
    }
    await storageService.saveFolders(_folders);
    notifyListeners();
  }
}
