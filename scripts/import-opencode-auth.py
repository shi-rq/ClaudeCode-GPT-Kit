#!/usr/bin/env python3
import json
import os
import pathlib
import sys

src = pathlib.Path.home() / ".local/share/opencode/auth.json"
dst = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path("data/tokens.json")

if not src.exists():
    print(f"OpenCode auth not found: {src}", file=sys.stderr)
    sys.exit(1)

data = json.loads(src.read_text())
openai = data.get("openai")
if not isinstance(openai, dict):
    print("OpenCode auth.json does not contain an OpenAI OAuth login", file=sys.stderr)
    sys.exit(1)

payload = {
    "access_token": openai["access"],
    "refresh_token": openai["refresh"],
    "expires_at": int(openai["expires"]),
    "chatgpt_account_id": openai.get("accountId"),
}

dst.parent.mkdir(parents=True, exist_ok=True)
dst.write_text(json.dumps(payload, indent=2))
os.chmod(dst, 0o600)
print(dst)
