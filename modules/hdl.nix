# Hardware description tools (both hosts). VHDL stack, recognized by helix
# out of the box (hx --health vhdl): vhdl_ls LSP + built-in treesitter
# grammar. Simulate with ghdl, inspect the waveforms in gtkwave.
{ flake, ... }:

{
  flake.modules.nixos.hdl =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        ghdl # 6.0.0 — VHDL 2008/93/87 simulator; writes .ghw/.vcd waveforms
        gtkwave # 3.3.128 — waveform viewer for ghdl's output
        vhdl-ls # 0.88.0 — vhdl_ls, the LSP helix auto-starts from PATH
      ];
    };
}
