#!/usr/bin/env python3
"""Remap KiCad footprint names in a PnP position CSV to OpenPnP package IDs."""
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
    writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
    writer.writeheader()
    for row in reader:
        pkg = row.get("Package", "")
        if pkg in mapping:
            row["Package"] = mapping[pkg]
        writer.writerow(row)


if __name__ == "__main__":
    mapping = load_map(MAP_FILE)
    if len(sys.argv) == 3:
        with open(sys.argv[1]) as inf, open(sys.argv[2], "w", newline="") as outf:
            remap(inf, outf, mapping)
    else:
        remap(sys.stdin, sys.stdout, mapping)
