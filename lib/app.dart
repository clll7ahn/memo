import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/settings_provider.dart';

/// 앱 루트 위젯
class MemoCalendarApp extends StatelessWidget {
  const MemoCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsProvider에서 테마 모드 가져오기
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp.router(
      // 앱 제목
      title: 'MemoCalendar',
      // 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
      // 라우터 설정
      routerConfig: appRouter,
      // 라이트 테마
      theme: AppTheme.lightTheme,
      // 다크 테마
      darkTheme: AppTheme.darkTheme,
      // 테마 모드 (SettingsProvider에서 가져옴)
      themeMode: settingsProvider.themeMode,
    );
  }
}
