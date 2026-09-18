{ pkgs, ... }:

let
  # brightnessctl's own -s/-r is fragile: -s snapshots whatever the backlight
  # is at *that instant* as the restore target, so a second on-timeout with no
  # on-resume between (resume-event flapping, a resume missed during lock/DPMS)
  # or any other process nudging the backlight corrupts the saved value to 10%.
  # Once that happens every resume "restores" to 10% and every idle re-saves it.
  # These guard against it: only record a pre-dim value when clearly not already
  # dim, and drop the state file after restoring so a stale value can't linger.
  dimBrightness = pkgs.writeShellApplication {
    name = "hypridle-dim-brightness";
    runtimeInputs = [ pkgs.brightnessctl ];
    text = ''
      state="$XDG_RUNTIME_DIR/hypridle-brightness.pre"

      IFS=, read -r _ _ cur _ max < <(brightnessctl -m)
      # 15% of max — above this we treat the panel as "at the user's level"
      threshold=$(( max * 15 / 100 ))

      if [ "$cur" -gt "$threshold" ]; then
        printf '%s' "$cur" > "$state"
      fi

      brightnessctl set 10%
    '';
  };

  restoreBrightness = pkgs.writeShellApplication {
    name = "hypridle-restore-brightness";
    runtimeInputs = [ pkgs.brightnessctl ];
    text = ''
      state="$XDG_RUNTIME_DIR/hypridle-brightness.pre"

      if [ -r "$state" ]; then
        brightnessctl set "$(cat "$state")"
        rm -f "$state"
      fi
    '';
  };

  # The power-saver listener had no on-resume, so any 5-minute idle left the
  # machine stuck in power-saver until noticed. Capture the active profile on
  # the way in and put it back on resume.
  enterPowerSave = pkgs.writeShellApplication {
    name = "hypridle-enter-powersave";
    runtimeInputs = [ pkgs.power-profiles-daemon pkgs.systemd ];
    text = ''
      state="$XDG_RUNTIME_DIR/hypridle-powerprofile.pre"

      powerprofilesctl get > "$state"
      powerprofilesctl set power-saver
      loginctl lock-session
    '';
  };

  exitPowerSave = pkgs.writeShellApplication {
    name = "hypridle-exit-powersave";
    runtimeInputs = [ pkgs.power-profiles-daemon ];
    text = ''
      state="$XDG_RUNTIME_DIR/hypridle-powerprofile.pre"

      if [ -r "$state" ]; then
        powerprofilesctl set "$(cat "$state")" || true
        rm -f "$state"
      fi
    '';
  };
in
{
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({action = \"on\"})'";
      };

      listener = [
        {
          timeout = 150;
          on-timeout = "${dimBrightness}/bin/hypridle-dim-brightness";
          on-resume = "${restoreBrightness}/bin/hypridle-restore-brightness";
        }

        {
          timeout = 300;
          on-timeout = "${enterPowerSave}/bin/hypridle-enter-powersave";
          on-resume = "${exitPowerSave}/bin/hypridle-exit-powersave";
        }

        {
          timeout = 330;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({action = \"off\"})'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({action = \"on\"})'";
        }

        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
