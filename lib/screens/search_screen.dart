import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/memo.dart';
import '../providers/memo_provider.dart';
import '../providers/folder_provider.dart';
import '../providers/tag_provider.dart';
import '../providers/settings_provider.dart';
/// 검색 화면
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// 현재 검색어
  String _query = '';

  /// 최근 검색어 목록
  List<String> _recentSearches = [];

  /// 필터 패널 표시 여부
  bool _showFilters = false;

  /// 검색 필터
  MemoFilter _filter = const MemoFilter();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 최근 검색어 로드
  Future<void> _loadRecentSearches() async {
    final storageService = context.read<SettingsProvider>().storageService;
    final searches = await storageService.loadRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  /// 검색어 저장
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final storageService = context.read<SettingsProvider>().storageService;
    final updated = await storageService.addRecentSearch(query.trim());
    if (mounted) {
      setState(() {
        _recentSearches = updated;
      });
    }
  }

  /// 특정 검색어 삭제
  Future<void> _removeRecentSearch(String query) async {
    final storageService = context.read<SettingsProvider>().storageService;
    final updated = await storageService.removeRecentSearch(query);
    if (mounted) {
      setState(() {
        _recentSearches = updated;
      });
    }
  }

  /// 전체 검색어 삭제
  Future<void> _clearRecentSearches() async {
    final storageService = context.read<SettingsProvider>().storageService;
    await storageService.clearRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = [];
      });
    }
  }

  /// 검색어 선택
  void _selectSearch(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    setState(() {
      _query = query;
    });
    _searchFocusNode.unfocus();
    _saveRecentSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final memoProvider = context.watch<MemoProvider>();

    // 검색 결과
    final results = _query.isNotEmpty
        ? memoProvider.searchMemos(_query, additionalFilter: _filter.isEmpty ? null : _filter)
        : <Memo>[];

    final hasActiveFilter = !_filter.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),
        titleSpacing: 0,
        actions: [
          // 필터 버튼
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                tooltip: '필터',
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              if (hasActiveFilter)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필터 패널 (접힘/펼침)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showFilters
                ? _FilterPanel(
                    filter: _filter,
                    onFilterChanged: (newFilter) {
                      setState(() {
                        _filter = newFilter;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _filter = const MemoFilter();
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
          // 검색어가 없을 때: 최근 검색어
          if (_query.isEmpty)
            Expanded(
              child: _buildRecentSearches(context),
            )
          // 검색 결과
          else
            Expanded(
              child: _buildSearchResults(context, results),
            ),
        ],
      ),
    );
  }

  /// 검색 입력 필드
  Widget _buildSearchField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: false,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '메모 검색...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                    });
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _saveRecentSearch(value.trim());
          }
        },
      ),
    );
  }

  /// 최근 검색어 영역
  Widget _buildRecentSearches(BuildContext context) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha:0.4),
            ),
            const SizedBox(height: 12),
            Text(
              '검색어를 입력해 주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Text(
                '최근 검색어',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearRecentSearches,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Colors.grey,
                ),
                child: const Text('전체 삭제'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => _removeRecentSearch(search),
                ),
                onTap: () => _selectSearch(search),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 검색 결과 영역
  Widget _buildSearchResults(BuildContext context, List<Memo> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.withValues(alpha:0.4),
            ),
            const SizedBox(height: 12),
            Text(
              '"$_query" 검색 결과가 없습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '${results.length}개의 결과',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              return _HighlightMemoCard(
                memo: results[index],
                query: _query,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 검색어 하이라이트를 지원하는 메모 카드
class _HighlightMemoCard extends StatelessWidget {
  final Memo memo;
  final String query;

  const _HighlightMemoCard({
    required this.memo,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = memo.color.getColor(isDark);
    final luminance = bgColor.computeLuminance();
    final textColor = luminance < 0.5 ? Colors.white : Colors.black87;
    final subTextColor = luminance < 0.5
        ? Colors.white.withValues(alpha:0.7)
        : Colors.black54;
    final highlightColor = Theme.of(context).colorScheme.primary.withValues(alpha:0.3);

    return GestureDetector(
      onTap: () => context.push('/memo/${memo.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 (하이라이트)
            _buildHighlightText(
              text: memo.title.isEmpty ? '제목 없음' : memo.title,
              query: query,
              baseStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              highlightColor: highlightColor,
              textColor: textColor,
              maxLines: 1,
            ),
            if (memo.content.isNotEmpty) ...[
              const SizedBox(height: 4),
              // 내용 (하이라이트)
              _buildHighlightText(
                text: memo.content,
                query: query,
                baseStyle: TextStyle(
                  fontSize: 13,
                  color: subTextColor,
                  height: 1.4,
                ),
                highlightColor: highlightColor,
                textColor: textColor,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 하이라이트 텍스트 위젯
  Widget _buildHighlightText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required Color highlightColor,
    required Color textColor,
    int? maxLines,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ));
      start = index + query.length;
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 검색 필터 패널
class _FilterPanel extends StatelessWidget {
  final MemoFilter filter;
  final ValueChanged<MemoFilter> onFilterChanged;
  final VoidCallback onClear;

  const _FilterPanel({
    required this.filter,
    required this.onFilterChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final folderProvider = context.watch<FolderProvider>();
    final tagProvider = context.watch<TagProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 + 초기화 버튼
          Row(
            children: [
              Text(
                '필터',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('초기화'),
              ),
            ],
          ),

          // 폴더 필터
          Text(
            '폴더',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 전체 (폴더 필터 없음)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('전체'),
                    selected: filter.folderId == null,
                    onSelected: (_) {
                      onFilterChanged(filter.copyWith(folderId: null));
                    },
                    showCheckmark: false,
                  ),
                ),
                ...folderProvider.folders.map((folder) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(folder.name),
                    selected: filter.folderId == folder.id,
                    onSelected: (_) {
                      onFilterChanged(
                        filter.copyWith(
                          folderId: filter.folderId == folder.id
                              ? null
                              : folder.id,
                        ),
                      );
                    },
                    showCheckmark: false,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 태그 필터
          if (tagProvider.tags.isNotEmpty) ...[
            Text(
              '태그',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tagProvider.tags.map((tag) {
                  final isSelected = filter.tagIds.contains(tag.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (_) {
                        final newTagIds = List<String>.from(filter.tagIds);
                        if (isSelected) {
                          newTagIds.remove(tag.id);
                        } else {
                          newTagIds.add(tag.id);
                        }
                        onFilterChanged(filter.copyWith(tagIds: newTagIds));
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 색상 필터
          Text(
            '색상',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MemoColor.values.map((color) {
                final isSelected = filter.color == color;
                final colorValue = color.getColor(isDark);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      onFilterChanged(
                        filter.copyWith(
                          color: isSelected ? null : color,
                        ),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : Border.all(
                                color: Colors.grey.withValues(alpha:0.3),
                                width: 1,
                              ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: colorValue.computeLuminance() < 0.5
                                  ? Colors.white
                                  : Colors.black,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // 고정/즐겨찾기 토글
          Row(
            children: [
              FilterChip(
                label: const Text('고정'),
                selected: filter.isPinned == true,
                onSelected: (_) {
                  onFilterChanged(
                    filter.copyWith(
                      isPinned: filter.isPinned == true ? null : true,
                    ),
                  );
                },
                avatar: const Icon(Icons.push_pin, size: 14),
                showCheckmark: false,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('즐겨찾기'),
                selected: filter.isFavorite == true,
                onSelected: (_) {
                  onFilterChanged(
                    filter.copyWith(
                      isFavorite: filter.isFavorite == true ? null : true,
                    ),
                  );
                },
                avatar: const Icon(Icons.star, size: 14),
                showCheckmark: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
