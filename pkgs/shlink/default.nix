# from https://github.com/uku3lig/camasca/
{
  fetchFromGitHub,
  makeWrapper,
  php84,
}:
php84.buildComposerProject2 (finalAttrs: {
  pname = "shlink";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "shlinkio";
    repo = "shlink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GOexTdz1RDdnRgcFYXn5JVwTZWQdycMlm1CLC88sirU=/sa63bJVuQ3+cGBAY=";
  };

  patches = [ ./datadir.patch ];

  nativeBuildInputs = [ makeWrapper ];

  php = php84.withExtensions (
    { enabled, all }:
    enabled
    ++ (with all; [
      # json
      curl
      pdo
      intl
      gd
      gmp
      sockets
      bcmath
    ])
  );

  composerLock = ./composer.lock;
  composerStrictValidation = false;
  vendorHash = "sha256-A8PoNtONmZuQCdWU3hS46s1Pm6l+ZJKszLvvyAmZKxg=";

  postPatch = ''
    sed -i "s/%SHLINK_VERSION%/${finalAttrs.version}/g" module/Core/src/Config/Options/AppOptions.php
  '';

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/share/php/shlink/bin/cli $out/bin/shlink
  '';
})
