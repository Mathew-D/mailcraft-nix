{
  description = "MailCraft - mail, calendar and contacts in pure Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.callPackage ./package.nix {
        inherit (pkgs)
          alsa-lib
          dbus
          libGL
          vulkan-loader
          wayland
          libx11
          libxcb
          libxcursor
          libxi
          libxrandr
          libxkbcommon
          libva;
      };
    };
}
