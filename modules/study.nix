# Study tools (both hosts): notes, typesetting, lectures. Programming
# tools live in dev.nix, VHDL/waveform tools in hdl.nix.
{ flake, ... }:

{
  flake.modules.nixos.study =
    { pkgs, lib, ... }:
    let
      # TUvpn needs --no-external-auth for its 2FA flow, which NetworkManager
      # can't pass — hence a CLI wrapper (per TU Wien's OpenConnect KB page).
      # Prompts for password, then the 6-digit MFA code. The username is read
      # from ~/.config/tuvpn/user if present (kept out of this public repo),
      # otherwise openconnect asks for it. Extra args pass through (e.g. -b).
      # Profile: TUVPN_PROFILE=2_Alles_getunnelt tuvpn to tunnel everything.
      tuvpn = pkgs.writeShellApplication {
        name = "tuvpn";
        text = ''
          user_file="''${XDG_CONFIG_HOME:-$HOME/.config}/tuvpn/user"
          args=(
            --useragent="AnyConnect OpenConnect"
            --no-external-auth
            --authgroup="''${TUVPN_PROFILE:-1_TU_getunnelt}"
          )
          if [[ -r $user_file ]]; then
            args+=(--user "$(<"$user_file")")
          fi
          exec sudo ${lib.getExe pkgs.openconnect} "''${args[@]}" "$@" vpn.tuwien.ac.at
        '';
      };
    in
    {
      environment.systemPackages = with pkgs; [
        # 1.14.5 (unfree — covered by the global allowUnfree). Pinned to
        # electron_42: electron 43.8.3 (nixpkgs 2026-10-23) crashes in its own
        # renderer_init (web-frame.ts, "reading 'defineProperty'") and leaves a
        # blank window — Wayland and X11 alike; 43.7.11 and 42.11.18 both work.
        # Drop the override once nixpkgs ships a fixed electron 43 (TIPS.md).
        (obsidian.override { electron = electron_42; })
        typst # 0.15.1 — typesetting without texlive
        tinymist # 0.15.2 — typst LSP; helix ships built-in typst support
        # and auto-starts tinymist from PATH (hx --health typst)
        typstyle # 0.15.1 — typst formatter, for :format once wired in helix
        tectonic # 0.17.0 — full TeX engine, no texlive; fetches support
        # files from the network on first compile
        zoom-us
        anki-bin # 26.09.3 — official upstream build, ahead of the source-built `anki`
        tuvpn # TUvpn via openconnect, see above
      ];
    };
}
