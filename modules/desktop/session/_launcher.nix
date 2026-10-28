# Tiling-session launcher — rofi 2.x (native Wayland in niri, X11 in qtile):
# apps, clipboard picker, the wallpaper picker and the power menu. Config
# deployed by hjem to ~/.config/rofi/config.rasi.
{ pkgs, ... }:

let
  # power-menu — lock / log out / suspend / hibernate / reboot / shut down,
  # from the qtile bar's power button and Mod+Shift+E there; works in niri too.
  # Hibernate is only offered where logind allows it (not on manus).
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = with pkgs; [
      rofi
      systemd
    ];
    text = ''
      options=("󰌾  Lock" "󰍃  Log out" "󰒲  Suspend")
      if [[ $(busctl call org.freedesktop.login1 /org/freedesktop/login1 \
        org.freedesktop.login1.Manager CanHibernate 2>/dev/null) == 's "yes"' ]]; then
        options+=("󰋊  Hibernate")
      fi
      options+=("󰜉  Reboot" "󰐥  Shut down")

      choice=$(printf '%s\n' "''${options[@]}" | rofi -dmenu -i -p power -no-custom) || exit 0
      case ''${choice#*  } in
        Lock) loginctl lock-session ;;
        "Log out")
          if [[ -n ''${NIRI_SOCKET:-} ]]; then
            niri msg action quit --skip-confirmation
          elif [[ ''${XDG_CURRENT_DESKTOP:-} == qtile ]]; then
            qtile cmd-obj -o cmd -f shutdown
          else
            loginctl terminate-session "''${XDG_SESSION_ID:-}"
          fi
          ;;
        Suspend) systemctl suspend ;;
        Hibernate) systemctl hibernate ;;
        Reboot) systemctl reboot ;;
        "Shut down") systemctl poweroff ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [
    pkgs.rofi
    powerMenu
  ];
}
