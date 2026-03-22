#!/usr/bin/env bash
set -euo pipefail

bat="/sys/class/power_supply/BAT0"
status=$(cat "$bat/status")
capacity=$(cat "$bat/capacity")
power_uw=$(cat "$bat/power_now" 2>/dev/null || echo 0)
voltage_uv=$(cat "$bat/voltage_now" 2>/dev/null || echo 0)
energy_now=$(cat "$bat/energy_now" 2>/dev/null || echo 0)
energy_full=$(cat "$bat/energy_full" 2>/dev/null || echo 0)
energy_design=$(cat "$bat/energy_full_design" 2>/dev/null || echo 0)
cycles=$(cat "$bat/cycle_count" 2>/dev/null || echo "?")

power_w=$(awk "BEGIN {printf \"%.1f\", $power_uw/1000000}")
voltage_v=$(awk "BEGIN {printf \"%.1f\", $voltage_uv/1000000}")
health=$(awk "BEGIN {printf \"%.0f\", $energy_full/$energy_design*100}")

# Time estimate
time_str=""
if [[ "$status" == "Charging" && "$power_uw" -gt 0 ]]; then
  remaining_uwh=$((energy_full - energy_now))
  mins=$(awk "BEGIN {printf \"%.0f\", $remaining_uwh/$power_uw*60}")
  time_str="$(( mins / 60 )):$(printf '%02d' $(( mins % 60 ))) to full"
elif [[ "$status" == "Discharging" && "$power_uw" -gt 0 ]]; then
  mins=$(awk "BEGIN {printf \"%.0f\", $energy_now/$power_uw*60}")
  time_str="$(( mins / 60 )):$(printf '%02d' $(( mins % 60 ))) remaining"
fi

# Bar text
icons=("" "" "" "" "")
icon_idx=$(( capacity * 4 / 100 ))
(( icon_idx > 4 )) && icon_idx=4
icon="${icons[$icon_idx]}"
[[ "$status" == "Charging" ]] && icon=""

text="$icon  ${capacity}%"
[[ -n "$time_str" ]] && text="$text (${time_str%%to *}${time_str:+})" && text="$icon  ${capacity}% (${time_str})"

# CSS class
class=""
if [[ "$status" == "Charging" ]]; then
  class="charging"
elif (( capacity <= 15 )); then
  class="critical"
elif (( capacity <= 30 )); then
  class="warning"
fi

# Tooltip: USB-C port details
port_info=""
for port_dir in /sys/class/typec/port[0-9]; do
  port=$(basename "$port_dir")
  port_num=${port#port}

  # Determine what's connected
  if [[ -d "${port_dir}-partner" ]]; then
    partner_type=""
    # Check corresponding UCSI power supply
    psy="/sys/class/power_supply/ucsi-source-psy-USBC000:00$((port_num + 1))"
    if [[ -d "$psy" ]]; then
      psy_status=$(cat "$psy/status" 2>/dev/null || echo "")
      psy_online=$(cat "$psy/online" 2>/dev/null || echo "0")
      psy_voltage_max=$(cat "$psy/voltage_max" 2>/dev/null || echo "0")
      psy_v_max=$(awk "BEGIN {printf \"%.0f\", $psy_voltage_max/1000000}")
      usb_type=$(sed 's/.*\[\(.*\)\].*/\1/' "$psy/usb_type" 2>/dev/null || echo "")

      if [[ "$psy_online" == "1" ]]; then
        partner_type="⚡ Charger (${usb_type:-PD}, ${psy_v_max}V max)"
      elif [[ "$psy_status" == "Discharging" ]]; then
        partner_type="🔌 USB device"
      else
        partner_type="🔌 USB device"
      fi
    else
      partner_type="🔌 Connected"
    fi
    port_info="${port_info}USB-C ${port_num}: ${partner_type}\\n"
  fi
done

# Build tooltip
power_label="Draw"
[[ "$status" == "Charging" ]] && power_label="Charging"

tooltip="${status}"
[[ -n "$time_str" ]] && tooltip="${tooltip} — ${time_str}"
tooltip="${tooltip}\\n${power_label}: ${power_w}W @ ${voltage_v}V"
tooltip="${tooltip}\\nHealth: ${health}% · Cycles: ${cycles}"
[[ -n "$port_info" ]] && tooltip="${tooltip}\\n\\n${port_info%\\n}"

printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$text" "$class" "$tooltip"
