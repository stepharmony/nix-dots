# Study tools (both hosts): notes, typesetting, lectures. Programming
# tools live in dev.nix, VHDL/waveform tools in hdl.nix.
{ flake, ... }:

{
  flake.modules.nixos.study =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        obsidian # 1.13.4 (unfree — covered by the global allowUnfree)
        typst # 0.15.1 — typesetting without texlive
        tinymist # 0.15.2 — typst LSP; helix ships built-in typst support
        # and auto-starts tinymist from PATH (hx --health typst)
        typstyle # 0.15.1 — typst formatter, for :format once wired in helix
        tectonic # 0.17.0 — full TeX engine, no texlive; fetches support
        # files from the network on first compile
        zoom-us
      ];
    };
}
