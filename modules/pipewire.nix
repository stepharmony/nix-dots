{ pkgs, ... }:
{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # WirePlumber loses the audio graph across suspend/resume (no sinks in the
  # graph while ALSA devices stay healthy) — restart it at suspend time so
  # wake sees a fresh graph. Runtime-scoped to Niri: the unit exists in every
  # session, but XDG_CURRENT_DESKTOP (imported into the user manager by both
  # DEs) is re-evaluated at each start — Plasma suspends (=KDE) skip it.
  systemd.user.services.restart-wireplumber-on-suspend = {
    description = "Restart WirePlumber before suspend (Niri sessions only)";
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    unitConfig.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };
}
