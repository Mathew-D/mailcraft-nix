# MailCraft Nix Flake

Nix flake for [MailCraft](https://github.com/UCS-Care-Group/mailcraft), an open-source mail, calendar and contacts program in pure Rust (Microsoft 365, Outlook.com and IMAP). It repackages the upstream x86_64 Linux AppImage.

## Usage

```bash
nix run github:Mathew-D/mailcraft-nix
nix build            # result/bin/mailcraft
```

### NixOS

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mailcraft.url = "github:Mathew-D/mailcraft-nix";
  };
  # ...
  environment.systemPackages = [ mailcraft.packages.x86_64-linux.default ];
}
```

## Updating

```bash
./update.sh
```

Fetches the latest upstream release, updates the version and hash in `package.nix` and the version below, then run `nix build` to verify.

## Version

Currently packages MailCraft v0.11.0

## License

MailCraft is licensed under Apache-2.0.
