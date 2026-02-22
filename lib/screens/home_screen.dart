import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/enums.dart';
import '../providers/memo_provider.dart';
import '../providers/folder_provider.dart';
import '../utils/csv_export.dart';
import '../widgets/memo_card.dart';

/// 홈 화면 (메모 목록 메인 화면)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  @override
  Widget build(BuildContext context) {
    final memoProvider = context.watch<MemoProvider>();
    final folderProvider = context.watch<FolderProvider>();
    final isMultiSelect = memoProvider.isMultiSelectMode;

    return Scaffold(
      appBar: _buildAppBar(context, memoProvider, folderProvider, isMultiSelect),
      body: Column(
        children: [
          // 폴더 선택 영역
          _FolderChipsRow(
            memoProvider: memoProvider,
            folderProvider: folderProvider,
          ),
          const Divider(height: 1),
          // 메모 목록
          Expanded(
            child: _buildMemoList(context, memoProvider),
          ),
        ],
      ),
      floatingActionButton: isMultiSelect
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/memo/new'),
              tooltip: '새 메모 작성',
              child: const Icon(Icons.add),
            ),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar(
    BuildContext context,
    MemoProvider memoProvider,
    FolderProvider folderProvider,
    bool isMultiSelect,
  ) {
    if (isMultiSelect) {
      return _buildMultiSelectAppBar(context, memoProvider);
    }

    // 현재 선택된 폴더명
    final selectedFolderId = memoProvider.selectedFolderId;
    final folderName = selectedFolderId != null
        ? folderProvider.getFolderById(selectedFolderId)?.name ?? '메모'
        : 'MemoCalendar';

    return AppBar(
      title: Text(folderName),
      actions: [
        // 뷰 전환 버튼
        IconButton(
          icon: Icon(
            memoProvider.viewType == ViewType.list
                ? Icons.grid_view
                : Icons.view_list,
          ),
          tooltip: memoProvider.viewType == ViewType.list ? '그리드 보기' : '리스트 보기',
          onPressed: () {
            memoProvider.setViewType(
              memoProvider.viewType == ViewType.list
                  ? ViewType.grid
                  : ViewType.list,
            );
          },
        ),
        // 정렬 버튼
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          tooltip: '정렬',
          onSelected: (value) => _handleSortMenuSelected(context, memoProvider, value),
          itemBuilder: (context) => _buildSortMenuItems(memoProvider),
        ),
        // 메뉴 버튼
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: '더보기',
          onSelected: (value) {
            switch (value) {
              case 'folders':
                context.push('/folders');
              case 'tags':
                context.push('/tags');
              case 'trash':
                context.push('/trash');
              case 'export_csv':
                _exportCsv(context, memoProvider);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'folders',
              child: Row(
                children: [
                  Icon(Icons.folder_outlined),
                  SizedBox(width: 8),
                  Text('폴더 관리'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'tags',
              child: Row(
                children: [
                  Icon(Icons.label_outline),
                  SizedBox(width: 8),
                  Text('태그 관리'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export_csv',
              child: Row(
                children: [
                  Icon(Icons.download_outlined),
                  SizedBox(width: 8),
                  Text('CSV 내보내기'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'trash',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('휴지통'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 다중 선택 모드 AppBar
  AppBar _buildMultiSelectAppBar(
    BuildContext context,
    MemoProvider memoProvider,
  ) {
    final count = memoProvider.selectedMemoIds.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: memoProvider.exitMultiSelectMode,
      ),
      title: Text('$count개 선택됨'),
      actions: [
        // 전체 선택
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: '전체 선택',
          onPressed: memoProvider.selectAll,
        ),
        // 선택 삭제
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '선택 삭제',
          onPressed: count > 0
              ? () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('메모 삭제'),
                      content: Text('선택한 $count개의 메모를 휴지통으로 이동하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await memoProvider.deleteSelectedMemos();
                  }
                }
              : null,
        ),
      ],
    );
  }

  /// CSV 내보내기
  Future<void> _exportCsv(
      BuildContext context, MemoProvider memoProvider) async {
    final allMemos = memoProvider.memos;
    if (allMemos.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('내보낼 메모가 없습니다.')),
        );
      }
      return;
    }
    try {
      await CsvExport.exportAndShare(allMemos);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내보내기 실패: $e')),
        );
      }
    }
  }

  /// 정렬 메뉴 아이템 빌드
  List<PopupMenuEntry<String>> _buildSortMenuItems(MemoProvider memoProvider) {
    PopupMenuItem<String> sortItem(String value, String label, SortField field) {
      final isSelected = memoProvider.sortField == field;
      return PopupMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check : null,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return [
      sortItem('sort_updatedAt', '수정 일시', SortField.updatedAt),
      sortItem('sort_createdAt', '생성 일시', SortField.createdAt),
      sortItem('sort_title', '제목', SortField.title),
      sortItem('sort_startDate', '날짜', SortField.startDate),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'order_toggle',
        child: Row(
          children: [
            Icon(
              memoProvider.sortOrder == SortOrder.descending
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              memoProvider.sortOrder == SortOrder.descending ? '내림차순' : '오름차순',
            ),
          ],
        ),
      ),
    ];
  }

  /// 정렬 메뉴 선택 처리
  void _handleSortMenuSelected(
    BuildContext context,
    MemoProvider memoProvider,
    String value,
  ) {
    switch (value) {
      case 'sort_updatedAt':
        memoProvider.setSortField(SortField.updatedAt);
      case 'sort_createdAt':
        memoProvider.setSortField(SortField.createdAt);
      case 'sort_title':
        memoProvider.setSortField(SortField.title);
      case 'sort_startDate':
        memoProvider.setSortField(SortField.startDate);
      case 'order_toggle':
        memoProvider.setSortOrder(
          memoProvider.sortOrder == SortOrder.descending
              ? SortOrder.ascending
              : SortOrder.descending,
        );
    }
  }

  /// 메모 목록 빌드
  Widget _buildMemoList(BuildContext context, MemoProvider memoProvider) {
    final memos = memoProvider.memos;

    if (memos.isEmpty) {
      return _buildEmptyState(context);
    }

    if (memoProvider.viewType == ViewType.grid) {
      return _buildGridView(context, memoProvider);
    }

    return _buildListView(context, memoProvider);
  }

  /// 리스트뷰 빌드 (고정 메모 상단, 일반 메모 하단)
  Widget _buildListView(BuildContext context, MemoProvider memoProvider) {
    final pinnedMemos = memoProvider.pinnedMemos;
    final unpinnedMemos = memoProvider.unpinnedMemos;

    return ListView(
      children: [
        // 고정 메모 섹션
        if (pinnedMemos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.push_pin, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '고정됨',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          ...pinnedMemos.map((memo) => MemoCard(memo: memo)),
          if (unpinnedMemos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '메모',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
        ],
        // 일반 메모 섹션
        ...unpinnedMemos.map((memo) => MemoCard(memo: memo)),
        // 하단 여백 (FAB 가림 방지)
        const SizedBox(height: 80),
      ],
    );
  }

  /// 그리드뷰 빌드
  Widget _buildGridView(BuildContext context, MemoProvider memoProvider) {
    final memos = memoProvider.memos;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        itemCount: memos.length,
        itemBuilder: (context, index) {
          return MemoCard(
            memo: memos[index],
            isGrid: true,
          );
        },
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '메모가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '오른쪽 아래 + 버튼을 눌러\n새 메모를 작성해 보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/memo/new'),
            icon: const Icon(Icons.add),
            label: const Text('새 메모 작성'),
          ),
        ],
      ),
    );
  }
}

/// 폴더 선택 칩 행
class _FolderChipsRow extends StatelessWidget {
  final MemoProvider memoProvider;
  final FolderProvider folderProvider;

  const _FolderChipsRow({
    required this.memoProvider,
    required this.folderProvider,
  });

  @override
  Widget build(BuildContext context) {
    final folders = folderProvider.folders;
    final selectedFolderId = memoProvider.selectedFolderId;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          // 전체 칩
          _FolderChip(
            label: '전체',
            count: memoProvider.memoCountByFolder(null),
            isSelected: selectedFolderId == null,
            onTap: () => memoProvider.setSelectedFolder(null),
          ),
          // 폴더 칩 목록
          ...folders.map((folder) => _FolderChip(
                label: folder.name,
                count: memoProvider.memoCountByFolder(folder.id),
                isSelected: selectedFolderId == folder.id,
                onTap: () => memoProvider.setSelectedFolder(folder.id),
              )),
        ],
      ),
    );
  }
}

/// 폴더 선택 칩 위젯
class _FolderChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FolderChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }
}
