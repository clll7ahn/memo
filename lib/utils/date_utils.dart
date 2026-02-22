import 'package:intl/intl.dart';

/// 날짜 관련 유틸리티 함수 모음
class AppDateUtils {
  AppDateUtils._(); // 인스턴스 생성 방지

  // ============================
  // 날짜 비교
  // ============================

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 주어진 날짜가 오늘인지 확인
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// 주어진 날짜가 어제인지 확인
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// 주어진 날짜가 이번 주인지 확인 (월~일 기준)
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
  }

  /// 주어진 날짜가 이번 달인지 확인
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // ============================
  // 날짜 포맷
  // ============================

  /// 전체 날짜 형식: 2026년 2월 22일
  static String formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일', 'ko').format(date);
  }

  /// 짧은 날짜 형식: 2.22 또는 2026.2.22 (연도가 다를 경우)
  static String formatShortDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year) {
      return DateFormat('M월 d일', 'ko').format(date);
    }
    return DateFormat('yyyy년 M월 d일', 'ko').format(date);
  }

  /// 상대적 날짜 형식 반환: 방금 전, 1시간 전, 어제, 날짜 등
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24 && isToday(date)) {
      return '${diff.inHours}시간 전';
    } else if (isYesterday(date)) {
      return '어제';
    } else if (isThisWeek(date)) {
      return weekdayName(date.weekday);
    } else {
      return formatShortDate(date);
    }
  }

  /// 날짜와 요일 포함 형식: 2026년 2월 22일 (일)
  static String formatDateWithWeekday(DateTime date) {
    return '${formatDate(date)} (${weekdayName(date.weekday)})';
  }

  /// 시간 포함 날짜 형식: 2026년 2월 22일 오전 9:30
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy년 M월 d일 a h:mm', 'ko').format(date);
  }

  /// 시간만 표시: 오전 9:30
  static String formatTime(DateTime date) {
    return DateFormat('a h:mm', 'ko').format(date);
  }

  /// 월/년 표시: 2026년 2월
  static String formatMonthYear(DateTime date) {
    return DateFormat('yyyy년 M월', 'ko').format(date);
  }

  // ============================
  // 요일 이름
  // ============================

  /// 요일 번호로 한국어 요일명 반환 (1=월, 7=일)
  static String weekdayName(int weekday) {
    const names = ['월', '화', '수', '목', '금', '토', '일'];
    return names[(weekday - 1) % 7];
  }

  /// 전체 요일명 반환 (1=월요일, 7=일요일)
  static String weekdayFullName(int weekday) {
    const names = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return names[(weekday - 1) % 7];
  }

  // ============================
  // 날짜 범위
  // ============================

  /// 두 날짜 사이의 일수 반환 (절대값)
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays.abs();
  }

  /// 날짜 범위를 문자열로 반환: 2월 22일 ~ 2월 25일
  static String formatDateRange(DateTime start, DateTime? end) {
    if (end == null || isSameDay(start, end)) {
      return formatShortDate(start);
    }
    return '${formatShortDate(start)} ~ ${formatShortDate(end)}';
  }

  /// 휴지통 만료까지 남은 일수 반환
  static int daysUntilExpiry(DateTime deletedAt) {
    const expiryDays = 30;
    final expiryDate = deletedAt.add(const Duration(days: expiryDays));
    final now = DateTime.now();
    final remaining = expiryDate.difference(now).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// 남은 만료 일수 문자열 반환
  static String formatDaysUntilExpiry(DateTime deletedAt) {
    final days = daysUntilExpiry(deletedAt);
    if (days == 0) {
      return '오늘 영구 삭제 예정';
    }
    return '$days일 후 영구 삭제';
  }

  // ============================
  // 월 관련
  // ============================

  /// 해당 월의 첫 날 반환
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 해당 월의 마지막 날 반환
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 이전 달 반환
  static DateTime previousMonth(DateTime date) {
    if (date.month == 1) {
      return DateTime(date.year - 1, 12);
    }
    return DateTime(date.year, date.month - 1);
  }

  /// 다음 달 반환
  static DateTime nextMonth(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1);
    }
    return DateTime(date.year, date.month + 1);
  }
}
