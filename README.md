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

Currently packages MailCraft v0.12.0

## Troubleshooting

### Linux trust anchors warning

If MailCraft logs:

```
no certification authorities for mail could be read
```

it means MailCraft could not find the mail-purpose trust bundle at one of its
hardcoded paths:

- `/etc/ca-certificates/extracted/email-ca-bundle.pem`
- `/etc/pki/ca-trust/extracted/pem/email-ca-bundle.pem`
- `/var/lib/ca-certificates/email-ca-bundle.pem`

On systems where this bundle is not generated automatically, create it from
p11-kit:

```bash
sudo mkdir -p /etc/ca-certificates/extracted
sudo nix shell nixpkgs#p11-kit -c trust extract \
  --overwrite \
  --format=pem-bundle \
  --filter=ca-anchors \
  --purpose=email \
  /etc/ca-certificates/extracted/email-ca-bundle.pem
```

After that, restart MailCraft.

### zbus ServiceUnknown warning

This warning:

```
zbus::proxy: Failed to populate properties cache via GetAll: org.freedesktop.DBus.Error.ServiceUnknown
```

is usually benign on minimal desktops/sessions without the related D-Bus
service. MailCraft should still run.

## License

MailCraft is licensed under Apache-2.0.
