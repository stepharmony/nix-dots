# Laptop power (spectre: Yoga Pro 7 14IMH9, Core Ultra 7 155H) — CPU and
# firmware power profiles, battery conservation mode, panel refresh rate.
# Commands: power-mode, battery-cap, refresh-rate (see TIPS.md).
{ flake, ... }:

{
  flake.modules.nixos.laptop =
    { pkgs, username, ... }:
    let
      # The only thing that runs as root: writes the two sysfs knobs, with
      # strictly validated arguments. Passwordless via sudo (rule below).
      laptopSysfs = pkgs.writeShellApplication {
        name = "laptop-sysfs";
        text = ''
          case "''${1:-}:''${2:-}" in
            profile:low-power | profile:balanced | profile:performance)
              echo "$2" >/sys/firmware/acpi/platform_profile
              ;;
            conservation:0 | conservation:1)
              for f in /sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode; do
                echo "$2" >"$f"
              done
              ;;
            *)
              echo "usage: laptop-sysfs profile low-power|balanced|performance | conservation 0|1" >&2
              exit 1
              ;;
          esac
        '';
      };
      sysfs = "/run/wrappers/bin/sudo -n ${laptopSysfs}/bin/laptop-sysfs";

      # power-mode [toggle|status] — flips the Lenovo platform profile between
      # performance and the default for the current power source (balanced on
      # AC, low-power on battery). auto-cpufreq resets it on plug/unplug.
      powerMode = pkgs.writeShellApplication {
        name = "power-mode";
        runtimeInputs = with pkgs; [
          procps
          libnotify
        ];
        text = ''
          profile=/sys/firmware/acpi/platform_profile
          [[ -r $profile ]] || exit 0
          current=$(<"$profile")
          case ''${1:-status} in
            status)
              case $current in
                performance) echo "󰓅 perf" ;;
                balanced) echo "󰾅 bal" ;;
                low-power) echo "󰾆 eco" ;;
                *) echo "$current" ;;
              esac
              ;;
            toggle)
              if [[ $current == performance ]]; then
                if grep -qs 1 /sys/class/power_supply/ADP*/online; then target=balanced; else target=low-power; fi
              else
                target=performance
              fi
              ${sysfs} profile "$target"
              pkill -RTMIN+9 -O 3 -x '\.?waybar(-wrapped)?' 2>/dev/null || true
              notify-send -t 1500 "Power mode" "$target" || true
              ;;
            *)
              echo "usage: power-mode [toggle|status]" >&2
              exit 1
              ;;
          esac
        '';
      };

      # battery-cap [on|off|status] — Lenovo conservation mode: the firmware
      # stops charging at ~80% (battery longevity when plugged in for long).
      batteryCap = pkgs.writeShellApplication {
        name = "battery-cap";
        text = ''
          files=(/sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode)
          if [[ ! -r ''${files[0]} ]]; then
            echo "battery-cap: no ideapad conservation_mode on this machine" >&2
            exit 1
          fi
          case ''${1:-status} in
            on) ${sysfs} conservation 1 ;;
            off) ${sysfs} conservation 0 ;;
            status) ;;
            *)
              echo "usage: battery-cap [on|off|status]" >&2
              exit 1
              ;;
          esac
          if [[ $(<"''${files[0]}") == 1 ]]; then
            echo "battery-cap: on (charging stops at ~80%)"
          else
            echo "battery-cap: off (charges to 100%)"
          fi
        '';
      };

      # refresh-rate [toggle|low|high|60|120|status|watch] — the internal
      # panel's (eDP) refresh rate under niri, using the modes niri reports at
      # the current resolution (low = slowest, high = fastest; 60/120 are
      # aliases). `watch` (spawned by config.kdl) sets high on AC and low on
      # battery, re-applying only when the AC state changes, so a manual
      # toggle sticks until the next plug/unplug. auto-cpufreq can't do this:
      # it only touches CPU/firmware/battery settings, not the display.
      refreshRate = pkgs.writeShellApplication {
        name = "refresh-rate";
        runtimeInputs = with pkgs; [
          gawk
          jq
          procps
          systemd
        ];
        text = ''
          outputs=$(niri msg --json outputs 2>/dev/null) || exit 0
          name=$(jq -r 'keys[] | select(startswith("eDP"))' <<<"$outputs" | head -n1)
          [[ -n $name ]] || exit 0

          # w h current low high (refresh rates in mHz, as niri reports them)
          read -r w h current low high < <(jq -r --arg n "$name" '
            .[$n] | .modes[.current_mode // 0] as $c
            | [.modes[] | select(.width == $c.width and .height == $c.height) | .refresh_rate] as $r
            | "\($c.width) \($c.height) \($c.refresh_rate) \($r | min) \($r | max)"' <<<"$outputs")

          set_rate() {
            niri msg output "$name" mode "''${w}x''${h}@$(awk -v r="$1" 'BEGIN { printf "%.3f", r / 1000 }')"
            # -O 3: a waybar that is still starting has no handler for this
            # signal yet, and its default action is to terminate — the
            # watcher's first apply at login used to kill the bar.
            pkill -RTMIN+8 -O 3 -x '\.?waybar(-wrapped)?' 2>/dev/null || true
          }
          on_ac() { grep -qs 1 /sys/class/power_supply/ADP*/online; }

          case ''${1:-status} in
            status) echo "󰍹 $(((current + 500) / 1000))Hz" ;;
            toggle) if [[ $current == "$high" ]]; then set_rate "$low"; else set_rate "$high"; fi ;;
            low | 60) set_rate "$low" ;;
            high | 120) set_rate "$high" ;;
            watch)
              last=
              apply() {
                local ac=0
                if on_ac; then ac=1; fi
                [[ $ac == "$last" ]] && return 0
                last=$ac
                if [[ $ac == 1 ]]; then set_rate "$high"; else set_rate "$low"; fi
              }
              apply || true
              # Wake on power_supply events, and at least once a minute to
              # notice that this session's niri has exited (then stop, taking
              # udevadm along) — otherwise a logout leaves the watcher behind.
              exec {events}< <(exec udevadm monitor --udev --subsystem-match=power_supply)
              monitor=$!
              trap 'kill "$monitor" 2>/dev/null' EXIT
              while niri msg version >/dev/null 2>&1; do
                if read -r -t 60 -u "$events" _; then apply || true; fi
              done
              ;;
            *)
              echo "usage: refresh-rate [toggle|low|high|60|120|status|watch]" >&2
              exit 1
              ;;
          esac
        '';
      };
    in
    {
      # auto-cpufreq instead of power-profiles-daemon (they conflict).
      services.power-profiles-daemon.enable = false;

      # powersave is intel_pstate's dynamic governor (it still boosts on
      # demand); the `performance` governor pinned clocks high on AC, which
      # ate the charger's headroom under load and made every EPP write fail
      # with EBUSY (~4000 errors per AC session). platform_profile is the
      # Lenovo firmware's power-limit/fan profile; enforce = false sets it
      # only on plug/unplug, so `power-mode toggle` sticks until then.
      services.auto-cpufreq = {
        enable = true;
        settings = {
          charger = {
            governor = "powersave";
            energy_performance_preference = "balance_performance";
            energy_perf_bias = "balance_performance";
            platform_profile = "balanced";
            enforce_platform_profile = false;
            turbo = "auto";
          };
          battery = {
            governor = "powersave";
            energy_performance_preference = "balance_power";
            energy_perf_bias = "balance_power";
            platform_profile = "low-power";
            enforce_platform_profile = false;
            turbo = "auto";
          };
        };
      };

      # Intel's thermal daemon — recommended for Meteor Lake; works next to
      # auto-cpufreq (it manages thermals, not frequency policy).
      services.thermald.enable = true;

      security.sudo.extraRules = [
        {
          users = [ username ];
          commands = [
            {
              command = "${laptopSysfs}/bin/laptop-sysfs";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      environment.systemPackages = [
        powerMode
        batteryCap
        refreshRate
      ];
    };
}
