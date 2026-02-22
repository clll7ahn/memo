"""
메모+캘린더 앱 아이콘 생성 스크립트
1024x1024 PNG, 딥 퍼플 그라데이션 배경, 흰색 메모장+캘린더 아이콘
"""

from PIL import Image, ImageDraw, ImageFont
import math
import os

def create_app_icon():
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === 1. 둥근 모서리 사각형 배경 (딥 퍼플 그라데이션) ===
    corner_radius = 220

    # 그라데이션 생성 (좌상단 #6200EE → 우하단 #9C27B0)
    gradient = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    for y in range(size):
        for x in range(size):
            # 대각선 그라데이션 비율 계산
            t = (x + y) / (2 * size)
            r = int(0x62 + (0x9C - 0x62) * t)
            g = int(0x00 + (0x27 - 0x00) * t)
            b = int(0xEE + (0xB0 - 0xEE) * t)
            gradient.putpixel((x, y), (r, g, b, 255))

    # 둥근 모서리 마스크 생성
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=corner_radius,
        fill=255
    )

    # 그라데이션에 둥근 모서리 마스크 적용
    gradient.putalpha(mask)
    img = Image.alpha_composite(img, gradient)
    draw = ImageDraw.Draw(img)

    # === 2. 메모장 아이콘 (흰색, 접힌 모서리 포함) ===
    # 메모장 위치와 크기 (중앙 약간 좌상단 배치)
    memo_left = 200
    memo_top = 160
    memo_right = 720
    memo_bottom = 780
    memo_width = memo_right - memo_left
    memo_height = memo_bottom - memo_top
    fold_size = 110  # 접힌 모서리 크기

    white = (255, 255, 255, 255)
    white_shadow = (255, 255, 255, 200)
    fold_color = (230, 230, 240, 255)  # 접힌 부분 색상
    fold_shadow = (200, 200, 220, 255)  # 접힌 부분 그림자
    line_color = (180, 160, 220, 180)  # 메모 줄 색상

    # 메모장 본체 (접힌 모서리 제외한 다각형)
    memo_body = [
        (memo_left, memo_top),                          # 좌상단
        (memo_right - fold_size, memo_top),              # 우상단 (접힌 부분 시작)
        (memo_right, memo_top + fold_size),              # 접힌 모서리 끝
        (memo_right, memo_bottom),                       # 우하단
        (memo_left, memo_bottom),                        # 좌하단
    ]
    draw.polygon(memo_body, fill=white)

    # 접힌 모서리 삼각형
    fold_triangle = [
        (memo_right - fold_size, memo_top),
        (memo_right, memo_top + fold_size),
        (memo_right - fold_size, memo_top + fold_size),
    ]
    draw.polygon(fold_triangle, fill=fold_color)

    # 접힌 모서리 경계선 (그림자 효과)
    draw.line(
        [(memo_right - fold_size, memo_top), (memo_right, memo_top + fold_size)],
        fill=fold_shadow,
        width=3
    )

    # 메모장 줄 (3줄)
    line_y_start = memo_top + 180
    line_spacing = 100
    line_margin = 60
    for i in range(3):
        ly = line_y_start + i * line_spacing
        draw.line(
            [(memo_left + line_margin, ly), (memo_right - line_margin, ly)],
            fill=line_color,
            width=5
        )

    # 메모장 제목 줄 (굵은 줄)
    title_y = memo_top + 100
    draw.line(
        [(memo_left + line_margin, title_y), (memo_right - line_margin - 100, title_y)],
        fill=(160, 140, 200, 200),
        width=8
    )

    # === 3. 캘린더 아이콘 (우하단, 작은 크기) ===
    cal_size = 260
    cal_left = 580
    cal_top = 600
    cal_right = cal_left + cal_size
    cal_bottom = cal_top + cal_size
    cal_radius = 30

    # 캘린더 배경 (흰색 둥근 사각형)
    draw.rounded_rectangle(
        [(cal_left, cal_top), (cal_right, cal_bottom)],
        radius=cal_radius,
        fill=white
    )

    # 캘린더 상단 바 (딥 퍼플)
    bar_height = 60
    # 상단 둥근 부분을 위해 전체 둥근 사각형 그리고 하단 직사각형 덮기
    draw.rounded_rectangle(
        [(cal_left, cal_top), (cal_right, cal_top + bar_height + cal_radius)],
        radius=cal_radius,
        fill=(120, 50, 200, 255)
    )
    draw.rectangle(
        [(cal_left, cal_top + bar_height), (cal_right, cal_top + bar_height + cal_radius)],
        fill=(120, 50, 200, 255)
    )

    # 캘린더 고리 (2개)
    hook_width = 8
    hook_color = (200, 200, 210, 255)
    hook_y_top = cal_top - 15
    hook_y_bottom = cal_top + 25
    hook1_x = cal_left + 70
    hook2_x = cal_right - 70
    draw.rounded_rectangle(
        [(hook1_x - hook_width, hook_y_top), (hook1_x + hook_width, hook_y_bottom)],
        radius=4,
        fill=hook_color
    )
    draw.rounded_rectangle(
        [(hook2_x - hook_width, hook_y_top), (hook2_x + hook_width, hook_y_bottom)],
        radius=4,
        fill=hook_color
    )

    # 캘린더 날짜 점 그리드 (3x3)
    grid_margin = 45
    grid_left = cal_left + grid_margin
    grid_top = cal_top + bar_height + 30
    grid_cols = 3
    grid_rows = 3
    cell_w = (cal_size - 2 * grid_margin) / grid_cols
    cell_h = (cal_size - bar_height - 30 - grid_margin) / grid_rows
    dot_radius = 10
    dot_color = (120, 50, 200, 200)
    highlight_color = (255, 100, 100, 255)

    for row in range(grid_rows):
        for col in range(grid_cols):
            cx = grid_left + col * cell_w + cell_w / 2
            cy = grid_top + row * cell_h + cell_h / 2
            # 중앙 점을 하이라이트 (오늘 날짜 표시)
            if row == 1 and col == 1:
                draw.ellipse(
                    [(cx - dot_radius - 6, cy - dot_radius - 6),
                     (cx + dot_radius + 6, cy + dot_radius + 6)],
                    fill=highlight_color
                )
                draw.ellipse(
                    [(cx - dot_radius + 2, cy - dot_radius + 2),
                     (cx + dot_radius - 2, cy + dot_radius - 2)],
                    fill=white
                )
            else:
                draw.ellipse(
                    [(cx - dot_radius, cy - dot_radius),
                     (cx + dot_radius, cy + dot_radius)],
                    fill=dot_color
                )

    # === 4. 미세한 그림자 효과 (메모장 아래) ===
    # 이미 충분히 깔끔하므로 추가 그림자는 생략

    # === 5. 저장 ===
    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assets', 'icon', 'app_icon.png')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"아이콘 생성 완료: {output_path}")
    print(f"이미지 크기: {img.size}")
    return output_path

if __name__ == '__main__':
    create_app_icon()
