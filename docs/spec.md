# 메모 + 캘린더 앱 - 기능명세서

**프로젝트명**: MemoCalendar (메모캘린더)
**작성일**: 2026-02-22
**버전**: 1.0.0

---

## 1. 화면별 기능 명세

### 1.1 스플래시 화면 (`/`)
- **역할**: 앱 시작 시 로딩 화면
- **표시 항목**: 앱 로고, 앱 이름
- **동작**: 1.5초 후 홈 화면으로 자동 이동
- **상태 초기화**: SharedPreferences에서 설정 로드

---

### 1.2 홈 화면 (`/home`)
- **역할**: 메모 목록 메인 화면

#### 상단 AppBar
- 앱 제목 또는 현재 폴더명
- 뷰 전환 버튼 (리스트 ↔ 그리드)
- 메뉴 버튼 → 폴더 관리, 태그 관리, 휴지통 이동

#### 폴더 선택 영역 (수평 스크롤)
- 전체 / 폴더 탭 선택
- 각 탭에 메모 개수 표시
- 폴더 추가 버튼

#### 메모 목록 영역
- **리스트뷰**:
  - 고정 메모 섹션 (상단)
  - 일반 메모 섹션
  - 각 항목: 색상 인디케이터, 제목, 내용 미리보기(2줄), 날짜, 태그, 즐겨찾기 아이콘
- **그리드뷰 (2열)**:
  - 카드 형태, 색상 배경
  - 제목, 내용 미리보기(3줄), 날짜

#### 인터랙션
- 메모 탭: 상세 화면 이동
- 메모 길게 누르기: 다중 선택 모드 진입
- 메모 좌→우 스와이프: 즐겨찾기 토글
- 메모 우→좌 스와이프: 삭제 (휴지통으로)

#### FAB (Floating Action Button)
- 새 메모 작성 버튼

#### 빈 상태 UI
- 메모가 없을 때 안내 메시지 + 작성 버튼

---

### 1.3 캘린더 화면 (`/calendar`)
- **역할**: 캘린더와 메모를 결합한 화면

#### 상단 AppBar
- 현재 월/년 표시
- 이전/다음 달 버튼
- 오늘로 이동 버튼
- 월간/주간 뷰 전환 버튼

#### 캘린더 영역 (월간 뷰)
- 요일 헤더 (일~토)
- 각 날짜 셀:
  - 날짜 숫자
  - 오늘 날짜 강조 표시
  - 선택된 날짜 강조 표시
  - 메모 도트 표시 (최대 3개, 색상 반영)
  - 날짜 범위 메모는 연결된 바로 표시

#### 날짜 선택 시 하단 패널
- 선택 날짜의 메모 목록 (슬라이드 업)
- 해당 날짜 새 메모 작성 버튼

#### 캘린더 영역 (주간 뷰)
- 7일 단위 가로 스크롤
- 시간대별 메모 표시

---

### 1.4 검색 화면 (`/search`)
- **역할**: 메모 검색 및 필터링

#### 검색 입력
- 텍스트 입력 시 실시간 검색
- 검색어 초기화 버튼

#### 최근 검색어
- 최근 검색어 최대 10개 칩 형태로 표시
- 개별 삭제 버튼
- 전체 삭제 버튼

#### 필터 패널
- 폴더 필터 (단일 선택)
- 태그 필터 (다중 선택, AND 조건)
- 날짜 범위 필터 (시작일 ~ 종료일 선택)
- 색상 필터
- 고정/즐겨찾기 필터 토글
- 필터 초기화 버튼

#### 검색 결과
- 결과 메모 목록 (리스트뷰)
- 매칭 텍스트 하이라이트
- 결과 없음 UI

---

### 1.5 설정 화면 (`/settings`)
- **역할**: 앱 환경 설정

#### 섹션 구성
1. **테마**
   - 앱 테마: 라이트 / 다크 / 시스템 (라디오 버튼)
   - 기본 메모 색상 선택

2. **뷰 설정**
   - 기본 뷰: 리스트 / 그리드 / 캘린더
   - 정렬 기준: 수정 일시 / 생성 일시 / 제목 / 날짜
   - 정렬 순서: 내림차순 / 오름차순

3. **알림**
   - 전체 알림 on/off 스위치

4. **데이터 관리**
   - 전체 데이터 초기화 버튼 (확인 다이얼로그)

5. **정보**
   - 앱 버전
   - 오픈소스 라이선스

---

### 1.6 메모 상세/수정 화면 (`/memo/:id`)
- **역할**: 메모 조회 및 수정

#### 상단 AppBar
- 뒤로가기 버튼
- 즐겨찾기 토글 아이콘
- 고정(핀) 토글 아이콘
- 더보기 메뉴: 공유, 색상 변경, 삭제

#### 메모 내용 영역
- 제목 (편집 가능 텍스트 필드)
- 내용 (마크다운 렌더링 / 편집 모드 전환)
- 체크리스트 항목 (있는 경우 표시)

#### 메타 정보 영역 (하단)
- 날짜 범위 (탭하여 변경)
- 태그 목록 (칩 형태, 탭하여 관리)
- 폴더 (탭하여 변경)
- 리마인더 (탭하여 설정)
- 색상 선택

#### 편집 모드
- 뷰 모드 ↔ 편집 모드 전환 버튼
- 편집 완료 시 자동 저장

---

### 1.7 메모 작성 화면 (`/memo/new`)
- **역할**: 새 메모 작성
- 메모 상세 화면과 동일한 레이아웃
- 초기 상태: 빈 제목, 빈 내용
- URL 파라미터로 날짜 전달 가능 (캘린더에서 진입 시)

---

### 1.8 폴더 관리 화면 (`/folders`)
- **역할**: 폴더 목록 및 CRUD

#### 폴더 목록
- 폴더명, 색상, 메모 개수 표시
- 드래그로 순서 변경

#### 폴더 항목 인터랙션
- 탭: 해당 폴더 메모 목록으로 이동
- 길게 누르기: 편집/삭제 옵션
- 스와이프: 삭제

#### 폴더 추가/수정 다이얼로그
- 폴더명 입력
- 색상 선택 (12가지 팔레트)

---

### 1.9 태그 관리 화면 (`/tags`)
- **역할**: 태그 목록 및 CRUD

#### 태그 목록
- 태그명, 색상, 사용 메모 개수 표시

#### 태그 추가/수정 다이얼로그
- 태그명 입력
- 색상 선택 (12가지 팔레트)

---

### 1.10 휴지통 화면 (`/trash`)
- **역할**: 삭제된 메모 관리

#### 상단 영역
- 안내 문구: "30일 후 자동 영구 삭제됩니다"
- 전체 복구 버튼
- 전체 영구 삭제 버튼

#### 삭제된 메모 목록
- 메모 제목, 삭제 일시, 남은 일수 표시
- 탭: 복구/영구 삭제 옵션 표시
- 스와이프: 영구 삭제

---

## 2. 데이터 모델 설계

### 2.1 Memo (메모)

```dart
class Memo {
  final String id;              // UUID
  final String title;           // 제목 (최대 100자)
  final String content;         // 내용 (마크다운, 최대 50000자)
  final MemoColor color;        // 메모 색상
  final String? folderId;       // 폴더 ID (null = 전체)
  final List<String> tagIds;    // 태그 ID 목록
  final bool isPinned;          // 고정 여부
  final bool isFavorite;        // 즐겨찾기 여부
  final DateTime? startDate;    // 시작 날짜
  final DateTime? endDate;      // 종료 날짜
  final DateTime? reminderAt;   // 알림 일시
  final ReminderRepeat reminderRepeat; // 반복 설정
  final String? reminderMessage; // 알림 메시지
  final List<ChecklistItem> checklist; // 체크리스트
  final bool isDeleted;         // 삭제 여부 (소프트 삭제)
  final DateTime? deletedAt;    // 삭제 일시
  final DateTime createdAt;     // 생성 일시
  final DateTime updatedAt;     // 수정 일시
}
```

### 2.2 Folder (폴더)

```dart
class Folder {
  final String id;              // UUID
  final String name;            // 폴더명 (최대 50자)
  final FolderColor color;      // 폴더 색상
  final int sortOrder;          // 정렬 순서
  final bool isDefault;         // 기본 폴더 여부
  final DateTime createdAt;     // 생성 일시
  final DateTime updatedAt;     // 수정 일시
}
```

### 2.3 Tag (태그)

```dart
class Tag {
  final String id;              // UUID
  final String name;            // 태그명 (최대 30자)
  final TagColor color;         // 태그 색상
  final DateTime createdAt;     // 생성 일시
}
```

### 2.4 ChecklistItem (체크리스트 항목)

```dart
class ChecklistItem {
  final String id;              // UUID
  final String text;            // 항목 텍스트
  final bool isChecked;         // 체크 여부
  final int sortOrder;          // 정렬 순서
}
```

### 2.5 AppSettings (앱 설정)

```dart
class AppSettings {
  final ThemeMode themeMode;        // 테마 (light/dark/system)
  final MemoColor defaultColor;     // 기본 메모 색상
  final ViewType defaultView;       // 기본 뷰 (list/grid/calendar)
  final SortField sortField;        // 정렬 기준
  final SortOrder sortOrder;        // 정렬 순서
  final bool notificationsEnabled;  // 알림 활성화
}
```

### 2.6 열거형 (Enums)

```dart
// 메모 색상
enum MemoColor {
  white, yellow, green, blue, purple,
  pink, red, orange, teal, indigo, lime, gray
}

// 반복 알림
enum ReminderRepeat { none, daily, weekly, monthly }

// 뷰 타입
enum ViewType { list, grid, calendar }

// 정렬 기준
enum SortField { updatedAt, createdAt, title, startDate }

// 정렬 순서
enum SortOrder { descending, ascending }

// 테마
enum AppThemeMode { light, dark, system }
```

---

## 3. 로컬 저장소 설계

### 3.1 저장 방식
- **SharedPreferences**: 앱 설정, 최근 검색어 저장
- **JSON 파일 저장**: 메모, 폴더, 태그 데이터 (앱 문서 디렉토리)

### 3.2 파일 구조
```
앱 문서 디렉토리/
├── memos.json         # 메모 전체 목록
├── folders.json       # 폴더 전체 목록
└── tags.json          # 태그 전체 목록
```

### 3.3 SharedPreferences 키

| 키 | 타입 | 설명 |
|----|------|------|
| `theme_mode` | String | 테마 설정 |
| `default_color` | String | 기본 메모 색상 |
| `default_view` | String | 기본 뷰 타입 |
| `sort_field` | String | 정렬 기준 |
| `sort_order` | String | 정렬 순서 |
| `notifications_enabled` | bool | 알림 활성화 |
| `recent_searches` | List<String> | 최근 검색어 |

---

## 4. 서비스 레이어 설계

### 4.1 MemoService
```dart
abstract class MemoService {
  Future<List<Memo>> getAllMemos();
  Future<Memo?> getMemoById(String id);
  Future<List<Memo>> getMemosByDate(DateTime date);
  Future<List<Memo>> getMemosByDateRange(DateTime start, DateTime end);
  Future<List<Memo>> getMemosByFolder(String folderId);
  Future<List<Memo>> getMemosByTag(String tagId);
  Future<List<Memo>> searchMemos(String query, MemoFilter filter);
  Future<List<Memo>> getDeletedMemos();
  Future<Memo> createMemo(Memo memo);
  Future<Memo> updateMemo(Memo memo);
  Future<void> deleteMemo(String id);          // 소프트 삭제
  Future<void> restoreMemo(String id);          // 복구
  Future<void> permanentlyDeleteMemo(String id); // 영구 삭제
  Future<void> togglePin(String id);
  Future<void> toggleFavorite(String id);
}
```

### 4.2 FolderService
```dart
abstract class FolderService {
  Future<List<Folder>> getAllFolders();
  Future<Folder> createFolder(Folder folder);
  Future<Folder> updateFolder(Folder folder);
  Future<void> deleteFolder(String id);
  Future<void> reorderFolders(List<String> orderedIds);
}
```

### 4.3 TagService
```dart
abstract class TagService {
  Future<List<Tag>> getAllTags();
  Future<Tag> createTag(Tag tag);
  Future<Tag> updateTag(Tag tag);
  Future<void> deleteTag(String id);
}
```

### 4.4 SettingsService
```dart
abstract class SettingsService {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<List<String>> getRecentSearches();
  Future<void> addRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
  Future<void> clearRecentSearches();
  Future<void> clearAllData();
}
```

### 4.5 NotificationService
```dart
abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleNotification(Memo memo);
  Future<void> cancelNotification(String memoId);
  Future<void> cancelAllNotifications();
}
```

---

## 5. Provider (상태 관리) 설계

### 5.1 MemoProvider
- 전체 메모 목록 관리
- 현재 뷰 타입 관리
- 필터/정렬 상태 관리
- 다중 선택 상태 관리

### 5.2 CalendarProvider
- 선택된 날짜 관리
- 캘린더 뷰 타입 (월간/주간) 관리
- 날짜별 메모 캐싱

### 5.3 SearchProvider
- 검색어 상태 관리
- 필터 상태 관리
- 검색 결과 관리
- 최근 검색어 관리

### 5.4 FolderProvider
- 폴더 목록 관리
- 선택된 폴더 관리

### 5.5 TagProvider
- 태그 목록 관리

### 5.6 SettingsProvider
- 앱 설정 상태 관리
- 테마 변경 즉시 반영

---

## 6. 네비게이션 흐름

```
스플래시 화면
    ↓ (1.5초 후 자동)
홈 화면 (하단 탭: 홈)
    ├── 메모 탭 → 메모 상세/수정 화면
    ├── FAB → 메모 작성 화면
    ├── 폴더 탭 → 폴더별 메모 필터링
    ├── 메뉴 → 폴더 관리 화면
    ├── 메뉴 → 태그 관리 화면
    └── 메뉴 → 휴지통 화면

캘린더 화면 (하단 탭: 캘린더)
    ├── 날짜 탭 → 해당 날짜 메모 목록 (하단 패널)
    └── 메모 탭 → 메모 상세/수정 화면

검색 화면 (하단 탭: 검색)
    └── 검색 결과 탭 → 메모 상세/수정 화면

설정 화면 (하단 탭: 설정)
    ├── 데이터 초기화
    └── 앱 정보
```

---

## 7. 색상 팔레트

### 7.1 메모/폴더/태그 색상 (12가지)

| 이름 | 라이트 모드 | 다크 모드 |
|------|------------|---------|
| white | #FFFFFF | #2C2C2C |
| yellow | #FFF9C4 | #5C5030 |
| green | #C8E6C9 | #2E5030 |
| blue | #BBDEFB | #1A3A5C |
| purple | #E1BEE7 | #3D2655 |
| pink | #FCE4EC | #5C2035 |
| red | #FFCDD2 | #5C1A20 |
| orange | #FFE0B2 | #5C3A1A |
| teal | #B2DFDB | #1A4C48 |
| indigo | #C5CAE9 | #262D5C |
| lime | #F0F4C3 | #414C1A |
| gray | #F5F5F5 | #3A3A3A |

### 7.2 앱 메인 색상
- **Primary**: `#6200EE` (딥 퍼플)
- **Secondary**: `#03DAC6` (틸)
- **Error**: `#B00020`

---

## 8. 완료 기준 (Definition of Done)

### 8.1 기능 완료 기준
- [ ] 모든 화면 구현 완료 (10개 화면)
- [ ] 메모 CRUD 정상 동작
- [ ] 폴더/태그 CRUD 정상 동작
- [ ] 캘린더 연동 정상 동작
- [ ] 검색 및 필터 정상 동작
- [ ] 휴지통 정상 동작
- [ ] 설정 저장/로드 정상 동작
- [ ] 다크/라이트 모드 정상 전환

### 8.2 품질 완료 기준
- [ ] `flutter analyze` 오류 0개
- [ ] `flutter test` 통과
- [ ] 다크/라이트 모드 UI 이상 없음
- [ ] Android/iOS 빌드 성공
- [ ] 사용가이드.md 작성 완료
