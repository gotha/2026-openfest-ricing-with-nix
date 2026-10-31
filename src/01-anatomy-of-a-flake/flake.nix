{
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
    };
  };

  # From this directory: nix run . -- "Hello, OpenFest!"
  #outputs = { nixpkgs, ... }: {
  #  packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.cowsay;
  #  packages.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.cowsay;
  #  packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.cowsay;
  #  packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.cowsay;
  #};

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system: {
        default = nixpkgs.legacyPackages.${system}.cowsay;
      });
    };
  # https://nix.dev/manual/nix/2.35/command-ref/new-cli/nix3-run.html#flake-output-attributes
}
