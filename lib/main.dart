import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/memo_provider.dart';
import 'providers/folder_provider.dart';
import 'providers/tag_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';

/// 앱 진입점
void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화 (날짜 포맷 등에 사용)
  await initializeDateFormatting('ko_KR', null);

  // 저장소 서비스 초기화
  final storageService = StorageService();
  await storageService.initialize();

  // Provider 인스턴스 생성
  final memoProvider = MemoProvider(storageService);
  final folderProvider = FolderProvider(storageService: storageService);
  final tagProvider = TagProvider(storageService: storageService);
  final settingsProvider = SettingsProvider(storageService: storageService);

  // 비동기 데이터 로드 (병렬 처리)
  await Future.wait([
    memoProvider.init(),
    folderProvider.initialize(),
    tagProvider.initialize(),
    settingsProvider.initialize(),
  ]);

  // MultiProvider로 앱 실행
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MemoProvider>.value(value: memoProvider),
        ChangeNotifierProvider<FolderProvider>.value(value: folderProvider),
        ChangeNotifierProvider<TagProvider>.value(value: tagProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
      ],
      child: const MemoCalendarApp(),
    ),
  );
}
