#!/usr/bin/env python3
"""Remap KiCad footprint names in a PnP position CSV to OpenPnP package IDs.

Reads CSV from stdin, writes KiCad ASCII .pos format to stdout.
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


def remap(infile, outfile, mapping):
    reader = csv.DictReader(infile)
    outfile.write("# Ref     Val                          Package                                    PosX       PosY       Rot  Side\n")
    for row in reader:
        ref = (row.get("Ref") or "").strip()
        val = (row.get("Val") or "").strip()
        pkg = (row.get("Package") or "").strip()
        if not ref or not pkg:
            continue
        pkg = mapping.get(pkg, pkg)
        x = row["PosX"].strip()
        y = row["PosY"].strip()
        rot = row["Rot"].strip()
        side = row["Side"].strip()
        outfile.write(f"{ref:<10}{val:<29}{pkg:<43}{x:>10}{y:>11}{rot:>10}  {side}\n")


if __name__ == "__main__":
    mapping = load_map(MAP_FILE)
    remap(sys.stdin, sys.stdout, mapping)
