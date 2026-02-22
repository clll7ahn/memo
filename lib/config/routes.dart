import 'package:go_router/go_router.dart';

// 화면 임포트 (각 팀원이 구현)
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/memo_detail_screen.dart';
import '../screens/memo_edit_screen.dart';
import '../screens/folder_screen.dart';
import '../screens/tag_screen.dart';
import '../screens/trash_screen.dart';
import '../widgets/bottom_nav_bar.dart';

/// 앱 라우트 정의
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    // 스플래시 화면 (독립 라우트)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // 하단 네비게이션을 포함하는 ShellRoute
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavBar(child: child);
      },
      routes: [
        // 홈 화면
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        // 캘린더 화면
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        // 검색 화면
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        // 설정 화면
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // 메모 작성 화면 (독립 라우트 - 하단 탭 숨김)
    GoRoute(
      path: '/memo/new',
      builder: (context, state) {
        // 캘린더에서 진입 시 날짜 파라미터 전달 가능
        final date = state.uri.queryParameters['date'];
        return MemoEditScreen(initialDate: date);
      },
    ),

    // 메모 상세/수정 화면 (독립 라우트 - 하단 탭 숨김)
    GoRoute(
      path: '/memo/:id',
      builder: (context, state) {
        final memoId = state.pathParameters['id']!;
        return MemoDetailScreen(memoId: memoId);
      },
    ),

    // 폴더 관리 화면 (독립 라우트)
    GoRoute(
      path: '/folders',
      builder: (context, state) => const FolderScreen(),
    ),

    // 태그 관리 화면 (독립 라우트)
    GoRoute(
      path: '/tags',
      builder: (context, state) => const TagScreen(),
    ),

    // 휴지통 화면 (독립 라우트)
    GoRoute(
      path: '/trash',
      builder: (context, state) => const TrashScreen(),
    ),
  ],
);

/// 라우트 경로 상수
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String memoNew = '/memo/new';
  static const String memoDetail = '/memo/:id';
  static const String folders = '/folders';
  static const String tags = '/tags';
  static const String trash = '/trash';

  /// 메모 상세 경로 생성
  static String memoDetailPath(String id) => '/memo/$id';

  /// 메모 작성 경로 생성 (날짜 포함 가능)
  static String memoNewPath({String? date}) {
    if (date != null) {
      return '/memo/new?date=$date';
    }
    return '/memo/new';
  }
}
