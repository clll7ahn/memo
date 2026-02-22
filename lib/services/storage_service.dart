import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/folder.dart';
import '../models/memo.dart';
import '../models/tag.dart';

/// SharedPreferences 키 상수
class _StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String defaultColor = 'default_color';
  static const String defaultView = 'default_view';
  static const String sortField = 'sort_field';
  static const String sortOrder = 'sort_order';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String recentSearches = 'recent_searches';
}

/// 앱 설정 데이터 클래스
class AppSettings {
  final AppThemeMode themeMode;
  final MemoColor defaultColor;
  final ViewType defaultView;
  final SortField sortField;
  final SortOrder sortOrder;
  final bool notificationsEnabled;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.defaultColor = MemoColor.white,
    this.defaultView = ViewType.list,
    this.sortField = SortField.updatedAt,
    this.sortOrder = SortOrder.descending,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    AppThemeMode? themeMode,
    MemoColor? defaultColor,
    ViewType? defaultView,
    SortField? sortField,
    SortOrder? sortOrder,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultColor: defaultColor ?? this.defaultColor,
      defaultView: defaultView ?? this.defaultView,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// 로컬 저장소 서비스
/// SharedPreferences 및 JSON 파일을 이용해 앱 데이터를 저장/로드한다.
class StorageService {
  static const _uuid = Uuid();

  late SharedPreferences _prefs;
  late Directory _appDir;
  bool _initialized = false;

  /// 초기화 - 앱 시작 시 반드시 호출
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _appDir = await getApplicationDocumentsDirectory();
    _initialized = true;
  }

  // ============================
  // 메모 저장소
  // ============================

  File get _memosFile => File('${_appDir.path}/memos.json');

  /// 전체 메모 목록 로드
  Future<List<Memo>> loadMemos() async {
    try {
      if (!await _memosFile.exists()) return [];
      final jsonStr = await _memosFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
      return jsonList
          .map((e) => Memo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 파일 손상 시 빈 목록 반환
      return [];
    }
  }

  /// 전체 메모 목록 저장
  Future<void> saveMemos(List<Memo> memos) async {
    final jsonList = memos.map((e) => e.toJson()).toList();
    await _memosFile.writeAsString(json.encode(jsonList));
  }

  // ============================
  // 폴더 저장소
  // ============================

  File get _foldersFile => File('${_appDir.path}/folders.json');

  /// 전체 폴더 목록 로드
  Future<List<Folder>> loadFolders() async {
    try {
      if (!await _foldersFile.exists()) return [];
      final jsonStr = await _foldersFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
      return jsonList
          .map((e) => Folder.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 전체 폴더 목록 저장
  Future<void> saveFolders(List<Folder> folders) async {
    final jsonList = folders.map((e) => e.toJson()).toList();
    await _foldersFile.writeAsString(json.encode(jsonList));
  }

  /// 기본 폴더 데이터 생성
  List<Folder> createDefaultFolders() {
    final now = DateTime.now();
    return [
      Folder(
        id: _uuid.v4(),
        name: '개인',
        color: MemoColor.blue,
        sortOrder: 0,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Folder(
        id: _uuid.v4(),
        name: '업무',
        color: MemoColor.green,
        sortOrder: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Folder(
        id: _uuid.v4(),
        name: '아이디어',
        color: MemoColor.yellow,
        sortOrder: 2,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // ============================
  // 태그 저장소
  // ============================

  File get _tagsFile => File('${_appDir.path}/tags.json');

  /// 전체 태그 목록 로드
  Future<List<Tag>> loadTags() async {
    try {
      if (!await _tagsFile.exists()) return [];
      final jsonStr = await _tagsFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
      return jsonList
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 전체 태그 목록 저장
  Future<void> saveTags(List<Tag> tags) async {
    final jsonList = tags.map((e) => e.toJson()).toList();
    await _tagsFile.writeAsString(json.encode(jsonList));
  }

  // ============================
  // 설정 저장소
  // ============================

  /// 앱 설정 로드
  Future<AppSettings> loadSettings() async {
    return AppSettings(
      themeMode: (_prefs.getString(_StorageKeys.themeMode) ?? 'system')
          .toAppThemeMode(),
      defaultColor: (_prefs.getString(_StorageKeys.defaultColor) ?? 'white')
          .toMemoColor(),
      defaultView:
          (_prefs.getString(_StorageKeys.defaultView) ?? 'list').toViewType(),
      sortField: (_prefs.getString(_StorageKeys.sortField) ?? 'updatedAt')
          .toSortField(),
      sortOrder: (_prefs.getString(_StorageKeys.sortOrder) ?? 'descending')
          .toSortOrder(),
      notificationsEnabled:
          _prefs.getBool(_StorageKeys.notificationsEnabled) ?? true,
    );
  }

  /// 앱 설정 저장
  Future<void> saveSettings(AppSettings settings) async {
    await Future.wait([
      _prefs.setString(_StorageKeys.themeMode, settings.themeMode.value),
      _prefs.setString(_StorageKeys.defaultColor, settings.defaultColor.value),
      _prefs.setString(_StorageKeys.defaultView, settings.defaultView.value),
      _prefs.setString(_StorageKeys.sortField, settings.sortField.value),
      _prefs.setString(_StorageKeys.sortOrder, settings.sortOrder.value),
      _prefs.setBool(
          _StorageKeys.notificationsEnabled, settings.notificationsEnabled),
    ]);
  }

  // ============================
  // 최근 검색어
  // ============================

  /// 최근 검색어 로드
  Future<List<String>> loadRecentSearches() async {
    return _prefs.getStringList(_StorageKeys.recentSearches) ?? [];
  }

  /// 최근 검색어 추가 (최대 10개)
  Future<List<String>> addRecentSearch(String query) async {
    final searches = await loadRecentSearches();
    // 중복 제거 후 맨 앞에 추가
    searches.remove(query);
    searches.insert(0, query);
    // 최대 10개 유지
    final limited = searches.take(10).toList();
    await _prefs.setStringList(_StorageKeys.recentSearches, limited);
    return limited;
  }

  /// 특정 검색어 삭제
  Future<List<String>> removeRecentSearch(String query) async {
    final searches = await loadRecentSearches();
    searches.remove(query);
    await _prefs.setStringList(_StorageKeys.recentSearches, searches);
    return searches;
  }

  /// 전체 검색어 삭제
  Future<void> clearRecentSearches() async {
    await _prefs.remove(_StorageKeys.recentSearches);
  }

  // ============================
  // 전체 데이터 초기화
  // ============================

  /// 모든 로컬 데이터 삭제
  Future<void> clearAll() async {
    // JSON 파일 삭제
    final files = [_memosFile, _foldersFile, _tagsFile];
    for (final file in files) {
      if (await file.exists()) {
        await file.delete();
      }
    }
    // SharedPreferences 전체 삭제
    await _prefs.clear();
  }
}
