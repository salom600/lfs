#!/usr/bin/env python3
"""
SalamOS Wallpaper Generator
Creates professional dark-themed wallpaper with gradient and logo
"""

import os
from PIL import Image, ImageDraw, ImageFont

WIDTH = 1920
HEIGHT = 1080

BG_COLOR = (26, 26, 46)
HEADER_COLOR = (15, 52, 96)
ACCENT_COLOR = (233, 69, 96)
TEXT_COLOR = (224, 224, 224)

def create_gradient(draw, width, height):
    for y in range(height):
        ratio = y / height
        r = int(BG_COLOR[0] * (1 - ratio * 0.05))
        g = int(BG_COLOR[1] * (1 - ratio * 0.05))
        b = int(BG_COLOR[2] * (1 - ratio * 0.15))
        draw.line([(0, y), (width, y)], fill=(r, g, b))

def draw_logo(draw, cx, cy, size):
    draw.ellipse(
        [cx - size, cy - size, cx + size, cy + size],
        outline=ACCENT_COLOR,
        width=3
    )
    s_size = size * 0.7
    draw.arc(
        [cx - s_size, cy - s_size, cx + s_size, cy],
        start=180, end=360,
        fill=ACCENT_COLOR,
        width=4
    )
    draw.arc(
        [cx - s_size, cy, cx + s_size, cy + s_size],
        start=0, end=180,
        fill=ACCENT_COLOR,
        width=4
    )
    draw.line([(cx - s_size, cy), (cx + s_size, cy)], fill=TEXT_COLOR, width=2)
    dot_size = 3
    draw.ellipse(
        [cx - dot_size, cy - dot_size, cx + dot_size, cy + dot_size],
        fill=ACCENT_COLOR
    )

def add_decorative_elements(draw, width, height):
    draw.line([(width * 0.1, height * 0.85), (width * 0.9, height * 0.85)],
              fill=HEADER_COLOR, width=1)
    tri_size = 30
    draw.polygon([(0, 0), (tri_size, 0), (0, tri_size)], fill=HEADER_COLOR)
    draw.polygon([(width, height), (width - tri_size, height), (width, height - tri_size)],
                 fill=HEADER_COLOR)

def create_wallpaper(output_path):
    img = Image.new('RGB', (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)
    create_gradient(draw, WIDTH, HEIGHT)
    add_decorative_elements(draw, WIDTH, HEIGHT)
    draw_logo(draw, WIDTH // 2, HEIGHT // 2 - 60, 80)
    
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 48)
        font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    title = "SalamOS"
    subtitle = "Ultra-lightweight Professional Linux"
    version = "2026.1 Zen"
    
    bbox = draw.textbbox((0, 0), title, font=font_large)
    title_width = bbox[2] - bbox[0]
    draw.text(((WIDTH - title_width) // 2, HEIGHT // 2 + 30), title, fill=TEXT_COLOR, font=font_large)
    
    bbox = draw.textbbox((0, 0), subtitle, font=font_medium)
    sub_width = bbox[2] - bbox[0]
    draw.text(((WIDTH - sub_width) // 2, HEIGHT // 2 + 90), subtitle, fill=HEADER_COLOR, font=font_medium)
    
    bbox = draw.textbbox((0, 0), version, font=font_small)
    ver_width = bbox[2] - bbox[0]
    draw.text(((WIDTH - ver_width) // 2, HEIGHT // 2 + 120), version, fill=ACCENT_COLOR, font=font_small)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Wallpaper saved to {output_path}")

def create_logo(output_path):
    size = 256
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_logo(draw, size // 2, size // 2, 60)
    
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
    except:
        font = ImageFont.load_default()
    
    draw.text((size // 2 - 30, size // 2 + 70), "Salam", fill=TEXT_COLOR, font=font)
    draw.text((size // 2 + 10, size // 2 + 70), "OS", fill=ACCENT_COLOR, font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Logo saved to {output_path}")

def create_grub_background(output_path):
    img = Image.new('RGB', (640, 480), BG_COLOR)
    draw = ImageDraw.Draw(img)
    create_gradient(draw, 640, 480)
    draw_logo(draw, 320, 200, 40)
    
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 30)
    except:
        font = ImageFont.load_default()
    
    draw.text((260, 250), "SalamOS", fill=TEXT_COLOR, font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"GRUB background saved to {output_path}")

if __name__ == '__main__':
    # Use relative path so it works both locally and in GitHub Actions
    base_dir = os.environ.get('SALAMOS_BUILD_DIR', 'build/resources')
    create_wallpaper(os.path.join(base_dir, 'salamos-wallpaper.png'))
    create_logo(os.path.join(base_dir, 'salamos-logo.png'))
    create_grub_background(os.path.join(base_dir, 'salamos-grub.png'))
