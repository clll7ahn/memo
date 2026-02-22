import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/enums.dart';
import '../models/memo.dart';

/// 메모 목록을 CSV 파일로 내보내기
class CsvExport {
  CsvExport._();

  /// CSV 필드 이스케이프 처리
  static String _escapeField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// 날짜 포맷
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// 메모 목록을 CSV 문자열로 변환
  static String _toCsvString(List<Memo> memos) {
    final buffer = StringBuffer();

    // BOM (엑셀 한국어 호환)
    buffer.write('\uFEFF');

    // 헤더
    buffer.writeln(
      '제목,내용,색상,고정,즐겨찾기,시작일,종료일,체크리스트,생성일,수정일',
    );

    // 데이터 행
    for (final memo in memos) {
      final checklistText = memo.checklist.isNotEmpty
          ? memo.checklist
              .map((item) => '${item.isChecked ? "[v]" : "[ ]"} ${item.text}')
              .join(' / ')
          : '';

      final row = [
        _escapeField(memo.title),
        _escapeField(memo.content),
        memo.color.label,
        memo.isPinned ? 'Y' : 'N',
        memo.isFavorite ? 'Y' : 'N',
        _formatDate(memo.startDate),
        _formatDate(memo.endDate),
        _escapeField(checklistText),
        _formatDate(memo.createdAt),
        _formatDate(memo.updatedAt),
      ].join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  /// 메모 목록을 CSV 파일로 내보내기 (공유 시트)
  static Future<void> exportAndShare(List<Memo> memos) async {
    final csvString = _toCsvString(memos);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '메모_$timestamp.csv';

    // 임시 디렉토리에 파일 저장
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvString);

    // 공유 시트로 파일 공유
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '메모 내보내기',
    );
  }
}
