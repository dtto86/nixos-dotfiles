{ pkgs, ... }:

let
  # Fires on every power_supply uevent (battery % tick, plug/unplug). Below
  # 20% we force power-saver; above it we only step back to balanced if we're
  # the ones who set power-saver, so a profile the user picked by hand
  # (e.g. performance) isn't clobbered once the battery recovers.
  # Notify-send is fired once per low-battery episode (flag file under
  # /run, cleared once we're back above the threshold or plugged in) so it
  # doesn't re-fire on every uevent while sitting below 20%.
  batteryPowerSaverScript = pkgs.writeShellScript "battery-power-saver" ''
    set -euo pipefail

    capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    threshold=20
    notifiedFlag=/run/battery-low-notified

    if [ "$capacity" -le "$threshold" ]; then
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver

      if [ "$status" = "Discharging" ] && [ ! -e "$notifiedFlag" ]; then
        touch "$notifiedFlag"
        ${pkgs.systemd}/bin/runuser -u pravin -- \
          ${pkgs.systemd}/bin/systemd-run --user \
          ${pkgs.libnotify}/bin/notify-send -u critical -t 0 \
          "Low battery" "Battery at $capacity% - plug in the charger."
      fi
    else
      rm -f "$notifiedFlag"
      current=$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)
      if [ "$current" = "power-saver" ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    fi
  '';
in
{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ACTION=="change", RUN+="${batteryPowerSaverScript}"
    '';
  };
}

