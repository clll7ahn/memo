import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/memo.dart';
import '../providers/memo_provider.dart';
import '../utils/date_utils.dart';

/// 휴지통 화면
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴지통'),
        actions: [
          // 전체 복구
          TextButton.icon(
            icon: const Icon(Icons.restore_outlined, size: 18),
            label: const Text('전체 복구'),
            onPressed: () => _restoreAll(context),
          ),
          // 전체 삭제
          TextButton.icon(
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('전체 삭제'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _emptyTrash(context),
          ),
        ],
      ),
      body: Consumer<MemoProvider>(
        builder: (context, memoProvider, _) {
          final deletedMemos = memoProvider.deletedMemos;

          return Column(
            children: [
              // 안내 배너
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '30일 후 자동으로 영구 삭제됩니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // 삭제된 메모 목록
              Expanded(
                child: deletedMemos.isEmpty
                    ? const _EmptyTrashView()
                    : ListView.builder(
                        itemCount: deletedMemos.length,
                        itemBuilder: (context, index) {
                          final memo = deletedMemos[index];
                          return _TrashMemoItem(
                            key: ValueKey(memo.id),
                            memo: memo,
                            onRestore: () =>
                                memoProvider.restoreMemo(memo.id),
                            onDelete: () =>
                                _confirmPermanentDelete(context, memo, memoProvider),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 전체 복구 확인
  Future<void> _restoreAll(BuildContext context) async {
    final memoProvider = context.read<MemoProvider>();
    if (memoProvider.deletedMemos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복구할 메모가 없습니다.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('전체 복구'),
        content: const Text('휴지통의 모든 메모를 복구하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('복구'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<MemoProvider>().restoreAllMemos();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 메모가 복구되었습니다.')),
        );
      }
    }
  }

  /// 휴지통 비우기 확인
  Future<void> _emptyTrash(BuildContext context) async {
    final memoProvider = context.read<MemoProvider>();
    if (memoProvider.deletedMemos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴지통이 비어있습니다.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('휴지통 비우기'),
        content: const Text(
          '휴지통의 모든 메모를 영구 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
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
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<MemoProvider>().emptyTrash();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('휴지통이 비워졌습니다.')),
        );
      }
    }
  }

  /// 개별 영구 삭제 확인
  Future<void> _confirmPermanentDelete(
    BuildContext context,
    Memo memo,
    MemoProvider memoProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('영구 삭제'),
        content: Text(
          '"${memo.title.isEmpty ? '(제목 없음)' : memo.title}" 메모를 영구 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
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
            child: const Text('영구 삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await memoProvider.permanentlyDeleteMemo(memo.id);
    }
  }
}

/// 휴지통 빈 상태 뷰
class _EmptyTrashView extends StatelessWidget {
  const _EmptyTrashView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '휴지통이 비어있습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha:0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '삭제된 메모가 여기에 표시됩니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha:0.4),
                ),
          ),
        ],
      ),
    );
  }
}

/// 휴지통 메모 항목 위젯
class _TrashMemoItem extends StatelessWidget {
  final Memo memo;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _TrashMemoItem({
    super.key,
    required this.memo,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = memo.color.getColor(isDark).withValues(alpha:0.4);
    final daysLeft = memo.deletedAt != null
        ? AppDateUtils.daysUntilExpiry(memo.deletedAt!)
        : 30;
    final isExpiringSoon = daysLeft <= 3;

    return Dismissible(
      key: ValueKey('trash_${memo.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('영구 삭제'),
            content: const Text('이 메모를 영구 삭제하시겠습니까?'),
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
                child: const Text('영구 삭제'),
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
          Icons.delete_forever,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: bgColor,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            memo.title.isEmpty ? '(제목 없음)' : memo.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (memo.content.isNotEmpty)
                Text(
                  memo.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha:0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    memo.deletedAt != null
                        ? '삭제: ${AppDateUtils.formatRelativeDate(memo.deletedAt!)}'
                        : '삭제 일시 불명',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha:0.5),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    memo.deletedAt != null
                        ? AppDateUtils.formatDaysUntilExpiry(memo.deletedAt!)
                        : '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isExpiringSoon
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha:0.5),
                          fontWeight: isExpiringSoon ? FontWeight.w600 : null,
                        ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 복구 버튼
              IconButton(
                icon: const Icon(Icons.restore_outlined, size: 22),
                onPressed: onRestore,
                tooltip: '복구',
                color: Theme.of(context).colorScheme.primary,
              ),
              // 영구 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete_forever, size: 22),
                onPressed: onDelete,
                tooltip: '영구 삭제',
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
          onTap: () {
            // 탭 시 복구/영구 삭제 옵션 표시
            showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.restore_outlined),
                      title: const Text('복구'),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onRestore();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever,
                        color: Theme.of(ctx).colorScheme.error,
                      ),
                      title: Text(
                        '영구 삭제',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onDelete();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
