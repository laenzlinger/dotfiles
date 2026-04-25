#!/usr/bin/env python3
"""Remap KiCad footprint names and generate OpenPnP board XML.

Usage:
  kicad-cli pcb export pos --format csv ... | remap-pnp.py PNP_DIR

Part IDs use the original KiCad footprint name to match existing OpenPnP parts.
Package IDs use the remapped short name from openpnp-package-map.csv.
"""
import csv
import sys
from pathlib import Path

MAP_FILE = Path(__file__).parent / "openpnp-package-map.csv"


def load_map(path):
    mapping = {}
    with open(path) as f:
        for row in csv.DictReader(filter(lambda r: not r.startswith("#"), f)):
            mapping[row["kicad_footprint"]] = row["openpnp_package"]
    return mapping


def read_placements(infile, mapping):
    placements = []
    reader = csv.DictReader(infile)
    for row in reader:
        ref = (row.get("Ref") or "").strip()
        val = (row.get("Val") or "").strip()
        kicad_fp = (row.get("Package") or "").strip()
        if not ref or not kicad_fp:
            continue
        openpnp_pkg = mapping.get(kicad_fp, kicad_fp)
        placements.append({
            "ref": ref, "val": val,
            "kicad_fp": kicad_fp,
            "pkg": openpnp_pkg,
            "part_id": f"{openpnp_pkg}-{val}",
            "x": row["PosX"].strip(), "y": row["PosY"].strip(),
            "rot": row["Rot"].strip(), "side": row["Side"].strip(),
        })
    return placements


def write_pos(placements, path):
    with open(path, "w") as f:
        f.write("### Footprint positions ###\n")
        f.write("## Unit = mm, Angle = deg.\n")
        f.write("## Side : All\n")
        f.write("# Ref     Val                          Package                                    PosX       PosY       Rot  Side\n")
        for p in placements:
            f.write(f"{p['ref']:<10}{p['val']:<29}{p['pkg']:<43}{p['x']:>10}{p['y']:>11}{p['rot']:>10}  {p['side']}\n")
        f.write("## End\n")


def write_board_xml(placements, path):
    with open(path, "w") as f:
        f.write('<openpnp-board version="1.1" name="granit">\n')
        f.write('   <dimensions units="Millimeters" x="92.0" y="99.5" z="1.6" rotation="0.0"/>\n')
        f.write('   <placements>\n')
        for p in placements:
            side = p["side"].capitalize()
            f.write(f'      <placement version="1.4" id="{p["ref"]}" side="{side}" part-id="{p["part_id"]}" type="Placement" enabled="true">\n')
            f.write(f'         <location units="Millimeters" x="{p["x"]}" y="{p["y"]}" z="0.0" rotation="{p["rot"]}"/>\n')
            f.write(f'      </placement>\n')
        f.write('   </placements>\n')
        f.write('   <fiducials/>\n')
        f.write('   <solder-paste-pads/>\n')
        f.write('</openpnp-board>\n')


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: kicad-cli pcb export pos --format csv ... | remap-pnp.py PNP_DIR", file=sys.stderr)
        sys.exit(1)
    pnp_dir = Path(sys.argv[1])
    pnp_dir.mkdir(parents=True, exist_ok=True)
    mapping = load_map(MAP_FILE)
    placements = read_placements(sys.stdin, mapping)
    write_pos(placements, pnp_dir / "granit.pos")
    write_board_xml(placements, pnp_dir / "granit.board.xml")
    print(f"Wrote {len(placements)} placements to {pnp_dir}")
