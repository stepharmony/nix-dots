# System fonts (both hosts). The CJK and emoji Noto fonts already came with
# the NixOS defaults; noto-fonts adds the other scripts, Symbols and Math.
# Listing them here keeps the set explicit. fontconfig falls through each
# list below, then to any installed font that has the glyph.
#
# Fonts disabled in Font Manager land in ~/.config/fontconfig/conf.d/
# 78-Reject.conf and override all of this for the user: rejecting Noto CJK
# and Noto Color Emoji there is what turned CJK and emoji into boxes.
{ flake, ... }:

{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        noto-fonts # Latin + most other scripts, Symbols, Math
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];

      # CJK "SC" first: Han characters without a language tag use
      # Simplified Chinese glyph shapes (pages that set lang= still get
      # their own variant). Color emoji after the text fonts, else emoji
      # fall back to monochrome DejaVu.
      fonts.fontconfig.defaultFonts = {
        monospace = [
          "Obel Mono"
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK SC"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Color Emoji"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
}
