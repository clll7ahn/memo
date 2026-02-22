import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../models/enums.dart';
import '../providers/folder_provider.dart';
import '../providers/memo_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tag_provider.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ListView(
            children: [
              // ── 테마 설정 ─────────────────────────
              const _SectionHeader(label: '테마'),
              RadioListTile<AppThemeMode>(
                title: const Text('라이트'),
                value: AppThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (v) {
                  if (v != null) settingsProvider.setThemeMode(v);
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('다크'),
                value: AppThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (v) {
                  if (v != null) settingsProvider.setThemeMode(v);
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('시스템'),
                value: AppThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (v) {
                  if (v != null) settingsProvider.setThemeMode(v);
                },
              ),
              // 기본 메모 색상
              ListTile(
                title: const Text('기본 메모 색상'),
                subtitle: Text(settings.defaultColor.label),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.defaultColor.getColor(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                onTap: () =>
                    _showColorPicker(context, settingsProvider, isDark),
              ),

              const Divider(),

              // ── 뷰 설정 ─────────────────────────
              const _SectionHeader(label: '뷰 설정'),
              ListTile(
                title: const Text('기본 뷰'),
                subtitle: Text(settings.defaultView.label),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showViewTypePicker(context, settingsProvider),
              ),
              ListTile(
                title: const Text('정렬 기준'),
                subtitle: Text(settings.sortField.label),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showSortFieldPicker(context, settingsProvider),
              ),
              ListTile(
                title: const Text('정렬 순서'),
                subtitle: Text(settings.sortOrder.label),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showSortOrderPicker(context, settingsProvider),
              ),

              const Divider(),

              // ── 알림 설정 ─────────────────────────
              const _SectionHeader(label: '알림'),
              SwitchListTile(
                title: const Text('전체 알림'),
                subtitle: const Text('메모 알림을 허용합니다'),
                value: settings.notificationsEnabled,
                onChanged: settingsProvider.setNotificationsEnabled,
              ),

              const Divider(),

              // ── 데이터 관리 ─────────────────────────
              const _SectionHeader(label: '데이터 관리'),
              ListTile(
                title: const Text('전체 데이터 초기화'),
                subtitle: const Text('모든 메모, 폴더, 태그가 삭제됩니다'),
                leading: const Icon(Icons.delete_forever_outlined),
                iconColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.error,
                onTap: () => _confirmReset(context),
              ),

              const Divider(),

              // ── 앱 정보 ─────────────────────────
              const _SectionHeader(label: '정보'),
              const ListTile(
                title: Text('앱 버전'),
                subtitle: Text(AppConstants.appVersion),
                leading: Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('오픈소스 라이선스'),
                leading: const Icon(Icons.description_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: AppConstants.appVersion,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  /// 색상 선택 다이얼로그
  Future<void> _showColorPicker(
    BuildContext context,
    SettingsProvider provider,
    bool isDark,
  ) async {
    final selected = await showDialog<MemoColor>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기본 메모 색상'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MemoColor.values.map((color) {
            final c = color.getColor(isDark);
            final isSelected = color == provider.settings.defaultColor;
            return GestureDetector(
              onTap: () => Navigator.of(ctx).pop(color),
              child: Tooltip(
                message: color.label,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(ctx).colorScheme.primary
                          : Theme.of(ctx).colorScheme.outlineVariant,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check,
                          size: 20, color: Theme.of(ctx).colorScheme.primary)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      await provider.setDefaultColor(selected);
    }
  }

  /// 기본 뷰 선택 다이얼로그
  Future<void> _showViewTypePicker(
    BuildContext context,
    SettingsProvider provider,
  ) async {
    final selected = await showDialog<ViewType>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('기본 뷰'),
        children: ViewType.values.map((v) {
          return RadioListTile<ViewType>(
            title: Text(v.label),
            value: v,
            groupValue: provider.settings.defaultView,
            onChanged: (val) => Navigator.of(ctx).pop(val),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      await provider.setDefaultView(selected);
    }
  }

  /// 정렬 기준 선택 다이얼로그
  Future<void> _showSortFieldPicker(
    BuildContext context,
    SettingsProvider provider,
  ) async {
    final selected = await showDialog<SortField>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('정렬 기준'),
        children: SortField.values.map((v) {
          return RadioListTile<SortField>(
            title: Text(v.label),
            value: v,
            groupValue: provider.settings.sortField,
            onChanged: (val) => Navigator.of(ctx).pop(val),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      await provider.setSortField(selected);
    }
  }

  /// 정렬 순서 선택 다이얼로그
  Future<void> _showSortOrderPicker(
    BuildContext context,
    SettingsProvider provider,
  ) async {
    final selected = await showDialog<SortOrder>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('정렬 순서'),
        children: SortOrder.values.map((v) {
          return RadioListTile<SortOrder>(
            title: Text(v.label),
            value: v,
            groupValue: provider.settings.sortOrder,
            onChanged: (val) => Navigator.of(ctx).pop(val),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      await provider.setSortOrder(selected);
    }
  }

  /// 데이터 초기화 확인 다이얼로그
  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('전체 데이터 초기화'),
        content: const Text(
          '모든 메모, 폴더, 태그 및 설정이 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // 데이터 초기화 실행
    final storageService = context.read<SettingsProvider>().storageService;
    await storageService.clearAll();

    if (!context.mounted) return;

    // 각 Provider 리로드
    await Future.wait([
      context.read<MemoProvider>().reload(),
      context.read<FolderProvider>().initialize(),
      context.read<TagProvider>().initialize(),
      context.read<SettingsProvider>().resetSettings(),
    ]);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터가 초기화되었습니다.')),
      );
    }
  }
}

/// 섹션 헤더 위젯
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
