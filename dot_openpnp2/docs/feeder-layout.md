# Opulo Lumen — Feeder Layout

Standard feeder array layout for the Opulo Lumen PnP machine.

## Bed Layout

```
   Low X (links)                              High X (rechts)

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │  High Y
│  LH8 8×8mm       PCB AREA                      RH12 6×12mm     │  (hinten)
│  ║ ║ ║ ║ ║ ║ ║ ║                               ║ ║ ║ ║ ║ ║    │
│  (8 slots)                                     (6 slots)       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │  Low Y
│  DRAG  LV8 16×8mm  [BTM CAM]  RV8 8×8mm  RV16 6×16mm          │  (vorne)
│  ≋≋≋≋≋≋≋≋  ║║║║║║║║║║║║║║║║  ◉     ║║║║║║║║  ═══ ═══ ═══          │
│  (8)  (16 slots)               (8 slots) ═══ ═══ ═══          │
│                                           (X dir hi→lo)        │
└─────────────────────────────────────────────────────────────────┘
   Operator (vorne)
```

## Feeder Arrays

| Array | Position       | Slots | Tape Width | Strip Direction | Feed Direction |
|-------|----------------|-------|------------|-----------------|----------------|
| LV8   | Links Vorne    | 16    | 8mm        | Y               | ↑ (low→high Y) |
| RV8   | Rechts Vorne   | 8     | 8mm        | Y               | ↑ (low→high Y) |
| LH8   | Links Hinten   | 8     | 8mm        | Y               | ↓ (high→low Y) |
| RH12  | Rechts Hinten  | 6     | 12mm       | Y               | ↑              |
| RV16  | Rechts Vorne   | 6     | 16mm       | X               | ← (high→low X) |

**Total: 44 feeder slots** (32×8mm + 6×12mm + 6×16mm)

## Naming Conventions

### Feeder Names

Format: `{Position}{TapeWidth}-{Slot}` — e.g. `LV8-01`, `RH12-3`, `RV16-5`

| Prefix | Position | Tape Width | Slots |
|--------|----------|------------|-------|
| LV8    | Links Vorne (front-left) | 8mm | 01–16 |
| RV8    | Rechts Vorne (front-right) | 8mm | 1–8 |
| LH8    | Links Hinten (back-left) | 8mm | 01–13 |
| RH12   | Rechts Hinten (back-right) | 12mm | 1–10 |
| RV16   | Rechts Vorne (front-right, beside RV8) | 16mm | 1–6 |

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

## Typical Allocation

### 8mm slots (VL + VR + HL = 32)
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
