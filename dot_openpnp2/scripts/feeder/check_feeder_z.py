"""Check feeder Z heights -- jog N1 to each feeder pick location.

Moves to safe Z first, then XY, then presents dialog before lowering.

Scripts menu -> feeder/check_feeder_z.py
"""
from javax.swing import JOptionPane
from org.openpnp.util import MovableUtils
from org.openpnp.util.UiUtils import submitUiMachineTask

SKIP_PARTS = set(["CALIBRATION-DUMMY"])
PREFIXES = ("LV08", "RV08", "RH12", "RV16")


def check_feeders():
    nozzle = machine.getDefaultHead().getDefaultNozzle()
    feeders = []
    for f in machine.getFeeders():
        name = f.getName()
        part = f.getPart()
        part_id = part.getId() if part else ""
        ok = False
        for p in PREFIXES:
            if name.startswith(p):
                ok = True
                break
        if not ok:
            continue
        if part_id in SKIP_PARTS:
            continue
        feeders.append((name, f, part_id))

    feeders.sort(cmp=lambda a, b: cmp(a[0], b[0]))

    total = len(feeders)
    for i in range(total):
        name, feeder, part_id = feeders[i]
        loc = feeder.getPickLocation()

        MovableUtils.moveToLocationAtSafeZ(nozzle, loc.derive(None, None, 0.0, None))

        msg = "[%d/%d] %s\nPart: %s\nPick Z = %.2f mm\n\nNozzle is at safe Z above pick location.\nManually jog Z down to check height.\nOK = next, Cancel = stop" % (
            i + 1, total, name, part_id, loc.getZ())
        result = JOptionPane.showConfirmDialog(
            None, msg, "Check Feeder Z",
            JOptionPane.OK_CANCEL_OPTION,
            JOptionPane.INFORMATION_MESSAGE)
        if result != JOptionPane.OK_OPTION:
            break

    nozzle.moveToSafeZ()


submitUiMachineTask(check_feeders)
