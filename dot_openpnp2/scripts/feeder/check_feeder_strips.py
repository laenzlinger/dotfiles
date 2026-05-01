"""Check feeder strip alignment -- move camera to each feeder.

Auto-advances after a short pause. Click Cancel to stop and adjust.

Scripts menu -> feeder/check_feeder_strips.py
"""
from javax.swing import JOptionPane
from org.openpnp.util import MovableUtils
from org.openpnp.util.UiUtils import submitUiMachineTask
from java.lang import Thread

SKIP_PARTS = set(["CALIBRATION-DUMMY"])
PAUSE_MS = 1500


def check_strips():
    nozzle = machine.getDefaultHead().getDefaultNozzle()
    nozzle.moveToSafeZ()
    camera = machine.getDefaultHead().getDefaultCamera()

    feeders = []
    for f in machine.getFeeders():
        if not f.isEnabled():
            continue
        part = f.getPart()
        if part is None or part.getId() in SKIP_PARTS:
            continue
        feeders.append(f)

    feeders.sort(cmp=lambda a, b: cmp(a.getName(), b.getName()))

    total = len(feeders)
    i = 0
    while i < total:
        feeder = feeders[i]
        name = feeder.getName()
        part_id = feeder.getPart().getId()
        loc = feeder.getPickLocation()
        if loc is None:
            i += 1
            continue

        MovableUtils.moveToLocationAtSafeZ(camera, loc)
        Thread.sleep(PAUSE_MS)

        result = JOptionPane.showConfirmDialog(
            None,
            "[%d/%d] %s\nPart: %s\n\nOK = next\nCancel = stop here to adjust" % (
                i + 1, total, name, part_id),
            "Check Strip",
            JOptionPane.OK_CANCEL_OPTION,
            JOptionPane.QUESTION_MESSAGE)

        if result != JOptionPane.OK_OPTION:
            # Let user adjust, then retry same feeder
            retry = JOptionPane.showConfirmDialog(
                None,
                "Adjusted %s?\n\nOK = recheck this feeder\nCancel = abort" % name,
                "Retry?",
                JOptionPane.OK_CANCEL_OPTION,
                JOptionPane.QUESTION_MESSAGE)
            if retry != JOptionPane.OK_OPTION:
                break
            continue

        i += 1

    JOptionPane.showMessageDialog(
        None,
        "Checked %d of %d feeders" % (i, total))


submitUiMachineTask(check_strips)
