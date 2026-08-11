{ _, ... }:

{
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    pulse.enable = true;

    # ALC257 headphone output supports up to 24-bit/192kHz, but PipeWire's
    # own default clock only allows 48kHz. Widen the allowed rates so
    # higher-quality sources aren't downsampled.
    extraConfig.pipewire."92-hd-audio" = {
      "context.properties" = {
        "default.clock.rate" = 96000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 ];
      };
    };
  };
}

