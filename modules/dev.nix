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
        opencode
        claude-code
      ];
    };
}
