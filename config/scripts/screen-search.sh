#!/usr/bin/env bash
set -euo pipefail
# This explicit action uploads the selected region to uguu.se for Google Lens.
work=$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/hshell-lens.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
region=$(slurp) || exit 0
[[ -n $region ]] || exit 0
grim -g "$region" "$work/region.png"
notify-send 'Screen search' 'Uploading selected region to uguu.se for Google Lens.'
if ! curl --fail --show-error --max-time 90 -F "files[]=@$work/region.png" 'https://uguu.se/upload' > "$work/response.json"; then
    notify-send 'Screen search failed' 'The image could not be uploaded.'; exit 1
fi
url=$(python3 - "$work/response.json" <<'PY'
import json,sys,urllib.parse
value=json.load(open(sys.argv[1]))['files'][0]['url']
if urllib.parse.urlsplit(value).scheme != 'https': raise SystemExit('Unexpected upload URL')
print('https://lens.google.com/uploadbyurl?url='+urllib.parse.quote(value,safe=''))
PY
)
xdg-open "$url"
