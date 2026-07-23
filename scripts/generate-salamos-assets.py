#!/usr/bin/env python3
"""
SalamOS Asset Generator 2026 - Professional Modern Design
Creates stunning gradient wallpaper with flowing waves (like Windows 11 Bloom / Nexora OS)
Generates logo, GRUB background, and desktop icons
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# === NEW COLOR PALETTE - Vibrant Modern 2026 ===
# Inspired by Windows 11 Bloom + Nexora OS + SalamOS identity
# Deep blues, violet, magenta - NOT plain dark/black

WIDTH = 1920
HEIGHT = 1080

# Gradient base colors (top to bottom flow)
COLOR_DEEP_NAVY    = (13, 17, 35)      # #0d1123 - deepest background
COLOR_DARK_BLUE    = (22, 33, 62)      # #16213e - dark blue layer  
COLOR_MID_BLUE     = (15, 52, 96)      # #0f3460 - mid blue 
COLOR_ROYAL_BLUE   = (45, 70, 140)     # #2d468c - royal blue highlight
COLOR_VIOLET       = (124, 58, 237)    # #7c3aed - vibrant violet accent
COLOR_MAGENTA      = (233, 69, 96)     # #e94560 - coral/magenta accent
COLOR_PINK_GLOW    = (200, 80, 140)    # #c8508c - pink glow
COLOR_SOFT_PINK    = (255, 120, 180)   # #ff78b4 - soft pink highlight
COLOR_LIGHT_BLUE   = (100, 140, 220)   # #648cdc - light blue shimmer
COLOR_WHITE_SHIMMER = (220, 230, 255)  # #dce6ff - white shimmer

def create_wave_gradient(draw, width, height):
    """Create the stunning flowing gradient base - like Windows 11 Bloom wallpaper"""
    for y in range(height):
        ratio = y / height
        
        # Multi-layered gradient blending:
        # Top: deep navy → dark blue
        # Middle: royal blue → violet → magenta glow
        # Bottom: soft pink → light blue shimmer
        
        if ratio < 0.3:
            # Top section: deep navy to dark blue
            t = ratio / 0.3
            r = int(COLOR_DEEP_NAVY[0] + (COLOR_DARK_BLUE[0] - COLOR_DEEP_NAVY[0]) * t)
            g = int(COLOR_DEEP_NAVY[1] + (COLOR_DARK_BLUE[1] - COLOR_DEEP_NAVY[1]) * t)
            b = int(COLOR_DEEP_NAVY[2] + (COLOR_DARK_BLUE[2] - COLOR_DEEP_NAVY[2]) * t)
        elif ratio < 0.55:
            # Upper-mid: dark blue to royal blue with violet hints
            t = (ratio - 0.3) / 0.25
            r = int(COLOR_DARK_BLUE[0] + (COLOR_ROYAL_BLUE[0] - COLOR_DARK_BLUE[0]) * t)
            g = int(COLOR_DARK_BLUE[1] + (COLOR_ROYAL_BLUE[1] - COLOR_DARK_BLUE[1]) * t)
            b = int(COLOR_DARK_BLUE[2] + (COLOR_VIOLET[2] - COLOR_DARK_BLUE[2]) * t * 0.6)
        elif ratio < 0.75:
            # Center: royal blue → violet → magenta glow (the Bloom!)
            t = (ratio - 0.55) / 0.2
            r = int(COLOR_ROYAL_BLUE[0] + (COLOR_MAGENTA[0] - COLOR_ROYAL_BLUE[0]) * t)
            g = int(COLOR_ROYAL_BLUE[1] + (COLOR_MAGENTA[1] - COLOR_ROYAL_BLUE[1]) * t * 0.5)
            b = int(COLOR_VIOLET[2] + (COLOR_PINK_GLOW[2] - COLOR_VIOLET[2]) * t)
        else:
            # Bottom: magenta → soft pink → light shimmer
            t = (ratio - 0.75) / 0.25
            r = int(COLOR_MAGENTA[0] + (COLOR_LIGHT_BLUE[0] - COLOR_MAGENTA[0]) * t * 0.3)
            g = int(COLOR_PINK_GLOW[1] + (COLOR_LIGHT_BLUE[1] - COLOR_PINK_GLOW[1]) * t * 0.4)
            b = int(COLOR_PINK_GLOW[2] + (COLOR_LIGHT_BLUE[2] - COLOR_PINK_GLOW[2]) * t * 0.5)
        
        draw.line([(0, y), (width, y)], fill=(r, g, b))


def draw_flowing_waves(draw, width, height):
    """Draw flowing wave curves like Windows 11 Bloom / abstract fluid art"""
    import random
    # Seed for consistent generation
    random.seed(42)
    
    # Multiple wave layers with different colors and opacity
    wave_configs = [
        # (color, amplitude, frequency, phase, y_center, thickness, alpha_blend)
        (COLOR_VIOLET,       80, 0.008, 0.0,   height * 0.55, 3, 0.6),
        (COLOR_MAGENTA,      60, 0.012, 1.5,   height * 0.60, 2, 0.5),
        (COLOR_ROYAL_BLUE,   90, 0.006, 0.8,   height * 0.50, 4, 0.7),
        (COLOR_PINK_GLOW,    50, 0.015, 2.0,   height * 0.65, 2, 0.4),
        (COLOR_LIGHT_BLUE,   70, 0.010, 3.0,   height * 0.45, 3, 0.5),
        (COLOR_SOFT_PINK,    40, 0.018, 1.0,   height * 0.70, 1, 0.3),
        (COLOR_VIOLET,       55, 0.013, 2.5,   height * 0.58, 2, 0.4),
        (COLOR_WHITE_SHIMMER,30, 0.020, 0.5,   height * 0.52, 1, 0.2),
    ]
    
    for color, amp, freq, phase, y_center, thickness, alpha_blend in wave_configs:
        points = []
        for x in range(0, width, 2):
            y = y_center + amp * math.sin(freq * x + phase) + amp * 0.3 * math.sin(freq * 2.5 * x + phase + 1)
            points.append((x, int(y)))
        
        # Draw the wave line with blended color
        blended_r = int(color[0] * alpha_blend + (15 + int(x / width * 30)) * (1 - alpha_blend))
        blended_g = int(color[1] * alpha_blend + (20 + int(x / width * 20)) * (1 - alpha_blend))
        blended_b = int(color[2] * alpha_blend + (40 + int(x / width * 50)) * (1 - alpha_blend))
        blended = (min(255, blended_r), min(255, blended_g), min(255, blended_b))
        
        for i in range(len(points) - 1):
            # Vary color along the wave for more organic feel
            x_pos = points[i][0]
            progress = x_pos / width
            local_r = int(color[0] * (alpha_blend + progress * 0.3) + blended_r * (1 - progress * 0.3))
            local_g = int(color[1] * (alpha_blend + progress * 0.2) + blended_g * (1 - progress * 0.2))
            local_b = int(color[2] * (alpha_blend + progress * 0.1) + blended_b * (1 - progress * 0.1))
            local_color = (min(255, max(0, local_r)), min(255, max(0, local_g)), min(255, max(0, local_b)))
            
            draw.line([points[i], points[i+1]], fill=local_color, width=thickness)


def draw_glow_center(draw, width, height):
    """Draw a soft glow emanating from the center-bottom - like the Bloom light source"""
    cx = width // 2
    cy = int(height * 0.65)
    
    # Radial glow effect - concentric circles with decreasing opacity
    for radius in range(200, 10, -5):
        alpha = max(0, min(60, int(60 * (1 - radius / 200))))
        # Blend from magenta/pink center to violet edges
        t = radius / 200
        r = int(COLOR_MAGENTA[0] * (1-t) + COLOR_VIOLET[0] * t)
        g = int(COLOR_MAGENTA[1] * (1-t) + COLOR_VIOLET[1] * t)
        b = int(COLOR_MAGENTA[2] * (1-t) + COLOR_VIOLET[2] * t)
        draw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
                     fill=(r, g, b, alpha) if draw.im.mode == 'RGBA' else (r, g, b),
                     outline=None)


def draw_salamos_logo(draw, cx, cy, size):
    """Draw the SalamOS infinity/salam logo - elegant and modern"""
    # Outer circle - subtle glow ring
    for r_offset in range(6, 0, -1):
        alpha_factor = (7 - r_offset) / 7
        r = int(COLOR_MAGENTA[0] * alpha_factor)
        g = int(COLOR_MAGENTA[1] * alpha_factor * 0.5)
        b = int(COLOR_VIOLET[2] * alpha_factor)
        draw.ellipse(
            [cx - size - r_offset, cy - size - r_offset, cx + size + r_offset, cy + size + r_offset],
            outline=(r, g, b),
            width=1
        )
    
    # Main circle ring
    draw.ellipse(
        [cx - size, cy - size, cx + size, cy + size],
        outline=COLOR_MAGENTA,
        width=3
    )
    
    # Infinity/salam symbol - two interlocking arcs
    s_size = size * 0.65
    # Top arc
    draw.arc(
        [cx - s_size, cy - s_size, cx + s_size, cy],
        start=180, end=360,
        fill=COLOR_VIOLET,
        width=4
    )
    # Bottom arc
    draw.arc(
        [cx - s_size, cy, cx + s_size, cy + s_size],
        start=0, end=180,
        fill=COLOR_MAGENTA,
        width=4
    )
    # Center line
    draw.line([(cx - s_size, cy), (cx + s_size, cy)], fill=COLOR_WHITE_SHIMMER, width=2)
    # Center dot
    draw.ellipse(
        [cx - 4, cy - 4, cx + 4, cy + 4],
        fill=COLOR_MAGENTA
    )


def add_particle_effects(draw, width, height):
    """Add subtle light particles/dots for depth - like floating light specs"""
    import random
    random.seed(123)
    
    for _ in range(80):
        x = random.randint(0, width)
        y = random.randint(int(height * 0.3), int(height * 0.8))
        size = random.randint(1, 3)
        # Choose from accent colors
        colors = [COLOR_VIOLET, COLOR_LIGHT_BLUE, COLOR_WHITE_SHIMMER, COLOR_PINK_GLOW]
        color = random.choice(colors)
        # Dim the color based on distance from center glow
        dist_factor = max(0.2, 1 - abs(y - height * 0.65) / (height * 0.4))
        r = int(color[0] * dist_factor)
        g = int(color[1] * dist_factor)
        b = int(color[2] * dist_factor)
        draw.ellipse([x - size, y - size, x + size, y + size], fill=(r, g, b))


def create_wallpaper(output_path):
    """Create the stunning SalamOS 2026 wallpaper"""
    img = Image.new('RGB', (WIDTH, HEIGHT), COLOR_DEEP_NAVY)
    draw = ImageDraw.Draw(img)
    
    # Layer 1: Base gradient
    create_wave_gradient(draw, WIDTH, HEIGHT)
    
    # Layer 2: Flowing wave curves
    draw_flowing_waves(draw, WIDTH, HEIGHT)
    
    # Layer 3: Center glow
    draw_glow_center(draw, WIDTH, HEIGHT)
    
    # Layer 4: Light particles
    add_particle_effects(draw, WIDTH, HEIGHT)
    
    # Layer 5: Logo (subtle, bottom-right area)
    logo_x = WIDTH // 2
    logo_y = int(HEIGHT * 0.35)
    draw_salamos_logo(draw, logo_x, logo_y, 60)
    
    # Layer 6: Text branding
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 52)
        font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 22)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
    except OSError:
        try:
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf", 52)
            font_medium = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans.ttf", 22)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationSans.ttf", 16)
        except OSError:
            font_large = ImageFont.load_default()
            font_medium = ImageFont.load_default()
            font_small = ImageFont.load_default()
    
    # Title text - positioned below logo
    title = "SalamOS"
    subtitle = "Ultra-lightweight Professional Linux"
    version = "2026.1 Zen"
    
    # Title with glow effect
    bbox = draw.textbbox((0, 0), title, font=font_large)
    title_width = bbox[2] - bbox[0]
    title_x = (WIDTH - title_width) // 2
    title_y = logo_y + 75
    
    # Shadow/glow behind title
    for offset in range(4, 0, -1):
        glow_color = (int(COLOR_MAGENTA[0] * 0.3 * offset), 
                      int(COLOR_MAGENTA[1] * 0.2 * offset), 
                      int(COLOR_VIOLET[2] * 0.3 * offset))
        draw.text((title_x + offset, title_y + offset), title, fill=glow_color, font=font_large)
    draw.text((title_x, title_y), title, fill=COLOR_WHITE_SHIMMER, font=font_large)
    
    # Subtitle
    bbox = draw.textbbox((0, 0), subtitle, font=font_medium)
    sub_width = bbox[2] - bbox[0]
    draw.text(((WIDTH - sub_width) // 2, title_y + 60), subtitle, fill=COLOR_LIGHT_BLUE, font=font_medium)
    
    # Version
    bbox = draw.textbbox((0, 0), version, font=font_small)
    ver_width = bbox[2] - bbox[0]
    draw.text(((WIDTH - ver_width) // 2, title_y + 88), version, fill=COLOR_MAGENTA, font=font_small)
    
    # Apply slight Gaussian blur for softer look (makes it feel more organic)
    img = img.filter(ImageFilter.GaussianBlur(radius=1))
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG', optimize=True)
    print(f"Wallpaper saved to {output_path}")


def create_logo(output_path):
    """Create the SalamOS logo icon"""
    size = 256
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background circle with gradient feel
    for r in range(size // 2, 0, -2):
        t = r / (size // 2)
        cr = int(COLOR_DEEP_NAVY[0] * t + COLOR_VIOLET[0] * (1-t) * 0.6)
        cg = int(COLOR_DEEP_NAVY[1] * t + COLOR_VIOLET[1] * (1-t) * 0.3)
        cb = int(COLOR_DEEP_NAVY[2] * t + COLOR_VIOLET[2] * (1-t))
        draw.ellipse([size//2 - r, size//2 - r, size//2 + r, size//2 + r], fill=(cr, cg, cb))
    
    # Logo symbol
    draw_salamos_logo(draw, size // 2, size // 2 - 10, 55)
    
    # Text below logo
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22)
    except OSError:
        font = ImageFont.load_default()
    
    draw.text((size // 2 - 35, size // 2 + 55), "Salam", fill=COLOR_WHITE_SHIMMER, font=font)
    draw.text((size // 2 + 15, size // 2 + 55), "OS", fill=COLOR_MAGENTA, font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Logo saved to {output_path}")


def create_grub_background(output_path):
    """Create GRUB boot background"""
    img = Image.new('RGB', (640, 480), COLOR_DEEP_NAVY)
    draw = ImageDraw.Draw(img)
    
    # Simplified gradient for GRUB
    create_wave_gradient(draw, 640, 480)
    
    # Simplified waves
    wave_configs = [
        (COLOR_VIOLET, 30, 0.012, 0.0, 240, 2, 0.5),
        (COLOR_MAGENTA, 20, 0.018, 1.5, 260, 1, 0.4),
        (COLOR_ROYAL_BLUE, 40, 0.008, 0.8, 220, 3, 0.6),
    ]
    
    for color, amp, freq, phase, y_center, thickness, alpha_blend in wave_configs:
        points = []
        for x in range(0, 640, 3):
            y = y_center + amp * math.sin(freq * x + phase)
            points.append((x, int(y)))
        for i in range(len(points) - 1):
            draw.line([points[i], points[i+1]], fill=color, width=thickness)
    
    # Logo
    draw_salamos_logo(draw, 320, 160, 30)
    
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
    except OSError:
        font = ImageFont.load_default()
    
    draw.text((270, 200), "SalamOS", fill=COLOR_WHITE_SHIMMER, font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"GRUB background saved to {output_path}")


if __name__ == '__main__':
    base_dir = os.environ.get('SALAMOS_BUILD_DIR', 'build/resources')
    create_wallpaper(os.path.join(base_dir, 'salamos-wallpaper.png'))
    create_logo(os.path.join(base_dir, 'salamos-logo.png'))
    create_grub_background(os.path.join(base_dir, 'salamos-grub.png'))
