#!/usr/bin/env python3
"""Director mode: auto-generates short vertical clips (TikTok / Shorts / Reels).

For each recipe it finds a reproducible bot run with the wanted outcome
(tools/find_run.gd), renders it at 720x1280 under a virtual display, cuts the
seconds leading up to the key moment (pop or finish), burns in a hook caption
and writes media/clips/<name>.mp4 plus a row in media/clips/clips.csv with
post title + caption + hashtags. Posting stays manual (producer's accounts).

usage: scripts/director.py [recipe_names...]   (default: all)
"""
import csv, os, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GAME = os.path.join(ROOT, "game")
OUT = os.path.join(ROOT, "media", "clips")
FONT = "/usr/share/fonts/opentype/inter/InterDisplay-Black.otf"
FPS = 30

# name, level, skill, outcome, style, hook format, hook text (TR / EN), seconds
RECIPES = [
    ("fail_l13_gece", 13, 0.3, "popped", "gece", "fail", "Bir nefes fazla...", "One breath too many...", 9),
    ("fail_l11_kagit", 11, 0.3, "popped", "kagit", "fail", "Bunu nasıl patlattım 😭", "How did I pop this 😭", 9),
    ("fail_l12_pastel", 12, 0.2, "popped", "pastel", "fail", "Rüzgâr beni sevmiyor", "The wind hates me", 9),
    ("squeeze_l2", 2, 1.0, "won", "kagit", "satisfying", "En tatmin edici sıkışma", "The most satisfying squeeze", 9),
    ("challenge_l13", 13, 1.0, "won", "gece", "challenge", "Botların %75'i burada patladı", "75% of bots popped here", 12),
    ("challenge_l15", 15, 1.0, "won", "pastel", "challenge", "Son bölüm. Geçebilir misin?", "Final level. Can you clear it?", 12),
    ("wind_l12", 12, 1.0, "won", "pastel", "before_after", "Büyük = yelken, küçük = fren", "Big = sail, small = brake", 12),
    ("solve_l9", 9, 1.0, "won", "kagit", "puzzle", "Tavanın altından nasıl geçersin?", "How do you get past the ceiling?", 12),
]
HASHTAGS = "#oyun #mobiloyun #indiegame #satisfying #ŞİŞ"


def godot(*args, display=False, timeout=1200):
    cmd = ["godot", "--path", GAME] + list(args)
    if display:
        cmd = ["xvfb-run", "-a", "-s", "-screen 0 1400x2200x24"] + cmd
    return subprocess.run(cmd, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=timeout).stdout


def find_seed(level, skill, outcome):
    out = godot("--headless", "-s", "res://tools/find_run.gd", "--", str(level), str(skill), outcome, "3600", "1", "40")
    for line in out.splitlines():
        if line.startswith("seed="):
            parts = dict(p.split("=") for p in line.split()[:2])
            return int(parts["seed"]), int(parts["frames"])
    return None, None


def burn(name, text):
    """Burns the hook caption onto the raw clip (re-runnable without re-rendering)."""
    clean = "".join(ch for ch in text if ord(ch) < 0x2000).strip()   # emoji only in post text
    size = max(44, min(70, int(1900 / max(len(clean), 1))))
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
        f.write(clean)
        txt = f.name
    vf = (f"drawtext=fontfile={FONT}:textfile={txt}:fontcolor=white:fontsize={size}:borderw=7:"
          f"bordercolor=#2b2522:expansion=none:x=(w-text_w)/2:y=260")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", os.path.join(OUT, "raw", f"{name}.mp4"), "-vf", vf,
                    "-c:v", "libx264", "-crf", "21", "-preset", "veryfast", "-c:a", "copy",
                    os.path.join(OUT, f"{name}.mp4")], check=True)
    os.unlink(txt)


def make(recipe, writer):
    name, level, skill, outcome, style, fmt, tr, en, secs = recipe
    seed, sim_frames = find_seed(level, skill, outcome)
    if seed is None:
        print(f"[skip] {name}: no {outcome} run found")
        return
    event = sim_frames // 2                       # sim runs at 60 Hz, capture at 30 fps
    end = event + int(1.6 * FPS)
    start = max(end - secs * FPS, 0)
    with tempfile.TemporaryDirectory() as tmp:
        godot("--rendering-driver", "opengl3", "--resolution", "720x1280", "--write-movie", f"{tmp}/f.png",
              "--fixed-fps", str(FPS), "--quit-after", str(end + 5), "--", "demo", "style", style,
              "autoplay", str(level), str(skill), str(seed + 1), "1", display=True)
        os.makedirs(os.path.join(OUT, "raw"), exist_ok=True)
        raw = os.path.join(OUT, "raw", f"{name}.mp4")
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", str(FPS), "-start_number", str(start),
                        "-i", f"{tmp}/f%08d.png", "-ss", f"{start / FPS:.3f}", "-t", f"{(end - start) / FPS:.3f}",
                        "-i", f"{tmp}/f.wav", "-frames:v", str(end - start),
                        "-vf", "scale=1080:1920:flags=lanczos,format=yuv420p", "-c:v", "libx264", "-crf", "20",
                        "-preset", "veryfast", "-c:a", "aac", "-b:a", "128k", "-shortest", raw], check=True)
    burn(name, tr)
    writer.writerow([f"{name}.mp4", fmt, level, style, tr, en, f"{tr} {HASHTAGS}", f"{en} #mobilegame #indiegame #satisfying"])
    print(f"[ok] {name} level={level} seed={seed} {outcome}@{event}f")


def main():
    if sys.argv[1:2] == ["--reburn"]:          # captions only, from media/clips/raw
        for r in RECIPES:
            if os.path.exists(os.path.join(OUT, "raw", f"{r[0]}.mp4")):
                burn(r[0], r[6])
        return
    wanted = set(sys.argv[1:])
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, "clips.csv")
    new = not os.path.exists(path)
    with open(path, "a", newline="") as f:
        w = csv.writer(f)
        if new:
            w.writerow(["file", "format", "level", "style", "hook_tr", "hook_en", "post_tr", "post_en"])
        for r in RECIPES:
            if not wanted or r[0] in wanted:
                make(r, w)


if __name__ == "__main__":
    main()
