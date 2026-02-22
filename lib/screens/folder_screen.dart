import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/folder.dart';
import '../providers/folder_provider.dart';
import '../providers/memo_provider.dart';

/// 폴더 관리 화면
class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('폴더 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '폴더 추가',
            onPressed: () => _showFolderDialog(context, null),
          ),
        ],
      ),
      body: Consumer<FolderProvider>(
        builder: (context, folderProvider, _) {
          final folders = folderProvider.folders;
          final memoProvider = context.watch<MemoProvider>();

          if (folders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('폴더가 없습니다.'),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: folders.length,
            onReorder: folderProvider.reorderFolders,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final memoCount = memoProvider.memoCountByFolder(folder.id);
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final folderColor = folder.color.getColor(isDark);

              return _FolderListItem(
                key: ValueKey(folder.id),
                folder: folder,
                memoCount: memoCount,
                folderColor: folderColor,
                onEdit: () => _showFolderDialog(context, folder),
                onDelete: folder.isDefault
                    ? null
                    : () => _deleteFolder(context, folder),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFolderDialog(context, null),
        tooltip: '폴더 추가',
        child: const Icon(Icons.create_new_folder_outlined),
      ),
    );
  }

  /// 폴더 추가/수정 다이얼로그
  Future<void> _showFolderDialog(
      BuildContext context, Folder? existingFolder) async {
    final nameController =
        TextEditingController(text: existingFolder?.name ?? '');
    MemoColor selectedColor = existingFolder?.color ?? MemoColor.blue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingFolder != null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? '폴더 수정' : '새 폴더'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 폴더 이름 입력
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '폴더 이름',
                  hintText: '폴더 이름을 입력하세요',
                ),
                autofocus: true,
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              // 색상 선택
              Text(
                '색상',
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MemoColor.values.map((color) {
                  final c = color.getColor(isDark);
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColor = color),
                    child: Tooltip(
                      message: color.label,
                      child: Container(
                        width: 36,
                        height: 36,
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
                                size: 18,
                                color: Theme.of(ctx).colorScheme.primary)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final folderProvider = context.read<FolderProvider>();
                if (isEdit) {
                  final updated = existingFolder.copyWith(
                    name: name,
                    color: selectedColor,
                  );
                  await folderProvider.updateFolder(updated);
                } else {
                  await folderProvider.addFolder(
                    name: name,
                    color: selectedColor,
                  );
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(isEdit ? '저장' : '추가'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  /// 폴더 삭제 확인
  Future<void> _deleteFolder(BuildContext context, Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('폴더 삭제'),
        content: Text(
            '"${folder.name}" 폴더를 삭제하시겠습니까?\n폴더 내 메모는 삭제되지 않습니다.'),
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
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      // 폴더 삭제 전 해당 폴더의 메모에서 폴더 정보 제거
      await context.read<MemoProvider>().removeFolderFromMemos(folder.id);
      if (context.mounted) {
        await context.read<FolderProvider>().deleteFolder(folder.id);
      }
    }
  }
}

/// 폴더 목록 항목 위젯
class _FolderListItem extends StatelessWidget {
  final Folder folder;
  final int memoCount;
  final Color folderColor;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _FolderListItem({
    super.key,
    required this.folder,
    required this.memoCount,
    required this.folderColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismissible_${folder.id}'),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (_) async {
        if (onDelete == null) return false;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('폴더 삭제'),
            content: Text('"${folder.name}" 폴더를 삭제하시겠습니까?'),
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
                child: const Text('삭제'),
              ),
            ],
          ),
        );
        return confirmed == true;
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: folderColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            folder.isDefault ? Icons.folder : Icons.folder_outlined,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(folder.name)),
            if (folder.isDefault)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '기본',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                ),
              ),
          ],
        ),
        subtitle: Text('메모 $memoCount개'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: '수정',
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                tooltip: '삭제',
                color: Theme.of(context).colorScheme.error,
              )
            else
              const SizedBox(width: 40),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
