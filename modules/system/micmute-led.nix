{ config, pkgs, lib, ... }:

let
  # The mic-mute LED is bound by ALSA UCM (see alsa-ucm-conf's
  # ucm2/common/ctl/led.conf, which registers it against snd_ctl_led via
  # /sys/class/sound/ctl-led/mic/card1) to the codec's generic "Capture"
  # switch. On this hardware the actual microphone (AMD ACP63 DSP "Digital
  # Microphone") is muted entirely in software by PipeWire and never
  # touches that switch (confirmed via `pw-dump`: route.hw-mute is false
  # for that route), so the LED never follows real mute state on its own.
  #
  # "Capture" belongs to the codec's other, inactive input (the analog
  # Stereo Microphone) rather than the DSP path actually in use, so
  # toggling it has no effect on the real captured audio - it only
  # matters here because it's already wired to the LED. Real muting stays
  # exactly as-is (PipeWire's software mute); this just mirrors that
  # state onto the switch the LED already watches.
  micmute-led = pkgs.writeShellScriptBin "micmute-led" ''
    #!${pkgs.bash}/bin/bash

    WPCTL=${pkgs.wireplumber}/bin/wpctl
    AMIXER=${pkgs.alsa-utils}/bin/amixer
    GREP=${pkgs.gnugrep}/bin/grep

    update() {
      if "$WPCTL" get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | "$GREP" -q '\[MUTED\]'; then
        "$AMIXER" -c 1 set Capture nocap >/dev/null
      else
        "$AMIXER" -c 1 set Capture cap >/dev/null
      fi
    }

    # At login, WirePlumber hasn't necessarily finished electing a default
    # source node yet, so `wpctl subscribe`/`get-volume` can fail (and the
    # subscribe pipe closes immediately) even though pipewire.service and
    # wireplumber.service have already started - unit ordering guarantees
    # start, not readiness. Retry in a loop instead of letting the process
    # exit, since repeated systemd restarts burn through the default
    # StartLimitBurst and leave the LED permanently out of sync.
    while true; do
      update

      "$WPCTL" subscribe 2>/dev/null | while read -r line; do
        case "$line" in
          *source*|*Source*)
            update
            ;;
        esac
      done

      sleep 1
    done
  '';
in
{
  environment.systemPackages = [ micmute-led ];

  systemd.user.services.micmute-led = {
    description = "ThinkPad microphone LED sync";

    wantedBy = [ "graphical-session.target" ];

    after = [
      "pipewire.service"
      "wireplumber.service"
    ];

    serviceConfig = {
      ExecStart = "${micmute-led}/bin/micmute-led";
      Restart = "always";
      RestartSec = 1;
    };
  };
}

