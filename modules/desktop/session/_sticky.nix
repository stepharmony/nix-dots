# Wayland session stack (Niri) — sticky windows, which niri has no option
# for: `niri-sticky toggle` (Mod+P, or a click on waybar's pin) marks the
# focused window, and `niri-sticky watch` (spawned by config.kdl) moves the
# marked windows along whenever you switch workspace. A marked window is
# floated, as a tiled one would join each workspace as a new column. niri
# can't colour one window's border from a script (rules only match fixed
# properties; the urgent flag clears on focus), so waybar's custom/sticky
# shows 󰐃 while the focused window is sticky.
{ pkgs, ... }:

let
  niriSticky = pkgs.writeShellApplication {
    name = "niri-sticky";
    runtimeInputs = with pkgs; [
      jq
      procps
      libnotify
    ];
    text = ''
      # Window ids, one per line; gone with the session.
      state=''${XDG_RUNTIME_DIR:-/tmp}/niri-sticky
      touch "$state"

      bar() { pkill -RTMIN+10 -O 3 -x '\.?waybar(-wrapped)?' 2>/dev/null || true; }
      sticky() { grep -qx "$1" "$state"; }
      drop() { grep -vx "$1" "$state" >"$state.new" || true; mv "$state.new" "$state"; }

      case ''${1:-status} in
        status)
          id=$(niri msg --json focused-window 2>/dev/null | jq -r '.id // empty') || exit 0
          if [[ -n $id ]] && sticky "$id"; then echo "󰐃"; fi
          ;;
        toggle)
          window=$(niri msg --json focused-window | jq -c '.') || exit 0
          id=$(jq -r '.id // empty' <<<"$window")
          [[ -n $id ]] || exit 0
          if sticky "$id"; then
            drop "$id"
            notify-send -t 1500 "Sticky window" "off" || true
          else
            echo "$id" >>"$state"
            [[ $(jq -r '.is_floating' <<<"$window") == true ]] || niri msg action move-window-to-floating --id "$id"
            notify-send -t 1500 "Sticky window" "follows you across workspaces" || true
          fi
          bar
          ;;
        watch)
          # Ids from an earlier session mean other windows now.
          : >"$state"
          niri msg --json event-stream | while read -r event; do
            case $event in
              '{"WorkspaceActivated"'*)
                read -r ws focused < <(jq -r '.WorkspaceActivated | "\(.id) \(.focused)"' <<<"$event")
                # Another monitor's workspace changed; you're not there.
                [[ $focused == true && -s $state ]] || continue
                windows=$(niri msg --json windows)
                idx=$(niri msg --json workspaces | jq -r --argjson ws "$ws" '.[] | select(.id == $ws) | .idx')
                while read -r id; do
                  on=$(jq -r --argjson id "$id" '.[] | select(.id == $id) | .workspace_id' <<<"$windows")
                  if [[ -z $on ]]; then
                    drop "$id"
                  elif [[ $on != "$ws" ]]; then
                    niri msg action move-window-to-workspace --window-id "$id" --focus false "$idx"
                  fi
                done <"$state"
                ;;
              '{"WindowClosed"'*)
                drop "$(jq -r '.WindowClosed.id' <<<"$event")"
                bar
                ;;
              '{"WindowFocusChanged"'*) bar ;;
            esac
          done
          ;;
        *)
          echo "usage: niri-sticky [toggle|status|watch]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [ niriSticky ];
}
