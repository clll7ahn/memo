import 'package:flutter/material.dart';

/// 앱 전역 상수 정의
class AppConstants {
  AppConstants._();

  // 앱 기본 정보
  static const String appName = 'MemoCalendar';
  static const String appVersion = '1.0.0';

  // SharedPreferences 저장소 키
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultColor = 'default_color';
  static const String keyDefaultView = 'default_view';
  static const String keySortField = 'sort_field';
  static const String keySortOrder = 'sort_order';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyRecentSearches = 'recent_searches';
  static const String keyMemos = 'memos';
  static const String keyFolders = 'folders';
  static const String keyTags = 'tags';

  // 최근 검색어 최대 저장 개수
  static const int maxRecentSearches = 10;

  // 메모 필드 최대 길이
  static const int maxTitleLength = 100;
  static const int maxContentLength = 50000;
  static const int maxFolderNameLength = 50;
  static const int maxTagNameLength = 30;

  // 소프트 삭제 보관 기간 (일)
  static const int trashRetentionDays = 30;

  // 기본 폴더 데이터
  static const List<Map<String, dynamic>> defaultFolders = [
    {
      'id': 'folder_all',
      'name': '전체',
      'color': 'blue',
      'sortOrder': 0,
      'isDefault': true,
    },
    {
      'id': 'folder_personal',
      'name': '개인',
      'color': 'green',
      'sortOrder': 1,
      'isDefault': true,
    },
    {
      'id': 'folder_work',
      'name': '업무',
      'color': 'orange',
      'sortOrder': 2,
      'isDefault': true,
    },
    {
      'id': 'folder_idea',
      'name': '아이디어',
      'color': 'purple',
      'sortOrder': 3,
      'isDefault': true,
    },
  ];

  // 메모 색상 팔레트 (라이트 모드)
  static const Map<String, Color> memoColorsLight = {
    'white': Color(0xFFFFFFFF),
    'yellow': Color(0xFFFFF9C4),
    'green': Color(0xFFC8E6C9),
    'blue': Color(0xFFBBDEFB),
    'purple': Color(0xFFE1BEE7),
    'pink': Color(0xFFFCE4EC),
    'red': Color(0xFFFFCDD2),
    'orange': Color(0xFFFFE0B2),
    'teal': Color(0xFFB2DFDB),
    'indigo': Color(0xFFC5CAE9),
    'lime': Color(0xFFF0F4C3),
    'gray': Color(0xFFF5F5F5),
  };

  // 메모 색상 팔레트 (다크 모드)
  static const Map<String, Color> memoColorsDark = {
    'white': Color(0xFF2C2C2C),
    'yellow': Color(0xFF5C5030),
    'green': Color(0xFF2E5030),
    'blue': Color(0xFF1A3A5C),
    'purple': Color(0xFF3D2655),
    'pink': Color(0xFF5C2035),
    'red': Color(0xFF5C1A20),
    'orange': Color(0xFF5C3A1A),
    'teal': Color(0xFF1A4C48),
    'indigo': Color(0xFF262D5C),
    'lime': Color(0xFF414C1A),
    'gray': Color(0xFF3A3A3A),
  };

  // 색상 팔레트 키 목록 (순서 고정)
  static const List<String> colorKeys = [
    'white',
    'yellow',
    'green',
    'blue',
    'purple',
    'pink',
    'red',
    'orange',
    'teal',
    'indigo',
    'lime',
    'gray',
  ];

  // 앱 메인 색상
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
}
