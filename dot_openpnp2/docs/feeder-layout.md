# Opulo Lumen — Feeder Layout

> **⚠️ Always close OpenPnP before editing config files externally.**
> OpenPnP overwrites machine.xml on save/exit, discarding any external changes.

Standard feeder array layout for the Opulo Lumen PnP machine.

## Bed Layout

```
   Low X (links)                              High X (rechts)

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │  High Y
│  LH08 8×8mm      PCB AREA                      RH12 6×12mm     │  (hinten)
│  ║ ║ ║ ║ ║ ║ ║ ║                               ║ ║ ║ ║ ║ ║    │
│  (8 slots)                                     (6 slots)       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │  Low Y
│  DRAG  LV08 16×8mm  [BTM CAM]  RV08 8×8mm  RV16 6×16mm         │  (vorne)
│  ≋≋≋≋≋≋≋≋  ║║║║║║║║║║║║║║║║  ◉     ║║║║║║║║  ═══ ═══ ═══          │
│  (8)  (16 slots)               (8 slots) ═══ ═══ ═══          │
│                                           (X dir hi→lo)        │
└─────────────────────────────────────────────────────────────────┘
   Operator (vorne)
```

## Feeder Arrays

| Array | Position       | Slots | Tape Width | Strip Direction | Feed Direction |
|-------|----------------|-------|------------|-----------------|----------------|
| LV08  | Links Vorne    | 16    | 8mm        | Y               | ↑ (low→high Y) |
| RV08  | Rechts Vorne   | 8     | 8mm        | Y               | ↑ (low→high Y) |
| LH08  | Links Hinten   | 8     | 8mm        | Y               | ↓ (high→low Y) |
| RH12  | Rechts Hinten  | 6     | 12mm       | Y               | ↑              |
| RV16  | Rechts Vorne   | 6     | 16mm       | X               | ← (high→low X) |
| DV08   | Drag Vorne (far left)    | 8     | 8mm        | Y               | ↑              |

**Total: 44 feeder slots** (32×8mm + 6×12mm + 6×16mm)

## Naming Conventions

### Feeder Names

Format: `{Position}{TapeWidth}-{Slot}` — e.g. `LV08-01`, `RH12-03`, `RV16-05`

| Prefix | Position | Tape Width | Slots |
|--------|----------|------------|-------|
| LV08   | Links Vorne (front-left) | 8mm | 01–16 |
| RV08   | Rechts Vorne (front-right) | 8mm | 01–08 |
| LH08   | Links Hinten (back-left) | 8mm | 01–08 |
| RH12   | Rechts Hinten (back-right) | 12mm | 01–06 |
| RV16   | Rechts Vorne (front-right, beside RV08) | 16mm | 01–06 |
| DV08   | Drag Vorne (far left)    | 8     | 8mm        | Y               | ↑              |

### Package Names

Short names mapped from KiCad footprints via `openpnp-package-map.csv`:

| Package | Example footprint |
|---------|-------------------|
| C_0805  | C_0805_2012Metric |
| R_0805  | R_0805_2012Metric |
| SOT-23  | SOT-23 |
| SOIC-8  | SOIC-8_3.9x4.9mm_P1.27mm |
| QFN-48-7x7 | QFN50P700X700X90-49N-D |

### Part IDs

Format: `{Package}-{Value}` — e.g. `C_0805-100n`, `R_0805-10K`, `SOT-23-2N7002`

Parts are shared across all projects. The package map ensures consistent naming
regardless of which KiCad library the footprint came from.

## Tape Defaults

| Tape Width | Tape Type    | Part Pitch | Typical Components |
|------------|-------------|------------|-------------------|
| 8mm        | WhitePaper   | 4mm        | 0805 R/C/LED, SOT-23, SOT-23-5/6 |
| 8mm        | BlackPlastic | 4mm        | Oscillators, small ICs |
| 8mm        | ClearPlastic | 4mm        | Ceramic caps (1µF+) |
| 12mm       | BlackPlastic | 8mm        | SOIC-8, SOT-223, 2512 fuses |
| 12mm       | ClearPlastic | 8mm        | Tantalum caps |
| 16mm       | BlackPlastic | 12mm       | QFN-32/48, TSSOP, large ICs |
| 16mm       | WhitePaper   | 12mm       | Connectors (USB, etc.) |

> **Part pitch** is the distance between component centers on the tape.
> **Sprocket pitch** is always 4mm for all tape widths (EIA-481).
> Adjust part-pitch per feeder if the actual tape differs.

## Typical Allocation

### 8mm slots (LV08 + RV08 + LH08 = 32)
- 0805 capacitors (C_0805)
- 0805 resistors (R_0805)
- 0805 LEDs (LED_0805)
- SOT-23 / SOT-23-5 / SOT-23-6 ICs
- Small crystals (2016)

### 12mm slots (HR = 6)
- SOIC-8 ICs
- SOT-223 regulators
- 2512 fuses
- Tantalum capacitors (EIA-7343)

### 16mm slots (RV = 6)
- QFN packages (7×7mm and larger)
- PLCC4 LEDs (WS2812B / SK6812)
- Large ICs
