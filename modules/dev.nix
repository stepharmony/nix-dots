# Development tools (both hosts). C99/C11/C23 stack, recognized by helix
# out of the box (hx --health c): clangd LSP + lldb-dap debug adapter +
# built-in treesitter grammar.
{ flake, ... }:

{
  flake.modules.nixos.dev =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        helix # 25.07.1
        clang-tools # 21.1.8 — clangd (LSP), the recognizer
        lldb # lldb-dap — helix's default C debug adapter
        gdb # alternative debugger, CLI workflow
        gcc # 15.3.0 — full C23 (-std=c23); C99/C11 of course
        gnumake # 4.4.1
        vscode # 1.142.0 — Microsoft's build (unfree, covered by the global
        # allowUnfree): the Marketplace and Microsoft-only extensions work
        uv # Python projects: uv installs its own Pythons (see nix-ld below)
        opencode
        claude-code
      ];

      # uv's managed Pythons (python-build-standalone, what VS Code's Python
      # extension installs through uv) are generic Linux builds; nix-ld runs
      # them. Unlike a venv from nixpkgs' python3 they include tkinter.
      # Also enabled by music.nix for installers; the settings merge.
      programs.nix-ld.enable = true;

      # ~/.local/bin on PATH: where `uv tool install` puts its commands.
      environment.localBinInPath = true;
    };
}
