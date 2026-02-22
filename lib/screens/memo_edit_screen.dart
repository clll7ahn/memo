import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/checklist_item.dart';
import '../models/enums.dart';
import '../models/memo.dart';
import '../providers/folder_provider.dart';
import '../providers/memo_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tag_provider.dart';

/// 메모 작성 화면
class MemoEditScreen extends StatefulWidget {
  /// 캘린더에서 진입 시 초기 날짜 (선택사항, yyyy-MM-dd 형식)
  final String? initialDate;

  const MemoEditScreen({super.key, this.initialDate});

  @override
  State<MemoEditScreen> createState() => _MemoEditScreenState();
}

class _MemoEditScreenState extends State<MemoEditScreen> {
  static const _uuid = Uuid();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _checklistItemController = TextEditingController();

  MemoColor _color = MemoColor.white;
  String? _selectedFolderId;
  final List<String> _selectedTagIds = [];
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _reminderAt;
  final List<ChecklistItem> _checklistItems = [];

  @override
  void initState() {
    super.initState();
    // 설정에서 기본 색상 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = context.read<SettingsProvider>().settings;
        setState(() => _color = settings.defaultColor);
      }
    });
    // 초기 날짜 파싱 (기본값: 오늘)
    if (widget.initialDate != null) {
      try {
        _startDate = DateTime.parse(widget.initialDate!);
      } catch (_) {
        _startDate = DateTime.now();
      }
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _checklistItemController.dispose();
    super.dispose();
  }

  /// 메모 저장
  Future<void> _saveMemo() async {
    // 제목과 내용이 모두 비어있으면 저장하지 않음
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty &&
        _checklistItems.isEmpty) {
      context.pop();
      return;
    }

    final now = DateTime.now();
    final memo = Memo(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      color: _color,
      folderId: _selectedFolderId,
      tagIds: List.from(_selectedTagIds),
      startDate: _startDate,
      endDate: _endDate,
      reminderAt: _reminderAt,
      checklist: List.from(_checklistItems),
      createdAt: now,
      updatedAt: now,
    );

    await context.read<MemoProvider>().addMemo(memo);
    if (mounted) context.pop();
  }

  /// 색상 변경 다이얼로그
  Future<void> _showColorPicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showDialog<MemoColor>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('색상 선택'),
        content: _ColorPalette(selected: _color, isDark: isDark),
      ),
    );
    if (selected != null && mounted) {
      setState(() => _color = selected);
    }
  }

  /// 날짜 범위 선택
  Future<void> _showDateRangePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null
          ? DateTimeRange(
              start: _startDate!,
              end: _endDate ?? _startDate!,
            )
          : null,
    );
    if (range != null && mounted) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  /// 리마인더 설정
  Future<void> _showReminderPicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderAt != null
          ? TimeOfDay.fromDateTime(_reminderAt!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      _reminderAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  /// 체크리스트 항목 추가
  void _addChecklistItem() {
    final text = _checklistItemController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklistItems.add(ChecklistItem(
        id: _uuid.v4(),
        text: text,
        sortOrder: _checklistItems.length,
      ));
      _checklistItemController.clear();
    });
  }

  /// 체크리스트 항목 삭제
  void _removeChecklistItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item.id == id);
      // 정렬 순서 재정렬
      for (int i = 0; i < _checklistItems.length; i++) {
        _checklistItems[i] = _checklistItems[i].copyWith(sortOrder: i);
      }
    });
  }

  /// 체크리스트 항목 토글
  void _toggleChecklistItem(String id) {
    setState(() {
      final idx = _checklistItems.indexWhere((item) => item.id == id);
      if (idx != -1) {
        _checklistItems[idx] = _checklistItems[idx].copyWith(
          isChecked: !_checklistItems[idx].isChecked,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _color.getColor(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: '취소',
          onPressed: () => context.pop(),
        ),
        title: const Text('새 메모'),
        actions: [
          // 색상 선택 버튼
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: '색상 선택',
            onPressed: _showColorPicker,
          ),
          // 저장 버튼
          TextButton(
            onPressed: _saveMemo,
            child: const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            // 내용 입력
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
              minLines: 5,
            ),
            const Divider(),
            // 폴더 선택
            _buildFolderSection(),
            const SizedBox(height: 8),
            // 태그 선택
            _buildTagSection(),
            const SizedBox(height: 8),
            // 날짜 선택
            _buildDateSection(),
            const SizedBox(height: 8),
            // 리마인더 설정
            _buildReminderSection(),
            const SizedBox(height: 8),
            // 체크리스트
            _buildChecklistSection(),
          ],
        ),
      ),
    );
  }

  /// 폴더 선택 영역
  Widget _buildFolderSection() {
    final folderProvider = context.watch<FolderProvider>();
    final folders = folderProvider.folders;
    final selectedFolder = _selectedFolderId != null
        ? folderProvider.getFolderById(_selectedFolderId!)
        : null;

    return InkWell(
      onTap: () async {
        final selected = await showDialog<_OptionResult<String>>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('폴더 선택'),
            children: [
              SimpleDialogOption(
                onPressed: () =>
                    ctx.pop(const _OptionResult(value: null, selected: true)),
                child: const Text('폴더 없음'),
              ),
              ...folders.map((f) => SimpleDialogOption(
                    onPressed: () => ctx.pop(
                        _OptionResult(value: f.id, selected: true)),
                    child: Text(f.name),
                  )),
            ],
          ),
        );
        if (selected != null && selected.selected && mounted) {
          setState(() => _selectedFolderId = selected.value);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.folder_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              selectedFolder != null ? selectedFolder.name : '폴더 선택',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// 태그 선택 영역
  Widget _buildTagSection() {
    final tagProvider = context.watch<TagProvider>();
    final allTags = tagProvider.tags;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '태그',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        if (allTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: allTags.map((tag) {
                final isSelected = _selectedTagIds.contains(tag.id);
                return FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  backgroundColor: tag.color.getColor(isDark).withValues(alpha: 0.3),
                  selectedColor: tag.color.getColor(isDark).withValues(alpha: 0.7),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTagIds.add(tag.id);
                      } else {
                        _selectedTagIds.remove(tag.id);
                      }
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '태그가 없습니다. 태그 관리에서 추가하세요.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  /// 날짜 선택 영역
  Widget _buildDateSection() {
    String dateText = '날짜 선택';
    if (_startDate != null) {
      if (_endDate != null &&
          !(_startDate!.year == _endDate!.year &&
              _startDate!.month == _endDate!.month &&
              _startDate!.day == _endDate!.day)) {
        dateText =
            '${_startDate!.month}월 ${_startDate!.day}일 ~ ${_endDate!.month}월 ${_endDate!.day}일';
      } else {
        dateText =
            '${_startDate!.year}년 ${_startDate!.month}월 ${_startDate!.day}일';
      }
    }

    return InkWell(
      onTap: _showDateRangePicker,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_startDate != null) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () =>
                    setState(() => _startDate = _endDate = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '날짜 제거',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 리마인더 설정 영역
  Widget _buildReminderSection() {
    String reminderText = '알림 설정';
    if (_reminderAt != null) {
      reminderText =
          '${_reminderAt!.year}년 ${_reminderAt!.month}월 ${_reminderAt!.day}일 '
          '${_reminderAt!.hour.toString().padLeft(2, '0')}:${_reminderAt!.minute.toString().padLeft(2, '0')}';
    }

    return InkWell(
      onTap: _showReminderPicker,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.alarm_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              reminderText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_reminderAt != null) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => setState(() => _reminderAt = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: '알림 제거',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 체크리스트 섹션
  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '체크리스트',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 체크리스트 항목 목록
        ..._checklistItems.map((item) => CheckboxListTile(
              value: item.isChecked,
              onChanged: (_) => _toggleChecklistItem(item.id),
              title: Text(
                item.text,
                style: TextStyle(
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              secondary: IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => _removeChecklistItem(item.id),
                color: Theme.of(context).colorScheme.error,
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            )),
        // 항목 추가 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _checklistItemController,
                decoration: const InputDecoration(
                  hintText: '항목 추가...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onSubmitted: (_) => _addChecklistItem(),
                textInputAction: TextInputAction.done,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addChecklistItem,
              tooltip: '항목 추가',
            ),
          ],
        ),
      ],
    );
  }
}

/// 옵션 선택 결과 헬퍼 클래스
class _OptionResult<T> {
  final T? value;
  final bool selected;
  const _OptionResult({required this.value, required this.selected});
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
                    size: 20, color: Theme.of(context).colorScheme.primary)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
