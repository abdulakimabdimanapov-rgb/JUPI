

import struct
import zlib
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from validators.asset_validator import get_png_dimensions

TILE_SIZE = 16
SHEET_COLS = 8


def read_png_pixels(path: Path) -> tuple:

    import struct, zlib

    with open(path, "rb") as f:
        sig = f.read(8)
        if sig != b"\x89PNG\r\n\x1a\n":
            raise ValueError(f"Not a PNG: {path}")

        width = height = 0
        pixel_data = b""
        idat_chunks = []

        while True:
            raw_len = f.read(4)
            if len(raw_len) < 4:
                break
            chunk_len = struct.unpack(">I", raw_len)[0]
            chunk_type = f.read(4)
            chunk_data = f.read(chunk_len)
            f.read(4)

            if chunk_type == b"IHDR":
                width = struct.unpack(">I", chunk_data[0:4])[0]
                height = struct.unpack(">I", chunk_data[4:8])[0]
            elif chunk_type == b"IDAT":
                idat_chunks.append(chunk_data)
            elif chunk_type == b"IEND":
                break

        raw = zlib.decompress(b"".join(idat_chunks))

        stride = 1 + width * 4
        pixels = bytearray()
        prev_row = bytearray(stride)

        for y in range(height):
            row_start = y * stride
            filter_type = raw[row_start]
            row = bytearray(raw[row_start + 1:row_start + stride])

            if filter_type == 0:
                pass
            elif filter_type == 1:
                for i in range(4, len(row)):
                    row[i] = (row[i] + row[i - 4]) & 0xFF
            elif filter_type == 2:
                for i in range(len(row)):
                    row[i] = (row[i] + prev_row[i]) & 0xFF
            elif filter_type == 3:
                for i in range(len(row)):
                    a = row[i - 4] if i >= 4 else 0
                    b = prev_row[i]
                    row[i] = (row[i] + (a + b) // 2) & 0xFF
            elif filter_type == 4:
                for i in range(len(row)):
                    a = row[i - 4] if i >= 4 else 0
                    b = prev_row[i]
                    c = prev_row[i - 4] if i >= 4 else 0
                    p = a + b - c
                    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                    pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                    row[i] = (row[i] + pr) & 0xFF

            prev_row = bytearray(row)
            pixels.extend(row)

        return width, height, bytes(pixels)


def write_png(path: Path, width: int, height: int, pixels: bytes):

    def chunk(ctype, data):
        c = ctype + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

    raw_rows = []
    stride = width * 4
    for y in range(height):
        raw_rows.append(b"\x00")
        raw_rows.append(pixels[y * stride:(y + 1) * stride])

    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(b"".join(raw_rows), 9)))
        f.write(chunk(b"IEND", b""))


def stitch_rows(row_paths: list, output_path: Path) -> bool:

    if not row_paths:
        print("No row files provided.")
        return False

    w0, h0, _ = read_png_pixels(row_paths[0])
    if h0 != TILE_SIZE:
        print(f"Warning: Row height is {h0}, expected {TILE_SIZE}")

    max_frames = 0
    rows_data = []
    for rp in row_paths:
        w, h, pixels = read_png_pixels(rp)
        frames = w // TILE_SIZE
        max_frames = max(max_frames, frames)
        rows_data.append((w, h, pixels))

    sheet_w = max_frames * TILE_SIZE
    sheet_h = len(row_paths) * TILE_SIZE

    sheet = bytearray(sheet_w * sheet_h * 4)

    for row_idx, (w, h, pixels) in enumerate(rows_data):
        src_frames = w // TILE_SIZE
        for frame in range(min(src_frames, max_frames)):
            for y in range(min(h, TILE_SIZE)):
                for x in range(TILE_SIZE):
                    src_x = frame * TILE_SIZE + x
                    src_y = y
                    if src_x < w and src_y < h:
                        src_offset = (src_y * w + src_x) * 4
                        dst_x = frame * TILE_SIZE + x
                        dst_y = row_idx * TILE_SIZE + y
                        dst_offset = (dst_y * sheet_w + dst_x) * 4
                        sheet[dst_offset:dst_offset + 4] = pixels[src_offset:src_offset + 4]

    write_png(output_path, sheet_w, sheet_h, bytes(sheet))
    print(f"✓ Stitched {len(row_paths)} rows → {output_path} ({sheet_w}x{sheet_h})")
    return True


def stitch_from_directory(dirpath: Path, output_name: str) -> bool:

    rows = sorted(dirpath.glob("*_sheet.png"))
    if not rows:
        print(f"No *_sheet.png files found in {dirpath}")
        return False

    output_path = dirpath.parent / output_name
    return stitch_rows([str(r) for r in rows], output_path)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    if sys.argv[1] == "--from-dir" and len(sys.argv) >= 4:
        dirpath = Path(sys.argv[2])
        output_name = sys.argv[3]
        success = stitch_from_directory(dirpath, output_name)
    elif len(sys.argv) >= 3:
        output_path = Path(sys.argv[1])
        row_paths = [Path(p) for p in sys.argv[2:]]
        success = stitch_rows(row_paths, output_path)
    else:
        print("Invalid arguments.")
        print(__doc__)
        sys.exit(1)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
