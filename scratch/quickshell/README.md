# quickshell playground

A standalone quickshell workspace for experiments — **not** wired into hjem
or any spawn line. The production island lives in
`dotfiles/quickshell/island/`; nothing here is deployed or built by the
flake.

## Workflow

```bash
qs -p ~/my-nixos-config/scratch/quickshell
```

- `-p` takes a raw path — the repo dir *is* the config dir, no symlinks.
- quickshell watches the files: **save any `.qml` → instant reload**, no
  restart, no `nh os switch`.
- Runs fine side-by-side with the island (arbitration is per config path).
- Entry point: `shell.qml` with a `ShellRoot` root.

## Lessons learned (from building the island — read before starting)

### qmldir
- The moment a `qmldir` exists in the directory, the engine **stops
  auto-registering sibling `.qml` files as types**. Every type must be
  listed explicitly or you get `X is not a type` at runtime. (qmllint
  resolves directory imports laxer than the engine and will not catch this.)
- Singletons: `pragma Singleton` + `Singleton` (from `Quickshell`) as root +
  a `singleton Name 1.0 File.qml` line in qmldir.

### PanelWindow / layer shell
- Anchoring **top only** makes the compositor center the window
  horizontally — that is how the island floats.
- `exclusiveZone: N` (with `exclusionMode: ExclusionMode.Normal`) reserves
  screen edge; `ExclusionMode.Ignore` overlays without shoving windows.
- A transparent window grabs input over its **whole** area unless you set
  `mask: Region { item: theVisibleBox; }` — otherwise invisible regions eat
  clicks.
- Animate sizes on an inner Rectangle, keep the window fixed — animated
  layer-surface resizing is a glitch factory. One animation source only
  (a child animating height while the parent animates a binding on it =
  two interpolations fighting).

### Services (all present in this quickshell build)
- MPRIS: `Mpris.players?.values` (it is an ObjectModel — not `.length` on
  the model itself). `togglePlaying()`, `next()`, `previous()`,
  `trackTitle`, `trackArtist`, `playbackState === MprisPlaybackState.Playing`.
- Notifications: `NotificationServer` with `bodySupported` etc.; the engine
  auto-acknowledges after `expireTimeout` — snapshot in `onNotification` for
  your own toasts/history. Only one daemon can own
  `org.freedesktop.Notifications` (kill swaync or you just get a WARN).
- PipeWire: `Pipewire.defaultAudioSink` returns an **unbound** node unless
  tracked: `PwObjectTracker { objects: sink ? [sink] : []; }` — without it
  every volume/mute write errors with `PwNode ... not bound`.
- There is **no Brightness module** in this build — use `brightnessctl`
  through `Quickshell.Io.Process`.
- Tray: `SystemTray.items`, render `item.icon` with `IconImage`
  (`Quickshell.Widgets`), `item.activate()` on click.
- One-shot queries: `Process { stdout: StdioCollector { onStreamFinished: …
  JSON.parse(this.text) … } }`.

### Compositor adapters
- The built-in `WindowManager` module is too young to trust across niri and
  - niri: `niri msg -j workspaces`, `niri msg -j focused-window`,
    focus via `niri msg action focus-workspace <idx>`
  - Both behind one interface (see `Wm.qml` in the island).

### Static checking (catches most breakage before the first run)

```bash
QS=$(nix build --print-out-paths .#nixosConfigurations.manus.pkgs.quickshell)
QT=$(nix build --print-out-paths .#nixosConfigurations.manus.pkgs.qt6.qtdeclarative)
nix shell nixpkgs#qt6.qtdeclarative -c \
  qmllint -I "$QS/lib/qt-6/qml" -I "$QT/lib/qt-6/qml" ./*.qml
```

Known false positives to ignore: `Type PanelWindow is not creatable`,
`unknown grouped property scope margins`, `unqualified` warnings on
singleton/file ids inside `Singleton` roots, and `JsonAdapter … incomplete
type FileViewAdapter`.

### Promotion path
Graduating an experiment into the island: copy file(s) into
`dotfiles/quickshell/island/`, add every type to its `qmldir`, add hjem
entries in `modules/users.nix`, `nh os switch` — the only step that ever
needs a rebuild.

## Reference
- Working example: `dotfiles/quickshell/island/`
- Docs: <https://quickshell.org> (outfoxxed)
