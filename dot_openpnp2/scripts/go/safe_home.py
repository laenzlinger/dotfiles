"""Safe Home - disengage motors, wait for user, then home.

Use this instead of the Home button to avoid crashing into feeders.
Scripts menu -> go/safe_home.py
"""
from javax.swing import JOptionPane
from org.openpnp.util.UiUtils import submitUiMachineTask

def safe_home():
    driver = machine.getDrivers().get(0)
    driver.sendCommand("M84", 5000)

    result = JOptionPane.showConfirmDialog(
        None,
        "Motors disengaged.\nMove the head to a safe position, then click OK to home.",
        "Pre-Home Safety",
        JOptionPane.OK_CANCEL_OPTION,
        JOptionPane.WARNING_MESSAGE,
    )

    if result == JOptionPane.OK_OPTION:
        machine.home()

submitUiMachineTask(safe_home)
