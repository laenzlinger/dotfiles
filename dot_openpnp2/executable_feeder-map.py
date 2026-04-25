#!/usr/bin/env python3
"""Generate an SVG feeder map from OpenPnP machine.xml.

Reads feeder positions and part assignments directly from the XML,
no running OpenPnP instance needed.

Usage: python3 feeder_map.py [machine.xml] [output.svg]
"""
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

MACHINE_XML = Path.home() / ".openpnp2" / "machine.xml"
SCALE = 3
MARGIN = 50
FONT_SIZE = 10


def parse_feeders(path):
    tree = ET.parse(path)
    feeders = []
    for f in tree.iter():
        if f.tag != "feeder":
            continue
        enabled = f.get("enabled", "false") == "true"
        name = f.get("name", "")
        part = f.get("part-id", "")
        ref = f.find("reference-hole-location")
        last = f.find("last-hole-location")
        if ref is None:
            continue
        x1, y1 = float(ref.get("x", 0)), float(ref.get("y", 0))
        if x1 == 0 and y1 == 0:
            continue
        x2, y2 = x1, y1
        if last is not None:
            x2, y2 = float(last.get("x", x1)), float(last.get("y", y1))
        feeders.append({
            "name": name, "part": part, "enabled": enabled,
            "x1": x1, "y1": y1, "x2": x2, "y2": y2,
        })
    return feeders


def generate_svg(feeders, path):
    if not feeders:
        print("No feeders with positions found")
        return
    xs = [f["x1"] for f in feeders] + [f["x2"] for f in feeders]
    ys = [f["y1"] for f in feeders] + [f["y2"] for f in feeders]
    x_min, x_max = min(xs), max(xs)
    y_min, y_max = min(ys), max(ys)

    w = (x_max - x_min) * SCALE + 2 * MARGIN
    h = (y_max - y_min) * SCALE + 2 * MARGIN

    def tx(x):
        return (x - x_min) * SCALE + MARGIN

    def ty(y):
        return h - ((y - y_min) * SCALE + MARGIN)

    lines = []
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w:.0f}" height="{h:.0f}">')
    lines.append(f'<rect width="100%" height="100%" fill="white"/>')
    lines.append(f'<text x="10" y="20" font-size="14" font-family="monospace">Feeder Map ({len(feeders)} feeders)</text>')

    for f in feeders:
        sx, sy = tx(f["x1"]), ty(f["y1"])
        ex, ey = tx(f["x2"]), ty(f["y2"])
        color = "#2a9d8f" if f["enabled"] else "#e76f51"
        opacity = "1.0" if f["enabled"] else "0.4"
        label = f["part"].rsplit("-", 1)[-1] if f["part"] else f["name"]

        # Feed direction line
        lines.append(f'<line x1="{sx:.1f}" y1="{sy:.1f}" x2="{ex:.1f}" y2="{ey:.1f}" stroke="{color}" stroke-width="2" opacity="{opacity}"/>')
        # Start dot
        lines.append(f'<circle cx="{sx:.1f}" cy="{sy:.1f}" r="3" fill="{color}" opacity="{opacity}"/>')
        # Label
        lines.append(f'<text x="{sx + 5:.1f}" y="{sy - 5:.1f}" font-size="{FONT_SIZE}" font-family="monospace" fill="{color}" opacity="{opacity}">{f["name"]}: {label}</text>')

    lines.append('</svg>')

    Path(path).write_text("\n".join(lines))
    enabled = sum(1 for f in feeders if f["enabled"])
    print(f"Wrote {len(feeders)} feeders ({enabled} enabled) to {path}")


if __name__ == "__main__":
    machine = Path(sys.argv[1]) if len(sys.argv) > 1 else MACHINE_XML
    output = sys.argv[2] if len(sys.argv) > 2 else "pnp/feed_map.svg"
    feeders = parse_feeders(machine)
    generate_svg(feeders, output)
