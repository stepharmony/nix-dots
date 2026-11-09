# helium-update — moves pkgs/helium/source.json to the newest Helium
# release, but only after its tarball verifies against the vendored
# pubkey.asc. The verified tarball is added to the store, so the next
# `nh os switch` doesn't download it again. Nothing else in the flake moves.
{
  writeShellApplication,
  curl,
  gnupg,
  jq,
}:
writeShellApplication {
  name = "helium-update";
  runtimeInputs = [
    curl
    gnupg
    jq
  ];
  text = ''
    repo=''${NH_OS_FLAKE:-$HOME/nix-dots}
    dir=$repo/pkgs/helium
    current=$(jq -r .version "$dir/source.json")

    latest=$(curl -fsS --max-time 10 -o /dev/null -w '%{redirect_url}' \
      https://github.com/imputnet/helium-linux/releases/latest)
    latest=''${latest##*/}
    if [[ -z $latest ]]; then
      echo "helium-update: could not determine the latest release" >&2
      exit 1
    fi
    if [[ $latest == "$current" ]]; then
      echo "Helium $current is up to date."
      exit 0
    fi

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    name=helium-$latest-x86_64_linux.tar.xz
    url=https://github.com/imputnet/helium-linux/releases/download/$latest/$name
    echo "Downloading Helium $latest..."
    curl -fL --progress-bar -o "$tmp/$name" "$url"
    curl -fsSL -o "$tmp/$name.asc" "$url.asc"

    export GNUPGHOME=$tmp/gnupg
    mkdir -m 700 "$GNUPGHOME"
    gpg --batch --quiet --dearmor -o "$tmp/helium.gpg" <"$dir/pubkey.asc"
    if ! gpgv --keyring "$tmp/helium.gpg" "$tmp/$name.asc" "$tmp/$name"; then
      echo "helium-update: BAD SIGNATURE for $name; source.json unchanged" >&2
      exit 1
    fi

    nix-store --add-fixed sha256 "$tmp/$name" >/dev/null
    jq -n --arg v "$latest" \
      --arg h "$(nix hash file --sri "$tmp/$name")" \
      --arg s "$(nix hash file --sri "$tmp/$name.asc")" \
      '{version: $v, hash: $h, signatureHash: $s}' >"$dir/source.json"

    echo "Helium $current -> $latest (signature OK). Next: nh os switch"
  '';
}
