import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/tag.dart';
import '../providers/memo_provider.dart';
import '../providers/tag_provider.dart';

/// 태그 관리 화면
class TagScreen extends StatelessWidget {
  const TagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('태그 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '태그 추가',
            onPressed: () => _showTagDialog(context, null),
          ),
        ],
      ),
      body: Consumer<TagProvider>(
        builder: (context, tagProvider, _) {
          final tags = tagProvider.tags;
          final memoProvider = context.watch<MemoProvider>();

          if (tags.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('태그가 없습니다.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final memoCount = memoProvider.memoCountByTag(tag.id);
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return _TagListItem(
                key: ValueKey(tag.id),
                tag: tag,
                memoCount: memoCount,
                isDark: isDark,
                onEdit: () => _showTagDialog(context, tag),
                onDelete: () => _deleteTag(context, tag),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTagDialog(context, null),
        tooltip: '태그 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 태그 추가/수정 다이얼로그
  Future<void> _showTagDialog(BuildContext context, Tag? existingTag) async {
    final nameController =
        TextEditingController(text: existingTag?.name ?? '');
    MemoColor selectedColor = existingTag?.color ?? MemoColor.blue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = existingTag != null;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? '태그 수정' : '새 태그'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 태그 이름 입력
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '태그 이름',
                  hintText: '태그 이름을 입력하세요',
                ),
                autofocus: true,
                maxLength: 30,
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
                final tagProvider = context.read<TagProvider>();
                if (isEdit) {
                  final updated = existingTag.copyWith(
                    name: name,
                    color: selectedColor,
                  );
                  await tagProvider.updateTag(updated);
                } else {
                  await tagProvider.addTag(
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

  /// 태그 삭제 확인
  Future<void> _deleteTag(BuildContext context, Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('태그 삭제'),
        content:
            Text('"${tag.name}" 태그를 삭제하시겠습니까?\n해당 태그가 붙은 메모에서도 제거됩니다.'),
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
      // 태그 삭제 전 해당 태그가 포함된 메모에서 태그 정보 제거
      await context.read<MemoProvider>().removeTagFromMemos(tag.id);
      if (context.mounted) {
        await context.read<TagProvider>().deleteTag(tag.id);
      }
    }
  }
}

/// 태그 목록 항목 위젯
class _TagListItem extends StatelessWidget {
  final Tag tag;
  final int memoCount;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagListItem({
    super.key,
    required this.tag,
    required this.memoCount,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismissible_${tag.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('태그 삭제'),
            content: Text('"${tag.name}" 태그를 삭제하시겠습니까?'),
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
      onDismissed: (_) => onDelete(),
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
            color: tag.color.getColor(isDark).withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              tag.name.isNotEmpty ? tag.name[0].toUpperCase() : '#',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        title: Text(tag.name),
        subtitle: Text('메모 $memoCount개'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: '수정',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: '삭제',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
