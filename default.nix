# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  hybooru = pkgs.callPackage ./pkgs/hybooru { };
  shlink = pkgs.callPackage ./pkgs/shlink { };
  caddy = pkgs.callPackage ./pkgs/caddy { };
  vivid = pkgs.callPackage ./pkgs/vivid { };
  incremental-compress = pkgs.callPackage ./pkgs/incremental-compress { };

  z-en = pkgs.writeShellScriptBin "en" ''
    ALTERNATE_EDITOR=emacs exec emacsclient -c "$@"
  '';
  z-eb = pkgs.writeShellScriptBin "eb" ''
    ALTERNATE_EDITOR=emacs exec emacsclient -c "$@" &
  '';
  z-en-nvim = pkgs.writeShellScriptBin "en" ''
    nvim "$@"
  '';
  zstdir = pkgs.writeShellScriptBin "zstdir" ''
    export TZ=UTC
    tar --force-local --create --verbose --use-compress-program='zstd -v -T4 -3'  --file "$1-$(date -Iseconds).tar.zst" ''${*:2}
  '';
  unencz = pkgs.writeShellApplication {
    name = "unencz";
    runtimeInputs = [ pkgs.age ];
    text = ''
      echo "$2" | age --decrypt -i - "$1" | tar -xvf - --zstd
    '';
  };
  gethash = pkgs.writeShellScriptBin "gethash" ''
    nix hash to-sri --type sha256 $(nix-prefetch-url $1)
  '';
  gethashz = pkgs.writeShellScriptBin "gethashz" ''
    nix hash to-sri --type sha256 $(nix-prefetch-url --unpack $1)
  '';

  nvidia-offload = pkgs.writeShellScriptBin "prime-run" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
    exec -a "$0" "$@"
  '';
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
