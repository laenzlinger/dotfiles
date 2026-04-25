# Opulo Lumen — Feeder Layout

Standard feeder array layout for the Opulo Lumen PnP machine.

## Bed Layout

```
   Low X (links)                              High X (rechts)

┌─────────────────────────────────────────────────────────────────┐
│                                                                 │  High Y
│  HL 8×8mm        PCB AREA                      HR 6×12mm       │  (hinten)
│  ║ ║ ║ ║ ║ ║ ║ ║                               ║ ║ ║ ║ ║ ║    │
│  (8 slots)                                     (6 slots)       │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │  Low Y
│  VL 16×8mm       [BTM CAM]  VR 8×8mm  RV 6×16mm               │  (vorne)
│  ║║║║║║║║║║║║║║║║    ◉      ║║║║║║║║  ═══ ═══ ═══             │
│  (16 slots)                 (8 slots) ═══ ═══ ═══             │
│                                       (X dir hi→lo)            │
└─────────────────────────────────────────────────────────────────┘
   Operator (vorne)
```

## Feeder Arrays

| Array | Position       | Slots | Tape Width | Strip Direction | Feed Direction |
|-------|----------------|-------|------------|-----------------|----------------|
| VL    | Vorne Links    | 16    | 8mm        | Y               | ↑ (low→high Y) |
| VR    | Vorne Rechts   | 8     | 8mm        | Y               | ↑ (low→high Y) |
| HL    | Hinten Links   | 8     | 8mm        | Y               | ↓ (high→low Y) |
| HR    | Hinten Rechts  | 6     | 12mm       | Y               | ↑              |
| RV    | Rechts Vorne   | 6     | 16mm       | X               | ← (high→low X) |

**Total: 44 feeder slots** (32×8mm + 6×12mm + 6×16mm)

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
