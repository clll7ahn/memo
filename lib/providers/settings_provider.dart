import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../services/storage_service.dart';

/// 앱 설정 상태 관리 Provider
class SettingsProvider extends ChangeNotifier {
  final StorageService storageService;

  /// 현재 앱 설정
  AppSettings _settings = const AppSettings();

  SettingsProvider({required this.storageService});

  // ============================
  // Getters
  // ============================

  /// 현재 설정
  AppSettings get settings => _settings;

  /// Flutter ThemeMode 반환 (앱 테마 적용에 사용)
  ThemeMode get themeMode => _settings.themeMode.themeMode;

  /// 기본 메모 색상
  MemoColor get defaultColor => _settings.defaultColor;

  /// 기본 뷰 타입
  ViewType get defaultView => _settings.defaultView;

  /// 정렬 기준
  SortField get sortField => _settings.sortField;

  /// 정렬 순서
  SortOrder get sortOrder => _settings.sortOrder;

  /// 알림 활성화 여부
  bool get notificationsEnabled => _settings.notificationsEnabled;

  // ============================
  // 초기화
  // ============================

  /// 설정 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    _settings = await storageService.loadSettings();
    notifyListeners();
  }

  // ============================
  // 설정 변경
  // ============================

  /// 테마 모드 변경
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 기본 메모 색상 변경
  Future<void> setDefaultColor(MemoColor color) async {
    _settings = _settings.copyWith(defaultColor: color);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 기본 뷰 타입 변경
  Future<void> setDefaultView(ViewType viewType) async {
    _settings = _settings.copyWith(defaultView: viewType);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 정렬 기준 변경
  Future<void> setSortField(SortField sortField) async {
    _settings = _settings.copyWith(sortField: sortField);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 정렬 순서 변경
  Future<void> setSortOrder(SortOrder sortOrder) async {
    _settings = _settings.copyWith(sortOrder: sortOrder);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 알림 활성화 여부 변경
  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// 전체 설정 초기화
  Future<void> resetSettings() async {
    _settings = const AppSettings();
    await storageService.saveSettings(_settings);
    notifyListeners();
  }
}
