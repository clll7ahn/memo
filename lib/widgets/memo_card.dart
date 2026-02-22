import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/memo.dart';
import '../models/enums.dart';
import '../providers/memo_provider.dart';
import '../providers/tag_provider.dart';
import '../utils/date_utils.dart';

/// 메모 카드 위젯
/// 리스트뷰와 그리드뷰 두 가지 레이아웃 지원
class MemoCard extends StatelessWidget {
  final Memo memo;

  /// 그리드 모드 여부 (true: 그리드, false: 리스트)
  final bool isGrid;

  /// 스와이프 지원 여부
  final bool dismissible;

  const MemoCard({
    super.key,
    required this.memo,
    this.isGrid = false,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = memo.color.getColor(isDark);

    // 배경색 밝기에 따라 텍스트 색상 결정
    final luminance = bgColor.computeLuminance();
    final textColor = luminance < 0.5 ? Colors.white : Colors.black87;
    final subTextColor = luminance < 0.5
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black54;

    final card = _buildCard(context, bgColor, textColor, subTextColor);

    if (!dismissible) return card;

    return Dismissible(
      key: ValueKey(memo.id),
      // 좌→우 스와이프: 즐겨찾기 토글
      background: _buildSwipeBackground(
        context: context,
        alignment: Alignment.centerLeft,
        color: Colors.amber,
        icon: memo.isFavorite ? Icons.star : Icons.star_border,
        label: memo.isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
      ),
      // 우→좌 스와이프: 삭제
      secondaryBackground: _buildSwipeBackground(
        context: context,
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete_outline,
        label: '삭제',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 즐겨찾기 토글 후 dismiss 취소 (목록 유지)
          await context.read<MemoProvider>().toggleFavorite(memo.id);
          return false;
        } else {
          // 삭제 확인 다이얼로그
          return await _showDeleteConfirmDialog(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<MemoProvider>().deleteMemo(memo.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('메모가 휴지통으로 이동되었습니다'),
              action: SnackBarAction(
                label: '되돌리기',
                onPressed: () {
                  context.read<MemoProvider>().restoreMemo(memo.id);
                },
              ),
            ),
          );
        }
      },
      child: card,
    );
  }

  /// 카드 본체 빌드
  Widget _buildCard(
    BuildContext context,
    Color bgColor,
    Color textColor,
    Color subTextColor,
  ) {
    final memoProvider = context.watch<MemoProvider>();
    final isSelected = memoProvider.selectedMemoIds.contains(memo.id);
    final isMultiSelect = memoProvider.isMultiSelectMode;

    return GestureDetector(
      onTap: () {
        if (isMultiSelect) {
          memoProvider.toggleMemoSelection(memo.id);
        } else {
          context.push('/memo/${memo.id}');
        }
      },
      onLongPress: () {
        if (!isMultiSelect) {
          memoProvider.enterMultiSelectMode(memo.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: isGrid
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: isGrid
                  ? _buildGridContent(context, textColor, subTextColor)
                  : _buildListContent(context, textColor, subTextColor),
            ),
            // 다중 선택 체크박스
            if (isMultiSelect)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white.withValues(alpha:0.8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : const SizedBox(width: 20, height: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 리스트뷰 내용 빌드
  Widget _buildListContent(
    BuildContext context,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 색상 인디케이터
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 고정/즐겨찾기 아이콘
              Row(
                children: [
                  if (memo.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: subTextColor,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      memo.title.isEmpty ? '제목 없음' : memo.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (memo.isFavorite)
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // 내용 미리보기 (2줄)
              if (memo.content.isNotEmpty)
                Text(
                  memo.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              // 체크리스트 진행률
              if (memo.checklist.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildChecklistProgress(context, textColor),
                ),
              const SizedBox(height: 6),
              // 하단 정보 (날짜, 태그)
              Row(
                children: [
                  Expanded(
                    child: _buildTagChips(context, subTextColor),
                  ),
                  Text(
                    AppDateUtils.formatRelativeDate(memo.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 그리드뷰 내용 빌드
  Widget _buildGridContent(
    BuildContext context,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 제목 + 고정/즐겨찾기
        Row(
          children: [
            if (memo.isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin,
                  size: 12,
                  color: subTextColor,
                ),
              ),
            Expanded(
              child: Text(
                memo.title.isEmpty ? '제목 없음' : memo.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (memo.isFavorite)
              const Icon(Icons.star, size: 14, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 6),
        // 내용 미리보기 (3줄)
        if (memo.content.isNotEmpty)
          Text(
            memo.content,
            style: TextStyle(
              fontSize: 12,
              color: subTextColor,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        // 체크리스트 진행률
        if (memo.checklist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildChecklistProgress(context, textColor),
          ),
        const SizedBox(height: 6),
        // 태그 칩
        _buildTagChips(context, subTextColor),
        const SizedBox(height: 4),
        // 날짜
        Text(
          AppDateUtils.formatRelativeDate(memo.updatedAt),
          style: TextStyle(
            fontSize: 10,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  /// 체크리스트 진행률 위젯
  Widget _buildChecklistProgress(BuildContext context, Color textColor) {
    final progress = memo.checklistProgress;
    final checked = memo.checklistCheckedCount;
    final total = memo.checklist.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$checked/$total',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha:0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: textColor.withValues(alpha:0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              textColor.withValues(alpha:0.7),
            ),
            minHeight: 3,
          ),
        ),
      ],
    );
  }

  /// 태그 칩 위젯
  Widget _buildTagChips(BuildContext context, Color subTextColor) {
    if (memo.tagIds.isEmpty) return const SizedBox.shrink();

    final tagProvider = context.watch<TagProvider>();
    final tags = tagProvider.getTagsByIds(memo.tagIds);

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: tags.take(3).map((tag) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final tagColor = tag.color.getColor(isDark);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag.name,
            style: TextStyle(
              fontSize: 10,
              color: subTextColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 스와이프 배경 위젯
  Widget _buildSwipeBackground({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: isGrid
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('이 메모를 휴지통으로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
