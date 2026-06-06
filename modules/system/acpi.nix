{ pkgs, ... }:

{
  services.acpid = {
    enable = true;

    handlers.micmute = {
      event = "button/micmute.*";

      action = ''
        ${pkgs.wireplumber}/bin/wpctl \
          set-mute @DEFAULT_AUDIO_SOURCE@ toggle

        STATE=$(
          ${pkgs.wireplumber}/bin/wpctl \
            get-volume @DEFAULT_AUDIO_SOURCE@ \
            | grep -o MUTED
        )

        if [ "$STATE" = "MUTED" ]; then
          echo 0 > /sys/class/leds/platform::micmute/brightness
        else
          echo 1 > /sys/class/leds/platform::micmute/brightness
        fi
      '';
    };
  };
}

