# hybooru.nix
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_20,
  python3,
  pkg-config,
  makeWrapper,
}:

buildNpmPackage {
  pname = "hybooru";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "funmaker";
    repo = "Hybooru";
    rev = "master"; # Or pin to a specific commit hash
    hash = "sha256-/EKYMaNocmpqQxoJYjT9nGMGBgb2byK97T5lbMI5XVI=";
  };

  # Calculate with: nix-prefetch-npm-deps package-lock.json
  # Or use: nix hash to-sri --type sha256 $(nix-prefetch-url --unpack <url>)

  nodejs = nodejs_20;

  npmDepsHash = "sha256-0i2PlZ9kHs6BikdMahssT05zOGgtWfnChhzZx3PoK1k=";
  # npmDepsHash = lib.fakeHash;

  npmBuildScript = "build:prod";

  nativeBuildInputs = [
    python3
    pkg-config
    makeWrapper
  ];

  makeCacheWritable = true;

  # Key fix: Include node_modules in the output
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/hybooru

    # Copy the built dist folder
    cp -r dist/* $out/lib/hybooru/

    # Copy production node_modules (required because webpack uses nodeExternals)
    cp -r node_modules $out/lib/hybooru/

    # Create wrapper script
    mkdir -p $out/bin
    makeWrapper ${nodejs_20}/bin/node $out/bin/hybooru \
      --add-flags "$out/lib/hybooru/server.js" \
      --set NODE_ENV production \
      --set SQLITE_USE_URI 1 \
      --chdir "$out/lib/hybooru"

    runHook postInstall
  '';
  postBuild = ''
    # Rebuild native modules after the main build
    npm rebuild better-sqlite3
  '';
  patches = [
    ./0001-read-config-file-location-from-environment-variable.patch
    ./0002-use-ATTACH-read-only.patch
    ./0003-update-better-sqlit3.patch
  ];

  # Don't run default install, we handle it manually
  dontNpmInstall = true;

  meta = {
    description = "Hydrus-based booru-styled imageboard in React";
    homepage = "https://github.com/funmaker/Hybooru";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "hybooru";
  };
}
