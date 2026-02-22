// MemoCalendar 앱 단위 테스트
// 모델, 유틸리티 함수에 대한 단위 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memo/models/checklist_item.dart';
import 'package:memo/models/enums.dart';
import 'package:memo/models/folder.dart';
import 'package:memo/models/memo.dart';
import 'package:memo/models/tag.dart';
import 'package:memo/utils/date_utils.dart';

void main() {
  // intl 한국어 로케일 초기화
  setUpAll(() async {
    await initializeDateFormatting('ko', null);
  });

  // ============================
  // ChecklistItem 모델 테스트
  // ============================
  group('ChecklistItem 모델', () {
    test('기본 생성 확인', () {
      const item = ChecklistItem(
        id: 'item-1',
        text: '할 일 1',
        sortOrder: 0,
      );

      expect(item.id, 'item-1');
      expect(item.text, '할 일 1');
      expect(item.isChecked, false);
      expect(item.sortOrder, 0);
    });

    test('isChecked=true로 생성', () {
      const item = ChecklistItem(
        id: 'item-2',
        text: '완료된 항목',
        isChecked: true,
        sortOrder: 1,
      );

      expect(item.isChecked, true);
    });

    test('JSON 직렬화 (toJson)', () {
      const item = ChecklistItem(
        id: 'item-3',
        text: '테스트',
        isChecked: false,
        sortOrder: 2,
      );

      final json = item.toJson();

      expect(json['id'], 'item-3');
      expect(json['text'], '테스트');
      expect(json['isChecked'], false);
      expect(json['sortOrder'], 2);
    });

    test('JSON 역직렬화 (fromJson)', () {
      final json = {
        'id': 'item-4',
        'text': '복원된 항목',
        'isChecked': true,
        'sortOrder': 3,
      };

      final item = ChecklistItem.fromJson(json);

      expect(item.id, 'item-4');
      expect(item.text, '복원된 항목');
      expect(item.isChecked, true);
      expect(item.sortOrder, 3);
    });

    test('fromJson 기본값 처리 (isChecked 없을 때)', () {
      final json = {
        'id': 'item-5',
        'text': '기본값 테스트',
        'sortOrder': 0,
      };

      final item = ChecklistItem.fromJson(json);

      expect(item.isChecked, false);
    });

    test('copyWith - 특정 필드 변경', () {
      const original = ChecklistItem(
        id: 'item-6',
        text: '원본',
        isChecked: false,
        sortOrder: 0,
      );

      final updated = original.copyWith(isChecked: true, text: '수정됨');

      expect(updated.id, 'item-6');
      expect(updated.text, '수정됨');
      expect(updated.isChecked, true);
      expect(updated.sortOrder, 0);
    });

    test('동등성 비교 (==)', () {
      const item1 = ChecklistItem(
        id: 'same-id',
        text: '동일 텍스트',
        isChecked: false,
        sortOrder: 0,
      );
      const item2 = ChecklistItem(
        id: 'same-id',
        text: '동일 텍스트',
        isChecked: false,
        sortOrder: 0,
      );

      expect(item1, equals(item2));
    });

    test('toString 형식 확인', () {
      const item = ChecklistItem(
        id: 'id-str',
        text: '스트링 테스트',
        isChecked: false,
        sortOrder: 0,
      );

      expect(item.toString(), contains('id-str'));
      expect(item.toString(), contains('스트링 테스트'));
    });
  });

  // ============================
  // Memo 모델 테스트
  // ============================
  group('Memo 모델', () {
    final now = DateTime(2026, 2, 22, 12, 0, 0);

    test('기본 생성 확인', () {
      final memo = Memo(
        id: 'memo-1',
        title: '테스트 메모',
        content: '내용입니다',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.id, 'memo-1');
      expect(memo.title, '테스트 메모');
      expect(memo.content, '내용입니다');
      expect(memo.color, MemoColor.white);
      expect(memo.isPinned, false);
      expect(memo.isFavorite, false);
      expect(memo.isDeleted, false);
      expect(memo.tagIds, isEmpty);
      expect(memo.checklist, isEmpty);
      expect(memo.reminderRepeat, ReminderRepeat.none);
    });

    test('JSON 직렬화 (toJson)', () {
      final memo = Memo(
        id: 'memo-2',
        title: '직렬화 테스트',
        content: '내용',
        color: MemoColor.yellow,
        folderId: 'folder-1',
        tagIds: ['tag-1', 'tag-2'],
        isPinned: true,
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = memo.toJson();

      expect(json['id'], 'memo-2');
      expect(json['title'], '직렬화 테스트');
      expect(json['content'], '내용');
      expect(json['color'], 'yellow');
      expect(json['folderId'], 'folder-1');
      expect(json['tagIds'], ['tag-1', 'tag-2']);
      expect(json['isPinned'], true);
      expect(json['isFavorite'], true);
      expect(json['createdAt'], now.toIso8601String());
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('JSON 역직렬화 (fromJson)', () {
      final json = {
        'id': 'memo-3',
        'title': '역직렬화 테스트',
        'content': '복원된 내용',
        'color': 'green',
        'folderId': 'folder-2',
        'tagIds': ['tag-3'],
        'isPinned': false,
        'isFavorite': true,
        'isDeleted': false,
        'reminderRepeat': 'daily',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final memo = Memo.fromJson(json);

      expect(memo.id, 'memo-3');
      expect(memo.title, '역직렬화 테스트');
      expect(memo.content, '복원된 내용');
      expect(memo.color, MemoColor.green);
      expect(memo.folderId, 'folder-2');
      expect(memo.tagIds, ['tag-3']);
      expect(memo.isFavorite, true);
      expect(memo.reminderRepeat, ReminderRepeat.daily);
    });

    test('fromJson - 체크리스트 포함', () {
      final json = {
        'id': 'memo-4',
        'title': '체크리스트 메모',
        'content': '',
        'checklist': [
          {
            'id': 'cl-1',
            'text': '항목 1',
            'isChecked': true,
            'sortOrder': 0,
          },
          {
            'id': 'cl-2',
            'text': '항목 2',
            'isChecked': false,
            'sortOrder': 1,
          },
        ],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final memo = Memo.fromJson(json);

      expect(memo.checklist.length, 2);
      expect(memo.checklist[0].text, '항목 1');
      expect(memo.checklist[0].isChecked, true);
      expect(memo.checklist[1].text, '항목 2');
      expect(memo.checklist[1].isChecked, false);
    });

    test('checklistProgress - 빈 체크리스트', () {
      final memo = Memo(
        id: 'memo-5',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.checklistProgress, 0.0);
    });

    test('checklistProgress - 50% 완료', () {
      final memo = Memo(
        id: 'memo-6',
        checklist: const [
          ChecklistItem(id: 'cl-1', text: '항목1', isChecked: true, sortOrder: 0),
          ChecklistItem(id: 'cl-2', text: '항목2', isChecked: false, sortOrder: 1),
        ],
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.checklistProgress, 0.5);
    });

    test('checklistProgress - 100% 완료', () {
      final memo = Memo(
        id: 'memo-7',
        checklist: const [
          ChecklistItem(id: 'cl-1', text: '항목1', isChecked: true, sortOrder: 0),
          ChecklistItem(id: 'cl-2', text: '항목2', isChecked: true, sortOrder: 1),
        ],
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.checklistProgress, 1.0);
    });

    test('checklistCheckedCount', () {
      final memo = Memo(
        id: 'memo-8',
        checklist: const [
          ChecklistItem(id: 'cl-1', text: '항목1', isChecked: true, sortOrder: 0),
          ChecklistItem(id: 'cl-2', text: '항목2', isChecked: true, sortOrder: 1),
          ChecklistItem(id: 'cl-3', text: '항목3', isChecked: false, sortOrder: 2),
        ],
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.checklistCheckedCount, 2);
    });

    test('hasReminder - reminderAt가 null인 경우', () {
      final memo = Memo(
        id: 'memo-9',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.hasReminder, false);
    });

    test('hasReminder - reminderAt가 설정된 경우', () {
      final memo = Memo(
        id: 'memo-10',
        reminderAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.hasReminder, true);
    });

    test('hasDate - startDate가 null인 경우', () {
      final memo = Memo(
        id: 'memo-11',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.hasDate, false);
    });

    test('hasDate - startDate가 설정된 경우', () {
      final memo = Memo(
        id: 'memo-12',
        startDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.hasDate, true);
    });

    test('copyWith - 기본 필드 변경', () {
      final original = Memo(
        id: 'memo-orig',
        title: '원본 제목',
        content: '원본 내용',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        title: '수정된 제목',
        isPinned: true,
      );

      expect(updated.id, 'memo-orig');
      expect(updated.title, '수정된 제목');
      expect(updated.content, '원본 내용');
      expect(updated.isPinned, true);
    });

    test('copyWith - nullable 필드를 null로 설정', () {
      final original = Memo(
        id: 'memo-null',
        folderId: 'folder-1',
        reminderAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        folderId: null,
        reminderAt: null,
      );

      expect(updated.folderId, isNull);
      expect(updated.reminderAt, isNull);
    });

    test('동등성 비교 (==)', () {
      final memo1 = Memo(
        id: 'same-memo',
        title: '동일',
        createdAt: now,
        updatedAt: now,
      );
      final memo2 = Memo(
        id: 'same-memo',
        title: '동일',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo1, equals(memo2));
    });

    test('toString 형식 확인', () {
      final memo = Memo(
        id: 'str-memo',
        title: '스트링',
        createdAt: now,
        updatedAt: now,
      );

      expect(memo.toString(), contains('str-memo'));
      expect(memo.toString(), contains('스트링'));
    });
  });

  // ============================
  // Folder 모델 테스트
  // ============================
  group('Folder 모델', () {
    final now = DateTime(2026, 2, 22);

    test('기본 생성 확인', () {
      final folder = Folder(
        id: 'folder-1',
        name: '업무',
        createdAt: now,
        updatedAt: now,
      );

      expect(folder.id, 'folder-1');
      expect(folder.name, '업무');
      expect(folder.color, MemoColor.blue);
      expect(folder.sortOrder, 0);
      expect(folder.isDefault, false);
    });

    test('JSON 직렬화 (toJson)', () {
      final folder = Folder(
        id: 'folder-2',
        name: '개인',
        color: MemoColor.pink,
        sortOrder: 1,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = folder.toJson();

      expect(json['id'], 'folder-2');
      expect(json['name'], '개인');
      expect(json['color'], 'pink');
      expect(json['sortOrder'], 1);
      expect(json['isDefault'], true);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('JSON 역직렬화 (fromJson)', () {
      final json = {
        'id': 'folder-3',
        'name': '취미',
        'color': 'purple',
        'sortOrder': 2,
        'isDefault': false,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final folder = Folder.fromJson(json);

      expect(folder.id, 'folder-3');
      expect(folder.name, '취미');
      expect(folder.color, MemoColor.purple);
      expect(folder.sortOrder, 2);
      expect(folder.isDefault, false);
    });

    test('fromJson 기본값 처리 (color 없을 때)', () {
      final json = {
        'id': 'folder-4',
        'name': '기본값',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final folder = Folder.fromJson(json);

      expect(folder.color, MemoColor.blue);
      expect(folder.sortOrder, 0);
      expect(folder.isDefault, false);
    });

    test('copyWith - 특정 필드 변경', () {
      final original = Folder(
        id: 'folder-orig',
        name: '원본 폴더',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        name: '수정된 폴더',
        color: MemoColor.red,
        sortOrder: 5,
      );

      expect(updated.id, 'folder-orig');
      expect(updated.name, '수정된 폴더');
      expect(updated.color, MemoColor.red);
      expect(updated.sortOrder, 5);
    });

    test('동등성 비교 (==)', () {
      final folder1 = Folder(
        id: 'same-folder',
        name: '동일 폴더',
        createdAt: now,
        updatedAt: now,
      );
      final folder2 = Folder(
        id: 'same-folder',
        name: '동일 폴더',
        createdAt: now,
        updatedAt: now,
      );

      expect(folder1, equals(folder2));
    });

    test('toString 형식 확인', () {
      final folder = Folder(
        id: 'str-folder',
        name: '스트링 폴더',
        createdAt: now,
        updatedAt: now,
      );

      expect(folder.toString(), contains('str-folder'));
      expect(folder.toString(), contains('스트링 폴더'));
    });
  });

  // ============================
  // Tag 모델 테스트
  // ============================
  group('Tag 모델', () {
    final now = DateTime(2026, 2, 22);

    test('기본 생성 확인', () {
      final tag = Tag(
        id: 'tag-1',
        name: '중요',
        createdAt: now,
      );

      expect(tag.id, 'tag-1');
      expect(tag.name, '중요');
      expect(tag.color, MemoColor.blue);
    });

    test('색상 지정 생성', () {
      final tag = Tag(
        id: 'tag-2',
        name: '긴급',
        color: MemoColor.red,
        createdAt: now,
      );

      expect(tag.color, MemoColor.red);
    });

    test('JSON 직렬화 (toJson)', () {
      final tag = Tag(
        id: 'tag-3',
        name: '업무',
        color: MemoColor.teal,
        createdAt: now,
      );

      final json = tag.toJson();

      expect(json['id'], 'tag-3');
      expect(json['name'], '업무');
      expect(json['color'], 'teal');
      expect(json['createdAt'], now.toIso8601String());
    });

    test('JSON 역직렬화 (fromJson)', () {
      final json = {
        'id': 'tag-4',
        'name': '개인',
        'color': 'orange',
        'createdAt': now.toIso8601String(),
      };

      final tag = Tag.fromJson(json);

      expect(tag.id, 'tag-4');
      expect(tag.name, '개인');
      expect(tag.color, MemoColor.orange);
    });

    test('fromJson 기본값 처리 (color 없을 때)', () {
      final json = {
        'id': 'tag-5',
        'name': '기본색',
        'createdAt': now.toIso8601String(),
      };

      final tag = Tag.fromJson(json);

      expect(tag.color, MemoColor.blue);
    });

    test('copyWith - 특정 필드 변경', () {
      final original = Tag(
        id: 'tag-orig',
        name: '원본 태그',
        createdAt: now,
      );

      final updated = original.copyWith(
        name: '수정된 태그',
        color: MemoColor.lime,
      );

      expect(updated.id, 'tag-orig');
      expect(updated.name, '수정된 태그');
      expect(updated.color, MemoColor.lime);
    });

    test('동등성 비교 (==)', () {
      final tag1 = Tag(id: 'same-tag', name: '동일', createdAt: now);
      final tag2 = Tag(id: 'same-tag', name: '동일', createdAt: now);

      expect(tag1, equals(tag2));
    });

    test('toString 형식 확인', () {
      final tag = Tag(id: 'str-tag', name: '스트링 태그', createdAt: now);

      expect(tag.toString(), contains('str-tag'));
      expect(tag.toString(), contains('스트링 태그'));
    });
  });

  // ============================
  // Enums 테스트
  // ============================
  group('MemoColor 열거형', () {
    test('value getter - 각 색상의 문자열 값', () {
      expect(MemoColor.white.value, 'white');
      expect(MemoColor.yellow.value, 'yellow');
      expect(MemoColor.green.value, 'green');
      expect(MemoColor.blue.value, 'blue');
      expect(MemoColor.purple.value, 'purple');
      expect(MemoColor.pink.value, 'pink');
      expect(MemoColor.red.value, 'red');
      expect(MemoColor.orange.value, 'orange');
      expect(MemoColor.teal.value, 'teal');
      expect(MemoColor.indigo.value, 'indigo');
      expect(MemoColor.lime.value, 'lime');
      expect(MemoColor.gray.value, 'gray');
    });

    test('label getter - 한국어 이름', () {
      expect(MemoColor.white.label, '흰색');
      expect(MemoColor.yellow.label, '노란색');
      expect(MemoColor.green.label, '초록색');
      expect(MemoColor.blue.label, '파란색');
      expect(MemoColor.purple.label, '보라색');
      expect(MemoColor.pink.label, '분홍색');
      expect(MemoColor.red.label, '빨간색');
      expect(MemoColor.orange.label, '주황색');
      expect(MemoColor.teal.label, '청록색');
      expect(MemoColor.indigo.label, '남색');
      expect(MemoColor.lime.label, '라임색');
      expect(MemoColor.gray.label, '회색');
    });

    test('toMemoColor() - 문자열에서 변환', () {
      expect('white'.toMemoColor(), MemoColor.white);
      expect('yellow'.toMemoColor(), MemoColor.yellow);
      expect('green'.toMemoColor(), MemoColor.green);
      expect('blue'.toMemoColor(), MemoColor.blue);
      expect('red'.toMemoColor(), MemoColor.red);
    });

    test('toMemoColor() - 알 수 없는 값은 white 반환', () {
      expect('unknown'.toMemoColor(), MemoColor.white);
      expect(''.toMemoColor(), MemoColor.white);
    });

    test('lightColor - 색상 값 확인', () {
      // 반환값이 Color 타입인지 확인
      expect(MemoColor.white.lightColor.toARGB32(), isNonZero);
      expect(MemoColor.blue.lightColor.toARGB32(), isNonZero);
    });

    test('darkColor - 색상 값 확인', () {
      expect(MemoColor.white.darkColor.toARGB32(), isNonZero);
      expect(MemoColor.blue.darkColor.toARGB32(), isNonZero);
    });

    test('getColor - isDark에 따른 색상 반환', () {
      expect(MemoColor.white.getColor(false), MemoColor.white.lightColor);
      expect(MemoColor.white.getColor(true), MemoColor.white.darkColor);
    });
  });

  group('ReminderRepeat 열거형', () {
    test('value getter', () {
      expect(ReminderRepeat.none.value, 'none');
      expect(ReminderRepeat.daily.value, 'daily');
      expect(ReminderRepeat.weekly.value, 'weekly');
      expect(ReminderRepeat.monthly.value, 'monthly');
    });

    test('label getter - 한국어 이름', () {
      expect(ReminderRepeat.none.label, '없음');
      expect(ReminderRepeat.daily.label, '매일');
      expect(ReminderRepeat.weekly.label, '매주');
      expect(ReminderRepeat.monthly.label, '매월');
    });

    test('toReminderRepeat() - 문자열에서 변환', () {
      expect('none'.toReminderRepeat(), ReminderRepeat.none);
      expect('daily'.toReminderRepeat(), ReminderRepeat.daily);
      expect('weekly'.toReminderRepeat(), ReminderRepeat.weekly);
      expect('monthly'.toReminderRepeat(), ReminderRepeat.monthly);
    });

    test('toReminderRepeat() - 알 수 없는 값은 none 반환', () {
      expect('unknown'.toReminderRepeat(), ReminderRepeat.none);
    });
  });

  group('ViewType 열거형', () {
    test('value getter', () {
      expect(ViewType.list.value, 'list');
      expect(ViewType.grid.value, 'grid');
      expect(ViewType.calendar.value, 'calendar');
    });

    test('label getter - 한국어 이름', () {
      expect(ViewType.list.label, '리스트');
      expect(ViewType.grid.label, '그리드');
      expect(ViewType.calendar.label, '캘린더');
    });

    test('toViewType() - 문자열에서 변환', () {
      expect('list'.toViewType(), ViewType.list);
      expect('grid'.toViewType(), ViewType.grid);
      expect('calendar'.toViewType(), ViewType.calendar);
    });

    test('toViewType() - 알 수 없는 값은 list 반환', () {
      expect('unknown'.toViewType(), ViewType.list);
    });
  });

  group('SortField 열거형', () {
    test('value getter', () {
      expect(SortField.updatedAt.value, 'updatedAt');
      expect(SortField.createdAt.value, 'createdAt');
      expect(SortField.title.value, 'title');
      expect(SortField.startDate.value, 'startDate');
    });

    test('label getter - 한국어 이름', () {
      expect(SortField.updatedAt.label, '수정 일시');
      expect(SortField.createdAt.label, '생성 일시');
      expect(SortField.title.label, '제목');
      expect(SortField.startDate.label, '날짜');
    });

    test('toSortField() - 문자열에서 변환', () {
      expect('updatedAt'.toSortField(), SortField.updatedAt);
      expect('createdAt'.toSortField(), SortField.createdAt);
      expect('title'.toSortField(), SortField.title);
      expect('startDate'.toSortField(), SortField.startDate);
    });

    test('toSortField() - 알 수 없는 값은 updatedAt 반환', () {
      expect('unknown'.toSortField(), SortField.updatedAt);
    });
  });

  group('SortOrder 열거형', () {
    test('value getter', () {
      expect(SortOrder.descending.value, 'descending');
      expect(SortOrder.ascending.value, 'ascending');
    });

    test('label getter - 한국어 이름', () {
      expect(SortOrder.descending.label, '내림차순');
      expect(SortOrder.ascending.label, '오름차순');
    });

    test('toSortOrder() - 문자열에서 변환', () {
      expect('descending'.toSortOrder(), SortOrder.descending);
      expect('ascending'.toSortOrder(), SortOrder.ascending);
    });

    test('toSortOrder() - 알 수 없는 값은 descending 반환', () {
      expect('unknown'.toSortOrder(), SortOrder.descending);
    });
  });

  // ============================
  // AppDateUtils 테스트
  // ============================
  group('AppDateUtils', () {
    group('isSameDay', () {
      test('같은 날 - true 반환', () {
        final a = DateTime(2026, 2, 22, 10, 0, 0);
        final b = DateTime(2026, 2, 22, 23, 59, 59);

        expect(AppDateUtils.isSameDay(a, b), true);
      });

      test('다른 날 - false 반환', () {
        final a = DateTime(2026, 2, 22);
        final b = DateTime(2026, 2, 23);

        expect(AppDateUtils.isSameDay(a, b), false);
      });

      test('다른 달 - false 반환', () {
        final a = DateTime(2026, 2, 22);
        final b = DateTime(2026, 3, 22);

        expect(AppDateUtils.isSameDay(a, b), false);
      });

      test('다른 연도 - false 반환', () {
        final a = DateTime(2025, 2, 22);
        final b = DateTime(2026, 2, 22);

        expect(AppDateUtils.isSameDay(a, b), false);
      });
    });

    group('isToday', () {
      test('오늘 날짜 - true 반환', () {
        final today = DateTime.now();
        expect(AppDateUtils.isToday(today), true);
      });

      test('오늘 다른 시간 - true 반환', () {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          0,
          0,
          0,
        );
        expect(AppDateUtils.isToday(today), true);
      });

      test('어제 - false 반환', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isToday(yesterday), false);
      });

      test('내일 - false 반환', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(AppDateUtils.isToday(tomorrow), false);
      });
    });

    group('formatDate', () {
      test('2026년 2월 22일 형식', () {
        final date = DateTime(2026, 2, 22);
        final result = AppDateUtils.formatDate(date);

        expect(result, '2026년 2월 22일');
      });

      test('1월 1일 형식', () {
        final date = DateTime(2025, 1, 1);
        final result = AppDateUtils.formatDate(date);

        expect(result, '2025년 1월 1일');
      });

      test('12월 31일 형식', () {
        final date = DateTime(2026, 12, 31);
        final result = AppDateUtils.formatDate(date);

        expect(result, '2026년 12월 31일');
      });
    });

    group('formatShortDate', () {
      test('현재 연도 - M월 d일 형식', () {
        final now = DateTime.now();
        final date = DateTime(now.year, 6, 15);
        final result = AppDateUtils.formatShortDate(date);

        expect(result, '6월 15일');
      });

      test('다른 연도 - yyyy년 M월 d일 형식', () {
        final date = DateTime(2020, 3, 10);
        final result = AppDateUtils.formatShortDate(date);

        expect(result, '2020년 3월 10일');
      });
    });

    group('weekdayName', () {
      test('1 = 월', () {
        expect(AppDateUtils.weekdayName(1), '월');
      });

      test('2 = 화', () {
        expect(AppDateUtils.weekdayName(2), '화');
      });

      test('3 = 수', () {
        expect(AppDateUtils.weekdayName(3), '수');
      });

      test('4 = 목', () {
        expect(AppDateUtils.weekdayName(4), '목');
      });

      test('5 = 금', () {
        expect(AppDateUtils.weekdayName(5), '금');
      });

      test('6 = 토', () {
        expect(AppDateUtils.weekdayName(6), '토');
      });

      test('7 = 일', () {
        expect(AppDateUtils.weekdayName(7), '일');
      });
    });

    group('formatRelativeDate', () {
      test('방금 전 (30초 이내)', () {
        final date = DateTime.now().subtract(const Duration(seconds: 30));
        expect(AppDateUtils.formatRelativeDate(date), '방금 전');
      });

      test('분 전 (5분 이내)', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        final result = AppDateUtils.formatRelativeDate(date);
        expect(result, '5분 전');
      });

      test('어제', () {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1));
        // 어제 자정으로 설정
        final date = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final result = AppDateUtils.formatRelativeDate(date);
        expect(result, '어제');
      });
    });

    group('daysBetween', () {
      test('같은 날 - 0 반환', () {
        final date = DateTime(2026, 2, 22);
        expect(AppDateUtils.daysBetween(date, date), 0);
      });

      test('3일 차이', () {
        final from = DateTime(2026, 2, 22);
        final to = DateTime(2026, 2, 25);
        expect(AppDateUtils.daysBetween(from, to), 3);
      });

      test('절대값 반환 (역순도 양수)', () {
        final from = DateTime(2026, 2, 25);
        final to = DateTime(2026, 2, 22);
        expect(AppDateUtils.daysBetween(from, to), 3);
      });
    });

    group('firstDayOfMonth & lastDayOfMonth', () {
      test('2월의 첫 날 = 1일', () {
        final date = DateTime(2026, 2, 15);
        final first = AppDateUtils.firstDayOfMonth(date);
        expect(first.day, 1);
        expect(first.month, 2);
        expect(first.year, 2026);
      });

      test('2026년 2월의 마지막 날 = 28일', () {
        final date = DateTime(2026, 2, 1);
        final last = AppDateUtils.lastDayOfMonth(date);
        expect(last.day, 28);
        expect(last.month, 2);
      });

      test('1월의 마지막 날 = 31일', () {
        final date = DateTime(2026, 1, 15);
        final last = AppDateUtils.lastDayOfMonth(date);
        expect(last.day, 31);
        expect(last.month, 1);
      });
    });

    group('previousMonth & nextMonth', () {
      test('2월 이전 달 = 1월', () {
        final date = DateTime(2026, 2, 1);
        final prev = AppDateUtils.previousMonth(date);
        expect(prev.month, 1);
        expect(prev.year, 2026);
      });

      test('1월 이전 달 = 작년 12월', () {
        final date = DateTime(2026, 1, 1);
        final prev = AppDateUtils.previousMonth(date);
        expect(prev.month, 12);
        expect(prev.year, 2025);
      });

      test('2월 다음 달 = 3월', () {
        final date = DateTime(2026, 2, 1);
        final next = AppDateUtils.nextMonth(date);
        expect(next.month, 3);
        expect(next.year, 2026);
      });

      test('12월 다음 달 = 내년 1월', () {
        final date = DateTime(2026, 12, 1);
        final next = AppDateUtils.nextMonth(date);
        expect(next.month, 1);
        expect(next.year, 2027);
      });
    });

    group('daysUntilExpiry', () {
      test('29일 전 삭제된 메모 - 1일 남음', () {
        final deletedAt = DateTime.now().subtract(const Duration(days: 29));
        final days = AppDateUtils.daysUntilExpiry(deletedAt);
        expect(days, 1);
      });

      test('30일 전 삭제된 메모 - 0일 남음', () {
        final deletedAt = DateTime.now().subtract(const Duration(days: 30));
        final days = AppDateUtils.daysUntilExpiry(deletedAt);
        expect(days, 0);
      });

      test('31일 전 삭제된 메모 - 0일 반환 (음수 없음)', () {
        final deletedAt = DateTime.now().subtract(const Duration(days: 31));
        final days = AppDateUtils.daysUntilExpiry(deletedAt);
        expect(days, 0);
      });
    });

    group('formatDateRange', () {
      test('종료일이 null인 경우 - 시작일만 표시', () {
        final now = DateTime.now();
        final start = DateTime(now.year, 2, 22);
        final result = AppDateUtils.formatDateRange(start, null);
        expect(result, AppDateUtils.formatShortDate(start));
      });

      test('시작일과 종료일이 같은 경우 - 하나만 표시', () {
        final now = DateTime.now();
        final date = DateTime(now.year, 2, 22);
        final result = AppDateUtils.formatDateRange(date, date);
        expect(result, AppDateUtils.formatShortDate(date));
      });

      test('시작일과 종료일이 다른 경우 - 범위 표시', () {
        final now = DateTime.now();
        final start = DateTime(now.year, 2, 22);
        final end = DateTime(now.year, 2, 25);
        final result = AppDateUtils.formatDateRange(start, end);
        expect(result, contains('~'));
        expect(result, contains('2월 22일'));
        expect(result, contains('2월 25일'));
      });
    });
  });
}
