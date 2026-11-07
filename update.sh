#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_dir"

api_url="https://api.github.com/repos/UCS-Care-Group/mailcraft/releases/latest"

latest_tag="$(curl -fsSL "$api_url" | python3 -c 'import sys, json; print(json.load(sys.stdin).get("tag_name", ""))')"
if [[ -z "$latest_tag" ]]; then
  echo "Error: Could not fetch the latest upstream release." >&2
  exit 1
fi

version="${latest_tag#v}"

current_version="$(python3 - <<'PY'
import re
from pathlib import Path
text = Path('package.nix').read_text(encoding='utf-8')
match = re.search(r'version\s*=\s*"([^"]+)";', text)
print(match.group(1) if match else '')
PY
)"

if [[ "$current_version" == "$version" ]]; then
  echo "MailCraft is already at v${version}."
  exit 0
fi

appimage_url="$(curl -fsSL "$api_url" | python3 - <<'PY'
import json, sys
release = json.load(sys.stdin)
for asset in release.get('assets', []):
    name = asset.get('name', '')
    if name.endswith('-linux-x86_64.AppImage'):
        print(asset.get('browser_download_url', ''))
        raise SystemExit
else:
    raise SystemExit('No Linux AppImage asset was found in the latest release.')
PY
)"

if [[ -z "$appimage_url" ]]; then
  echo "Error: Could not find the Linux AppImage asset for v${version}." >&2
  exit 1
fi

tmp_file="$(mktemp /tmp/mailcraft-update.XXXXXX.AppImage)"
trap 'rm -f "$tmp_file"' EXIT

curl -fsSL "$appimage_url" -o "$tmp_file"
sha256_hex="$(sha256sum "$tmp_file" | awk '{print $1}')"
sri_hash="$(nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri "$sha256_hex")"

python3 - "$version" "$sri_hash" <<'PY'
import re
import sys
from pathlib import Path

version, sri_hash = sys.argv[1:3]
package_path = Path('package.nix')
package_text = package_path.read_text(encoding='utf-8')
package_text, package_count = re.subn(r'(version\s*=\s*")[^"]+(";)', rf'\g<1>{version}\2', package_text, count=1)
if package_count != 1:
    raise SystemExit('Failed to update the package version in package.nix')
package_text, hash_count = re.subn(r'(hash\s*=\s*")[^"]+(";)', rf'\g<1>{sri_hash}\2', package_text, count=1)
if hash_count != 1:
    raise SystemExit('Failed to update the AppImage hash in package.nix')
package_path.write_text(package_text, encoding='utf-8')

readme_path = Path('README.md')
readme_text = readme_path.read_text(encoding='utf-8')
readme_text, readme_count = re.subn(r'Currently packages MailCraft v[^\n]+', f'Currently packages MailCraft v{version}', readme_text, count=1)
if readme_count != 1:
    raise SystemExit('Failed to update the version in README.md')
readme_path.write_text(readme_text, encoding='utf-8')

print(f'Updated MailCraft to v{version}')
PY

echo "Updated to version v${version}"
echo "Hash: ${sri_hash}"
