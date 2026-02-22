# MemoCalendar UI/UX 가이드

**버전**: 1.0.0
**작성일**: 2026-02-22
**기준**: Material Design 3

---

## 1. 색상 시스템

### 1.1 브랜드 색상

| 역할 | 색상 이름 | 헥스 코드 | 용도 |
|------|----------|----------|------|
| Primary | 딥 퍼플 | `#6200EE` | 주요 액션, 강조 요소, FAB |
| Secondary | 틸 | `#03DAC6` | 보조 강조, 칩 선택 |
| Error | 에러 레드 | `#B00020` | 오류 상태, 삭제 경고 |

### 1.2 Material 3 Color Scheme

`ColorScheme.fromSeed(seedColor: #6200EE)` 기반으로 자동 생성되는 색상 시스템을 사용합니다.

| 토큰 | 라이트 모드 용도 | 다크 모드 용도 |
|------|----------------|--------------|
| `primary` | 주요 버튼, 선택 인디케이터 | 주요 버튼, 선택 인디케이터 |
| `onPrimary` | Primary 위의 텍스트/아이콘 | Primary 위의 텍스트/아이콘 |
| `primaryContainer` | 선택된 네비게이션 배경 | 선택된 네비게이션 배경 |
| `surface` | 화면 배경, 카드 배경 | 화면 배경, 카드 배경 |
| `onSurface` | 기본 텍스트 색상 | 기본 텍스트 색상 |
| `onSurfaceVariant` | 보조 텍스트, 아이콘 | 보조 텍스트, 아이콘 |
| `outline` | 구분선, 비활성 경계선 | 구분선, 비활성 경계선 |
| `outlineVariant` | 약한 구분선 | 약한 구분선 |

### 1.3 메모 색상 팔레트 (12가지)

메모, 폴더, 태그에 공통으로 사용되는 12가지 색상 팔레트입니다.

| 색상 키 | 한국어 이름 | 라이트 모드 | 다크 모드 |
|---------|-----------|------------|---------|
| `white` | 흰색 | `#FFFFFF` | `#2C2C2C` |
| `yellow` | 노란색 | `#FFF9C4` | `#5C5030` |
| `green` | 초록색 | `#C8E6C9` | `#2E5030` |
| `blue` | 파란색 | `#BBDEFB` | `#1A3A5C` |
| `purple` | 보라색 | `#E1BEE7` | `#3D2655` |
| `pink` | 분홍색 | `#FCE4EC` | `#5C2035` |
| `red` | 빨간색 | `#FFCDD2` | `#5C1A20` |
| `orange` | 주황색 | `#FFE0B2` | `#5C3A1A` |
| `teal` | 청록색 | `#B2DFDB` | `#1A4C48` |
| `indigo` | 남색 | `#C5CAE9` | `#262D5C` |
| `lime` | 연두색 | `#F0F4C3` | `#414C1A` |
| `gray` | 회색 | `#F5F5F5` | `#3A3A3A` |

#### 색상 사용 원칙
- 라이트 모드: 파스텔 톤의 밝은 배경색으로 메모 내용을 돋보이게 함
- 다크 모드: 채도를 낮추고 어두운 톤으로 다크 테마에 자연스럽게 융화
- 기본 메모 색상: `white` (설정에서 변경 가능)

---

## 2. 타이포그래피 가이드

### 2.1 폰트 시스템

한국어에 최적화된 Material 3 기본 폰트(Roboto / Noto Sans KR 계열)를 사용합니다.

### 2.2 텍스트 스타일 가이드

| 스타일 토큰 | 크기 | 굵기 | 용도 |
|-----------|------|------|------|
| `headlineLarge` | 32sp | SemiBold (W600) | 대형 화면 제목 |
| `headlineMedium` | 28sp | SemiBold (W600) | 월/년 표시 (캘린더) |
| `headlineSmall` | 24sp | SemiBold (W600) | 섹션 제목 |
| `titleLarge` | 20sp | SemiBold (W600) | AppBar 제목 |
| `titleMedium` | 16sp | SemiBold (W600) | 메모 제목, 폴더명 |
| `titleSmall` | 14sp | SemiBold (W600) | 카드 소제목 |
| `bodyLarge` | 16sp | Regular (W400) | 메모 본문 (읽기 모드) |
| `bodyMedium` | 14sp | Regular (W400) | 메모 미리보기, 내용 |
| `bodySmall` | 12sp | Regular (W400) | 날짜, 보조 정보 |
| `labelLarge` | 14sp | Medium (W500) | 버튼 텍스트, 탭 레이블 |
| `labelMedium` | 12sp | Medium (W500) | 칩 텍스트, 태그 |
| `labelSmall` | 11sp | Medium (W500) | 메모 도트 수, 날짜 숫자 |

### 2.3 한국어 타이포그래피 원칙

- **줄 간격**: bodyLarge/bodyMedium에 `height: 1.6` 적용 (한국어 가독성 향상)
- **자간(letterSpacing)**: 한국어는 자간을 0 또는 최소값으로 유지
- **줄 바꿈**: 한국어 단어 단위 줄바꿈 (`softWrap: true`)
- **최대 줄 수**: 리스트뷰 미리보기 2줄, 그리드뷰 미리보기 3줄

---

## 3. 레이아웃 가이드

### 3.1 여백(Spacing) 시스템

4의 배수 기반 8포인트 그리드 시스템을 사용합니다.

| 크기 | 값 | 용도 |
|------|-----|------|
| XS | 4dp | 아이콘과 텍스트 사이 간격 |
| S | 8dp | 칩 내부 패딩, 도트 간격 |
| M | 12dp | 카드 내부 패딩 상하 |
| L | 16dp | 화면 기본 가로 패딩, 리스트 아이템 패딩 |
| XL | 24dp | 섹션 간 간격 |
| XXL | 32dp | 빈 상태 UI 상하 패딩 |

### 3.2 화면 기본 레이아웃

```
┌─────────────────────────────────┐
│ StatusBar (시스템)               │
├─────────────────────────────────┤
│ AppBar (56dp)                   │
│  - 제목 (titleLarge)            │
│  - 액션 아이콘들                  │
├─────────────────────────────────┤
│                                 │
│ 콘텐츠 영역                       │
│ padding: horizontal 16dp        │
│                                 │
│                                 │
├─────────────────────────────────┤
│ BottomNavigationBar (80dp)      │
│  홈 | 캘린더 | 검색 | 설정        │
└─────────────────────────────────┘
```

### 3.3 그리드 레이아웃

- **메모 그리드뷰**: 2열 고정, 가로 간격 8dp, 세로 간격 8dp
- **색상 팔레트 그리드**: 4열, 아이템 크기 44×44dp
- **카드 최소 높이**: 80dp (리스트뷰), 120dp (그리드뷰)

### 3.4 캘린더 레이아웃

```
┌──────────────────────────────────┐
│ < 2026년 2월                >  ⊞ │  ← AppBar
├──────────────────────────────────┤
│  일  월  화  수  목  금  토       │  ← 요일 헤더 (40dp)
├──────────────────────────────────┤
│  1   2   3   4   5   6   7      │
│  ●               ●●             │  ← 날짜 셀 (48dp)
│  8   9  10  11  12  13  14      │
│      ━━━━━━━━                   │  ← 날짜 범위 바
│ 15  16  17  18  19  20  21      │
├──────────────────────────────────┤
│ ▲ 선택 날짜의 메모 목록 (하단 패널) │  ← 슬라이드업 패널
└──────────────────────────────────┘
```

---

## 4. 컴포넌트 스타일 가이드

### 4.1 메모 카드

#### 리스트뷰 카드
```
┌──────────────────────────────────┐
│ ▌ [색상 인디케이터 4dp]           │
│   제목 (titleMedium, 1줄)         │
│   내용 미리보기 (bodySmall, 2줄)   │
│   날짜 • 태그칩들        ★  📌   │
└──────────────────────────────────┘
```
- 높이: 최소 80dp, 최대 제한 없음
- 좌측 색상 인디케이터: width 4dp, height 100%
- cornerRadius: 12dp
- elevation: 1

#### 그리드뷰 카드
```
┌──────────────┐
│ [색상 배경]  │
│ 제목 (1줄)   │
│ 내용 (3줄)   │
│              │
│ 날짜 (작게)  │
└──────────────┘
```
- 가로: (화면폭 - 48dp) / 2
- 배경색: 해당 메모의 색상
- cornerRadius: 12dp

### 4.2 AppBar 액션 버튼

- 아이콘 크기: 24dp
- 터치 영역: 48×48dp (접근성 최소 크기)
- 아이콘 간격: 4dp

### 4.3 FAB (새 메모 작성)

- 타입: Extended FAB 또는 Regular FAB
- 위치: 우하단, bottom: 16dp, right: 16dp
- 아이콘: `Icons.add_rounded`
- 라벨: "새 메모" (Extended FAB일 경우)
- cornerRadius: 16dp

### 4.4 검색 바

- 높이: 56dp
- cornerRadius: 28dp (원형에 가깝게)
- 아이콘: `Icons.search` (좌측), `Icons.close` (텍스트 입력 시 우측)
- 배경: `surfaceContainerHighest.withOpacity(0.4)`

### 4.5 폴더 탭 (수평 스크롤)

- 높이: 48dp
- 탭 형태: FilterChip 또는 텍스트 탭
- 선택 시: `primaryContainer` 배경, `onPrimaryContainer` 텍스트
- 미선택: `surfaceContainerHighest` 배경
- 각 탭에 메모 개수 뱃지 표시

### 4.6 태그 칩

- 높이: 28dp
- 스타일: `FilterChip` 위젯 사용
- cornerRadius: 8dp
- 폰트: `labelMedium` (12sp, W500)
- 배경: 해당 태그 색상의 연한 버전

### 4.7 메모 색상 도트 (캘린더)

- 크기: 6dp × 6dp
- cornerRadius: 3dp (원형)
- 최대 3개 표시
- 간격: 2dp

### 4.8 날짜 범위 바 (캘린더)

- 높이: 4dp
- cornerRadius: 2dp
- 색상: 해당 메모 색상
- 시작일: 좌측 반원, 종료일: 우측 반원, 중간: 직사각형

### 4.9 하단 시트 (날짜 선택 메모 목록)

- 최소 높이: 화면 높이의 30%
- 최대 높이: 화면 높이의 80%
- 드래그 핸들: 상단 중앙, 32×4dp, cornerRadius 2dp
- cornerRadius (상단): 28dp

### 4.10 빈 상태 UI

```
┌──────────────────────────────────┐
│           [아이콘 64dp]          │
│        보조 안내 텍스트            │
│                                  │
│     [새 메모 작성하기 버튼]         │
└──────────────────────────────────┘
```
- 아이콘: `Icons.note_alt_outlined` (홈), `Icons.search_off` (검색)
- 텍스트 색상: `onSurfaceVariant`
- 버튼: Outlined 또는 Filled 버튼

---

## 5. 아이콘 가이드

Material Icons (Rounded 스타일 권장) 사용합니다.

### 5.1 네비게이션 아이콘

| 탭 | 비선택 아이콘 | 선택 아이콘 |
|----|-------------|-----------|
| 홈 | `Icons.home_outlined` | `Icons.home_rounded` |
| 캘린더 | `Icons.calendar_month_outlined` | `Icons.calendar_month_rounded` |
| 검색 | `Icons.search_outlined` | `Icons.search_rounded` |
| 설정 | `Icons.settings_outlined` | `Icons.settings_rounded` |

### 5.2 기능 아이콘

| 기능 | 아이콘 |
|------|-------|
| 새 메모 (FAB) | `Icons.add_rounded` |
| 즐겨찾기 (비활성) | `Icons.star_outline_rounded` |
| 즐겨찾기 (활성) | `Icons.star_rounded` |
| 고정(핀) (비활성) | `Icons.push_pin_outlined` |
| 고정(핀) (활성) | `Icons.push_pin_rounded` |
| 삭제 | `Icons.delete_outline_rounded` |
| 수정 | `Icons.edit_outlined` |
| 더보기 메뉴 | `Icons.more_vert_rounded` |
| 리스트뷰 | `Icons.view_list_rounded` |
| 그리드뷰 | `Icons.grid_view_rounded` |
| 검색 닫기 | `Icons.close_rounded` |
| 뒤로 | `Icons.arrow_back_rounded` |
| 알림 | `Icons.notifications_outlined` |
| 폴더 | `Icons.folder_outlined` |
| 태그 | `Icons.label_outlined` |
| 체크박스 (비체크) | `Icons.check_box_outline_blank_rounded` |
| 체크박스 (체크) | `Icons.check_box_rounded` |
| 휴지통 | `Icons.delete_outline_rounded` |
| 복구 | `Icons.restore_from_trash_rounded` |
| 색상 변경 | `Icons.palette_outlined` |
| 공유 | `Icons.share_outlined` |
| 오늘 날짜 | `Icons.today_rounded` |
| 이전 달 | `Icons.chevron_left_rounded` |
| 다음 달 | `Icons.chevron_right_rounded` |
| 드래그 핸들 | `Icons.drag_handle_rounded` |

---

## 6. 네비게이션 흐름

### 6.1 전체 흐름 다이어그램

```
┌──────────────────────────────────────────────────────────┐
│                     스플래시 화면 (/)                      │
│                    1.5초 후 자동 이동                       │
└──────────────────────┬───────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────┐
│                    메인 화면 (하단 탭)                      │
│  ┌──────────┬──────────┬──────────┬──────────┐           │
│  │  홈       │ 캘린더    │  검색     │  설정     │           │
│  │ /home    │/calendar │ /search  │/settings │           │
│  └──────────┴──────────┴──────────┴──────────┘           │
└──────────────────────────────────────────────────────────┘
         │                    │              │
         ↓                    ↓              ↓
  ┌─────────────┐    ┌──────────────┐  ┌──────────┐
  │ 메모 상세    │    │메모 상세/수정 │  │데이터 초기│
  │ /memo/:id   │    │ /memo/:id    │  │화 다이얼로 │
  └─────────────┘    └──────────────┘  └──────────┘
         │
         ↓
  ┌─────────────┐
  │ 메모 작성    │
  │ /memo/new   │
  └─────────────┘

  홈 화면 메뉴에서 접근:
  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
  │ 폴더 관리       │  │ 태그 관리       │  │ 휴지통          │
  │ /folders       │  │ /tags          │  │ /trash         │
  └────────────────┘  └────────────────┘  └────────────────┘
```

### 6.2 화면별 진입 방법

| 화면 | 진입 방법 |
|------|---------|
| 홈 (`/home`) | 하단 탭 '홈' |
| 캘린더 (`/calendar`) | 하단 탭 '캘린더' |
| 검색 (`/search`) | 하단 탭 '검색' |
| 설정 (`/settings`) | 하단 탭 '설정' |
| 메모 상세 (`/memo/:id`) | 메모 탭, 검색 결과 탭, 캘린더 메모 탭 |
| 메모 작성 (`/memo/new`) | FAB 탭, 캘린더 날짜 선택 후 새 메모 버튼 |
| 폴더 관리 (`/folders`) | 홈 AppBar 메뉴 → 폴더 관리 |
| 태그 관리 (`/tags`) | 홈 AppBar 메뉴 → 태그 관리 |
| 휴지통 (`/trash`) | 홈 AppBar 메뉴 → 휴지통 |

### 6.3 제스처 인터랙션

| 제스처 | 동작 | 위치 |
|-------|------|------|
| 탭 | 메모 상세로 이동 | 메모 카드 |
| 길게 누르기 (LongPress) | 다중 선택 모드 진입 | 메모 카드 |
| 좌→우 스와이프 | 즐겨찾기 토글 | 메모 카드 (리스트뷰) |
| 우→좌 스와이프 | 휴지통으로 삭제 | 메모 카드 (리스트뷰) |
| 우→좌 스와이프 | 영구 삭제 | 휴지통 메모 |
| 길게 누르기 | 편집/삭제 옵션 | 폴더 항목 |
| 드래그 | 순서 변경 | 폴더 목록, 체크리스트 |

---

## 7. 접근성 가이드

### 7.1 색상 대비

- **일반 텍스트**: 최소 4.5:1 대비율 (WCAG AA)
- **대형 텍스트 (18sp+)**: 최소 3:1 대비율
- 메모 색상 위의 텍스트는 `getMemoTextColor()` 헬퍼 함수로 자동 계산

### 7.2 터치 영역

- 모든 인터랙티브 요소: 최소 **48×48dp**
- 아이콘 버튼: `IconButton` 사용 시 자동 보장
- 소형 칩: 패딩을 추가하여 최소 터치 영역 확보

### 7.3 Semantics 레이블

주요 위젯에 `Semantics` 위젯 또는 `semanticsLabel` 적용:

```dart
// 예시: 즐겨찾기 버튼
IconButton(
  icon: Icon(Icons.star_outline),
  onPressed: onFavoriteToggle,
  tooltip: '즐겨찾기 추가',  // 스크린 리더 지원
),
```

| 요소 | Semantics 레이블 예시 |
|------|---------------------|
| FAB | "새 메모 작성" |
| 즐겨찾기 버튼 | "즐겨찾기 추가" / "즐겨찾기 해제" |
| 삭제 버튼 | "메모 삭제" |
| 날짜 셀 | "2026년 2월 22일, 메모 3개" |
| 색상 선택 | "노란색 선택됨" |

---

## 8. 애니메이션 가이드

### 8.1 화면 전환 애니메이션

| 전환 | 방식 |
|------|------|
| 홈 → 메모 상세 | Shared Element Transition (Hero) + Slide Up |
| 탭 전환 | Fade (기본 Material 3) |
| 스플래시 → 홈 | Fade Out |
| 하단 패널 (캘린더) | Slide Up |

### 8.2 컴포넌트 애니메이션

| 요소 | 애니메이션 |
|------|---------|
| FAB | Scale (확대/축소) |
| 스와이프 삭제 | Slide + Fade |
| 체크박스 체크 | Check Scale + 취소선 DrawPath |
| 다중 선택 진입 | Scale Down (카드) |
| 필터 패널 펼침 | Expand (AnimatedContainer) |

### 8.3 애니메이션 시간 기준

- **빠름**: 150ms (소형 UI 피드백)
- **보통**: 250ms (일반 전환)
- **느림**: 400ms (화면 전환, 하단 시트)
- **커브**: `Curves.easeInOut` (기본), `Curves.easeOutCubic` (등장)

---

## 9. 다크 모드 대응 원칙

1. **색상**: `Theme.of(context).colorScheme.*` 토큰만 사용 (하드코딩 금지)
2. **메모 배경색**: `getMemoColor(key, context)` 헬퍼 함수로 라이트/다크 자동 대응
3. **이미지/아이콘**: 다크 모드에서 `opacity: 0.87` 적용 고려
4. **그림자**: 다크 모드에서 elevation 대신 `surfaceTint` 사용 (Material 3 기본)
5. **테마 전환**: 설정에서 즉시 전환, 애니메이션 없이 반영

---

## 10. 컴포넌트 사용 예시 코드

### 10.1 메모 색상 사용 예시

```dart
// 메모 카드 배경색 적용
Container(
  color: getMemoColor(memo.color.name, context),
  child: Text(
    memo.title,
    style: TextStyle(
      color: getMemoTextColor(memo.color.name, context),
    ),
  ),
)
```

### 10.2 태그 칩 예시

```dart
// 태그 칩
FilterChip(
  label: Text(tag.name),
  selected: isSelected,
  onSelected: onTagSelected,
  backgroundColor: getMemoColor(tag.color.name, context).withOpacity(0.6),
  selectedColor: getMemoColor(tag.color.name, context),
)
```

### 10.3 빈 상태 UI 예시

```dart
// 메모 없음 상태
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.note_alt_outlined, size: 64),
      const SizedBox(height: 16),
      Text('메모가 없습니다', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
        '새 메모를 작성해보세요',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        icon: const Icon(Icons.add_rounded),
        label: const Text('새 메모 작성'),
        onPressed: onCreateMemo,
      ),
    ],
  ),
)
```
