import 'package:flutter/material.dart';

/// 메모 색상 열거형
enum MemoColor {
  white,
  yellow,
  green,
  blue,
  purple,
  pink,
  red,
  orange,
  teal,
  indigo,
  lime,
  gray,
}

/// MemoColor 확장 메서드
extension MemoColorExtension on MemoColor {
  /// 한국어 이름
  String get label {
    switch (this) {
      case MemoColor.white:
        return '흰색';
      case MemoColor.yellow:
        return '노란색';
      case MemoColor.green:
        return '초록색';
      case MemoColor.blue:
        return '파란색';
      case MemoColor.purple:
        return '보라색';
      case MemoColor.pink:
        return '분홍색';
      case MemoColor.red:
        return '빨간색';
      case MemoColor.orange:
        return '주황색';
      case MemoColor.teal:
        return '청록색';
      case MemoColor.indigo:
        return '남색';
      case MemoColor.lime:
        return '라임색';
      case MemoColor.gray:
        return '회색';
    }
  }

  /// 저장용 문자열 값
  String get value => name;

  /// 라이트 모드 색상
  Color get lightColor {
    switch (this) {
      case MemoColor.white:
        return const Color(0xFFFFFFFF);
      case MemoColor.yellow:
        return const Color(0xFFFFF9C4);
      case MemoColor.green:
        return const Color(0xFFC8E6C9);
      case MemoColor.blue:
        return const Color(0xFFBBDEFB);
      case MemoColor.purple:
        return const Color(0xFFE1BEE7);
      case MemoColor.pink:
        return const Color(0xFFFCE4EC);
      case MemoColor.red:
        return const Color(0xFFFFCDD2);
      case MemoColor.orange:
        return const Color(0xFFFFE0B2);
      case MemoColor.teal:
        return const Color(0xFFB2DFDB);
      case MemoColor.indigo:
        return const Color(0xFFC5CAE9);
      case MemoColor.lime:
        return const Color(0xFFF0F4C3);
      case MemoColor.gray:
        return const Color(0xFFF5F5F5);
    }
  }

  /// 다크 모드 색상
  Color get darkColor {
    switch (this) {
      case MemoColor.white:
        return const Color(0xFF2C2C2C);
      case MemoColor.yellow:
        return const Color(0xFF5C5030);
      case MemoColor.green:
        return const Color(0xFF2E5030);
      case MemoColor.blue:
        return const Color(0xFF1A3A5C);
      case MemoColor.purple:
        return const Color(0xFF3D2655);
      case MemoColor.pink:
        return const Color(0xFF5C2035);
      case MemoColor.red:
        return const Color(0xFF5C1A20);
      case MemoColor.orange:
        return const Color(0xFF5C3A1A);
      case MemoColor.teal:
        return const Color(0xFF1A4C48);
      case MemoColor.indigo:
        return const Color(0xFF262D5C);
      case MemoColor.lime:
        return const Color(0xFF414C1A);
      case MemoColor.gray:
        return const Color(0xFF3A3A3A);
    }
  }

  /// 테마에 따른 색상 반환
  Color getColor(bool isDark) => isDark ? darkColor : lightColor;
}

/// MemoColor 문자열 변환 유틸
extension MemoColorFromString on String {
  MemoColor toMemoColor() {
    return MemoColor.values.firstWhere(
      (e) => e.value == this,
      orElse: () => MemoColor.white,
    );
  }
}

/// 반복 알림 열거형
enum ReminderRepeat {
  none,
  daily,
  weekly,
  monthly,
}

/// ReminderRepeat 확장 메서드
extension ReminderRepeatExtension on ReminderRepeat {
  /// 한국어 이름
  String get label {
    switch (this) {
      case ReminderRepeat.none:
        return '없음';
      case ReminderRepeat.daily:
        return '매일';
      case ReminderRepeat.weekly:
        return '매주';
      case ReminderRepeat.monthly:
        return '매월';
    }
  }

  /// 저장용 문자열 값
  String get value => name;
}

/// ReminderRepeat 문자열 변환 유틸
extension ReminderRepeatFromString on String {
  ReminderRepeat toReminderRepeat() {
    return ReminderRepeat.values.firstWhere(
      (e) => e.value == this,
      orElse: () => ReminderRepeat.none,
    );
  }
}

/// 뷰 타입 열거형
enum ViewType {
  list,
  grid,
  calendar,
}

/// ViewType 확장 메서드
extension ViewTypeExtension on ViewType {
  /// 한국어 이름
  String get label {
    switch (this) {
      case ViewType.list:
        return '리스트';
      case ViewType.grid:
        return '그리드';
      case ViewType.calendar:
        return '캘린더';
    }
  }

  /// 저장용 문자열 값
  String get value => name;
}

/// ViewType 문자열 변환 유틸
extension ViewTypeFromString on String {
  ViewType toViewType() {
    return ViewType.values.firstWhere(
      (e) => e.value == this,
      orElse: () => ViewType.list,
    );
  }
}

/// 정렬 기준 열거형
enum SortField {
  updatedAt,
  createdAt,
  title,
  startDate,
}

/// SortField 확장 메서드
extension SortFieldExtension on SortField {
  /// 한국어 이름
  String get label {
    switch (this) {
      case SortField.updatedAt:
        return '수정 일시';
      case SortField.createdAt:
        return '생성 일시';
      case SortField.title:
        return '제목';
      case SortField.startDate:
        return '날짜';
    }
  }

  /// 저장용 문자열 값
  String get value => name;
}

/// SortField 문자열 변환 유틸
extension SortFieldFromString on String {
  SortField toSortField() {
    return SortField.values.firstWhere(
      (e) => e.value == this,
      orElse: () => SortField.updatedAt,
    );
  }
}

/// 정렬 순서 열거형
enum SortOrder {
  descending,
  ascending,
}

/// SortOrder 확장 메서드
extension SortOrderExtension on SortOrder {
  /// 한국어 이름
  String get label {
    switch (this) {
      case SortOrder.descending:
        return '내림차순';
      case SortOrder.ascending:
        return '오름차순';
    }
  }

  /// 저장용 문자열 값
  String get value => name;
}

/// SortOrder 문자열 변환 유틸
extension SortOrderFromString on String {
  SortOrder toSortOrder() {
    return SortOrder.values.firstWhere(
      (e) => e.value == this,
      orElse: () => SortOrder.descending,
    );
  }
}

/// 앱 테마 모드 열거형
enum AppThemeMode {
  light,
  dark,
  system,
}

/// AppThemeMode 확장 메서드
extension AppThemeModeExtension on AppThemeMode {
  /// 한국어 이름
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return '라이트';
      case AppThemeMode.dark:
        return '다크';
      case AppThemeMode.system:
        return '시스템';
    }
  }

  /// 저장용 문자열 값
  String get value => name;

  /// Flutter ThemeMode로 변환
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// AppThemeMode 문자열 변환 유틸
extension AppThemeModeFromString on String {
  AppThemeMode toAppThemeMode() {
    return AppThemeMode.values.firstWhere(
      (e) => e.value == this,
      orElse: () => AppThemeMode.system,
    );
  }
}
