{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "vivid";
  version = "2772c9dab8c0f214d3e09b08fe6291ec89086359";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    rev = version;
    hash = "sha256-963rJz0ZsWnKQx8tO1Y65RHAW/oZnF4A5XKneP0PyBM=";
  };

  cargoHash = "sha256-oP5/G/PSkwn4JruLQOGtM8M2uPt4Q88bU3kNmXUK4JE=";

  meta = with lib; {
    description = "Generator for LS_COLORS with support for multiple color themes";
    homepage = "https://github.com/sharkdp/vivid";
    license = with licenses; [
      asl20 # or
      mit
    ];
    # maintainers = [ maintainers.dtzWill ];
    platforms = platforms.unix;
    mainProgram = "vivid";
  };
}
