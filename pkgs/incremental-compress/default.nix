{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "incremental-compress";
  version = "30c9c0de71d5f988fe0b5fd70834c1be1088ee95";

  src = fetchFromGitHub {
    owner = "scottlaird";
    repo = pname;
    rev = version;
    sha256 = "sha256-Qbp8ldpD81S66MBPk0Y1jM45GVnGVWoTsvS1eV+PXk0=";
  };

  vendorHash = "sha256-yh6dXS0TCcafqFe9PUokyWqg6lWEMIy6ddI4YgUtxDE=";

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${version}"
  ];

  meta = with lib; {
    description = " Incremental compression tool for generating pre-compressed web pages for static page generators like Hugo";
    homepage = "https://github.com/scottlaird/incremental-compress";
    license = licenses.apsl20;
    mainProgram = "incremental-compress";
  };
}
