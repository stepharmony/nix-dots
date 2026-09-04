# Wayland session stack (Niri) — libnotify clients (notify-send). The
# island's NotificationServer renders the toasts.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libnotify
  ];
}
