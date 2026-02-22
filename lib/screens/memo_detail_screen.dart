import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/checklist_item.dart';
import '../models/enums.dart';
import '../models/memo.dart';
import '../providers/folder_provider.dart';
import '../providers/memo_provider.dart';
import '../providers/tag_provider.dart';
import '../utils/date_utils.dart';

/// 메모 상세/수정 화면
class MemoDetailScreen extends StatefulWidget {
  final String memoId;

  const MemoDetailScreen({super.key, required this.memoId});

  @override
  State<MemoDetailScreen> createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 편집 모드 시작
  void _startEditing(Memo memo) {
    _titleController.text = memo.title;
    _contentController.text = memo.content;
    setState(() => _isEditing = true);
  }

  /// 메모 저장
  Future<void> _saveMemo(Memo memo) async {
    final updated = memo.copyWith(
      title: _titleController.text,
      content: _contentController.text,
    );
    await context.read<MemoProvider>().updateMemo(updated);
    if (mounted) {
      setState(() => _isEditing = false);
    }
  }

  /// 메모 삭제 확인 후 삭제
  Future<void> _deleteMemo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('이 메모를 휴지통으로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<MemoProvider>().deleteMemo(widget.memoId);
      if (mounted) context.pop();
    }
  }

  /// 색상 변경 다이얼로그
  Future<void> _showColorPicker(Memo memo) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showDialog<MemoColor>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('색상 변경'),
        content: _ColorPalette(selected: memo.color, isDark: isDark),
      ),
    );
    if (selected != null && mounted) {
      final updated = memo.copyWith(color: selected);
      await context.read<MemoProvider>().updateMemo(updated);
    }
  }

  /// 날짜 선택 다이얼로그
  Future<void> _showDatePicker(Memo memo) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: memo.startDate != null
          ? DateTimeRange(
              start: memo.startDate!,
              end: memo.endDate ?? memo.startDate!,
            )
          : null,
    );
    if (range != null && mounted) {
      final updated = memo.copyWith(
        startDate: range.start,
        endDate: range.end,
      );
      await context.read<MemoProvider>().updateMemo(updated);
    }
  }

  /// 리마인더 설정
  Future<void> _showReminderPicker(Memo memo) async {
    final date = await showDatePicker(
      context: context,
      initialDate: memo.reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: memo.reminderAt != null
          ? TimeOfDay.fromDateTime(memo.reminderAt!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    final reminderAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    final updated = memo.copyWith(reminderAt: reminderAt);
    await context.read<MemoProvider>().updateMemo(updated);
  }

  /// 체크리스트 항목 토글
  Future<void> _toggleChecklistItem(Memo memo, ChecklistItem item) async {
    final updated = memo.copyWith(
      checklist: memo.checklist
          .map((c) => c.id == item.id
              ? c.copyWith(isChecked: !c.isChecked)
              : c)
          .toList(),
    );
    await context.read<MemoProvider>().updateMemo(updated);
  }

  /// 폴더 선택 다이얼로그
  Future<void> _showFolderPicker(Memo memo) async {
    final folderProvider = context.read<FolderProvider>();
    final folders = folderProvider.folders;
    final selected = await showDialog<_FolderResult>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('폴더 선택'),
        children: [
          SimpleDialogOption(
            onPressed: () => ctx.pop(const _FolderResult(id: null, selected: true)),
            child: const Text('폴더 없음'),
          ),
          ...folders.map((f) => SimpleDialogOption(
                onPressed: () =>
                    ctx.pop(_FolderResult(id: f.id, selected: true)),
                child: Text(f.name),
              )),
        ],
      ),
    );
    if (selected != null && selected.selected && mounted) {
      final updated = memo.copyWith(folderId: selected.id);
      await context.read<MemoProvider>().updateMemo(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoProvider>(
      builder: (context, memoProvider, _) {
        final memo = memoProvider.getMemoById(widget.memoId);
        if (memo == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: Text('메모를 찾을 수 없습니다.')),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = memo.color.getColor(isDark);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildAppBar(context, memo, memoProvider),
          body: _buildBody(context, memo),
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context, Memo memo, MemoProvider memoProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          final nav = Navigator.of(context);
          if (_isEditing) await _saveMemo(memo);
          if (mounted) nav.pop();
        },
      ),
      actions: [
        // 즐겨찾기 토글
        IconButton(
          icon: Icon(
            memo.isFavorite ? Icons.star : Icons.star_border,
            color: memo.isFavorite ? Colors.amber : null,
          ),
          tooltip: memo.isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
          onPressed: () => memoProvider.toggleFavorite(memo.id),
        ),
        // 고정(핀) 토글
        IconButton(
          icon: Icon(
            memo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: memo.isPinned
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          tooltip: memo.isPinned ? '고정 해제' : '고정',
          onPressed: () => memoProvider.togglePin(memo.id),
        ),
        // 편집/완료 토글
        IconButton(
          icon: Icon(_isEditing ? Icons.done : Icons.edit_outlined),
          tooltip: _isEditing ? '저장' : '편집',
          onPressed: _isEditing
              ? () => _saveMemo(memo)
              : () => _startEditing(memo),
        ),
        // 더보기 메뉴
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'share':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 기능은 준비 중입니다.')),
                );
              case 'color':
                _showColorPicker(memo);
              case 'delete':
                _deleteMemo();
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('공유'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'color',
              child: ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text('색상 변경'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('삭제'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Memo memo) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                if (_isEditing)
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      hintText: '제목',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                  )
                else
                  Text(
                    memo.title.isEmpty ? '(제목 없음)' : memo.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 8),
                // 내용
                if (_isEditing)
                  TextField(
                    controller: _contentController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                  )
                else
                  Text(
                    memo.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                // 체크리스트
                if (memo.checklist.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildChecklist(context, memo),
                ],
              ],
            ),
          ),
        ),
        // 하단 메타 정보
        _buildMetaInfo(context, memo),
      ],
    );
  }

  Widget _buildChecklist(BuildContext context, Memo memo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '체크리스트 (${memo.checklistCheckedCount}/${memo.checklist.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...memo.checklist.map((item) => CheckboxListTile(
              value: item.isChecked,
              onChanged: (_) => _toggleChecklistItem(memo, item),
              title: Text(
                item.text,
                style: TextStyle(
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            )),
      ],
    );
  }

  Widget _buildMetaInfo(BuildContext context, Memo memo) {
    final folderProvider = context.watch<FolderProvider>();
    final tagProvider = context.watch<TagProvider>();
    final folder = memo.folderId != null
        ? folderProvider.getFolderById(memo.folderId!)
        : null;
    final tags = tagProvider.getTagsByIds(memo.tagIds);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날짜
            InkWell(
              onTap: () => _showDatePicker(memo),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      memo.startDate != null
                          ? AppDateUtils.formatDateRange(
                              memo.startDate!, memo.endDate)
                          : '날짜 없음',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            // 리마인더
            InkWell(
              onTap: () => _showReminderPicker(memo),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.alarm_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      memo.reminderAt != null
                          ? AppDateUtils.formatDateTime(memo.reminderAt!)
                          : '알림 없음',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            // 폴더
            InkWell(
              onTap: () => _showFolderPicker(memo),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      folder != null ? folder.name : '폴더 없음',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            // 태그
            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag.name),
                      backgroundColor:
                          tag.color.getColor(isDark).withValues(alpha: 0.6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ),
            // 수정 일시
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '수정: ${AppDateUtils.formatRelativeDate(memo.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 폴더 선택 결과 헬퍼 클래스
class _FolderResult {
  final String? id;
  final bool selected;
  const _FolderResult({required this.id, required this.selected});
}

/// 색상 팔레트 위젯
class _ColorPalette extends StatelessWidget {
  final MemoColor selected;
  final bool isDark;

  const _ColorPalette({required this.selected, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MemoColor.values.map((color) {
        final c = color.getColor(isDark);
        final isSelected = color == selected;
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
