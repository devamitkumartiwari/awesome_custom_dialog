"""Encodes frame_%04d.png sequences into GIFs (12 fps, looping)."""
import pathlib
import sys

from PIL import Image

frames_root = pathlib.Path(sys.argv[1])
out_dir = pathlib.Path(sys.argv[2])
names = sys.argv[3:] or [p.name for p in sorted(frames_root.iterdir()) if p.is_dir()]
out_dir.mkdir(parents=True, exist_ok=True)

for name in names:
    files = sorted((frames_root / name).glob('frame_*.png'))
    if not files:
        print(f'{name}: no frames, skipped')
        continue
    frames = []
    for f in files:
        im = Image.open(f).convert('RGB')
        # One adaptive palette per frame keeps gradients and dark tones clean.
        frames.append(im.quantize(colors=255, method=Image.Quantize.MEDIANCUT,
                                  dither=Image.Dither.NONE))
    target = out_dir / f'{name}.gif'
    frames[0].save(target, save_all=True, append_images=frames[1:],
                   duration=83, loop=0, optimize=True, disposal=1)
    w, h = frames[0].size
    print(f'{name}: {len(frames)} frames, {w}x{h}, {target.stat().st_size // 1024} KB')
