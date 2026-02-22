import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/memo.dart';
import '../providers/memo_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/memo_card.dart';

/// 캘린더 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// 현재 표시 중인 달
  DateTime _focusedDay = DateTime.now();

  /// 선택된 날짜
  DateTime? _selectedDay;

  /// 캘린더 포맷 (월간/주간)
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final memoProvider = context.watch<MemoProvider>();

    // 현재 달의 날짜별 메모 맵
    final memosByMonth = memoProvider.getMemosByMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    // 선택된 날짜의 메모 목록
    final selectedMemos = _selectedDay != null
        ? memoProvider.getMemosByDate(_selectedDay!)
        : <Memo>[];

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 캘린더 위젯
          _buildCalendar(context, memosByMonth),
          const Divider(height: 1),
          // 선택된 날짜 헤더
          _buildSelectedDayHeader(context, selectedMemos),
          // 해당 날짜 메모 목록
          Expanded(
            child: selectedMemos.isEmpty
                ? _buildEmptyDayState(context)
                : ListView.builder(
                    itemCount: selectedMemos.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      return MemoCard(
                        memo: selectedMemos[index],
                        dismissible: false,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 선택된 날짜를 파라미터로 전달
          final dateStr = _selectedDay != null
              ? '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}'
              : null;
          context.push(dateStr != null
              ? '/memo/new?date=$dateStr'
              : '/memo/new');
        },
        tooltip: '새 메모 작성',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// AppBar 빌드
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppDateUtils.formatMonthYear(_focusedDay)),
      actions: [
        // 이전 달 버튼
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: '이전 달',
          onPressed: () {
            setState(() {
              _focusedDay = AppDateUtils.previousMonth(_focusedDay);
            });
          },
        ),
        // 오늘로 이동
        TextButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
          },
          child: const Text('오늘'),
        ),
        // 다음 달 버튼
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: '다음 달',
          onPressed: () {
            setState(() {
              _focusedDay = AppDateUtils.nextMonth(_focusedDay);
            });
          },
        ),
        // 월간/주간 전환 버튼
        IconButton(
          icon: Icon(
            _calendarFormat == CalendarFormat.month
                ? Icons.view_week
                : Icons.calendar_view_month,
          ),
          tooltip: _calendarFormat == CalendarFormat.month ? '주간 보기' : '월간 보기',
          onPressed: () {
            setState(() {
              _calendarFormat = _calendarFormat == CalendarFormat.month
                  ? CalendarFormat.week
                  : CalendarFormat.month;
            });
          },
        ),
      ],
    );
  }

  /// 캘린더 위젯 빌드
  Widget _buildCalendar(
    BuildContext context,
    Map<DateTime, List<Memo>> memosByMonth,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TableCalendar<Memo>(
      locale: 'ko_KR',
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      // 날짜 선택 이벤트
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      // 달 변경 이벤트
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      // 포맷 변경 이벤트
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      // 이벤트 로더 - 날짜별 메모 반환
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return memosByMonth[key] ?? [];
      },
      // 캘린더 스타일
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        // 오늘 날짜 스타일
        todayDecoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha:0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        // 선택된 날짜 스타일
        selectedDecoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        // 주말 색상
        weekendTextStyle: TextStyle(
          color: isDark ? Colors.red[300] : Colors.red[700],
        ),
        // 이벤트 도트 스타일
        markerDecoration: BoxDecoration(
          color: colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markerSize: 6,
        markersMaxCount: 3,
        markersOffset: const PositionedOffset(bottom: 1),
      ),
      // 헤더 스타일
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: SizedBox.shrink(),
        rightChevronIcon: SizedBox.shrink(),
      ),
      // 요일 헤더 스타일
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.red[300] : Colors.red[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 선택된 날짜 헤더 빌드
  Widget _buildSelectedDayHeader(BuildContext context, List<Memo> memos) {
    final hasSelectedDay = _selectedDay != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            hasSelectedDay
                ? AppDateUtils.formatDateWithWeekday(_selectedDay!)
                : '날짜를 선택하세요',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          if (memos.isNotEmpty)
            Text(
              '${memos.length}개',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
        ],
      ),
    );
  }

  /// 해당 날짜에 메모 없음 상태
  Widget _buildEmptyDayState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 60,
            color: Colors.grey.withValues(alpha:0.5),
          ),
          const SizedBox(height: 12),
          Text(
            '이 날짜에 메모가 없습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              final dateStr = _selectedDay != null
                  ? '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}'
                  : null;
              context.push(dateStr != null
                  ? '/memo/new?date=$dateStr'
                  : '/memo/new');
            },
            icon: const Icon(Icons.add),
            label: const Text('이 날 메모 추가'),
          ),
        ],
      ),
    );
  }
}
