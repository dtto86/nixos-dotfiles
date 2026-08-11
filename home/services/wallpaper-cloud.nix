{ pkgs, ... }:

let
  fetchBingWallpaper = pkgs.writeShellApplication {
    name = "fetch-bing-wallpaper";
    runtimeInputs = with pkgs; [ curl jq coreutils ];
    text = ''
      cache_dir="$HOME/.cache/wallpapers/bing"
      mkdir -p "$cache_dir"

      meta="$(curl -fsSL "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US")"
      rel_url="$(echo "$meta" | jq -r '.images[0].url')"
      date_tag="$(echo "$meta" | jq -r '.images[0].startdate')"

      dest="$cache_dir/$date_tag.jpg"
      if [ ! -s "$dest" ]; then
        curl -fsSL "https://www.bing.com''${rel_url}" -o "$dest"
      fi

      noctalia msg wallpaper-set "$dest"

      # keep the last 14 days of cached wallpapers around, drop older ones
      find "$cache_dir" -maxdepth 1 -name '*.jpg' -mtime +14 -delete
    '';
  };
in
{
  home.packages = [ fetchBingWallpaper ];

  systemd.user.services.wallpaper-cloud = {
    Unit = {
      Description = "Fetch and apply Bing's daily wallpaper";
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${fetchBingWallpaper}/bin/fetch-bing-wallpaper";
    };
  };

  systemd.user.timers.wallpaper-cloud = {
    Unit.Description = "Daily Bing wallpaper refresh";

    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };

    Install.WantedBy = [ "timers.target" ];
  };
}
