#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROXY_DIR="$ROOT_DIR/proxy"
TOKEN_FILE="$ROOT_DIR/data/tokens.json"

choose_bin_dir() {
  local candidate
  for candidate in "$HOME/.local/bin" "$HOME/.opencode/bin"; do
    if [ -d "$candidate" ] && [[ ":$PATH:" == *":$candidate:"* ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  printf '%s\n' "$HOME/.local/bin"
}

BIN_DIR="$(choose_bin_dir)"
TARGET_BIN="$BIN_DIR/claude-gpt"

mkdir -p "$ROOT_DIR/data" "$ROOT_DIR/logs" "$BIN_DIR"

if ! command -v claude >/dev/null 2>&1; then
  printf 'Error: `claude` is not installed or not on PATH.\n' >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  printf 'Error: `node` and `npm` are required.\n' >&2
  exit 1
fi

cat >"$PROXY_DIR/.env" <<'EOF'
PORT=19080
PASSTHROUGH_MODE=false
ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.3-codex-spark
ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.3-codex
ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-5.4
PROXY_DEFAULT_EFFORT=high
PROXY_MCP_SERVERS=
EOF

if [ ! -d "$PROXY_DIR/node_modules" ]; then
  npm --prefix "$PROXY_DIR" install
fi

npm --prefix "$PROXY_DIR" run build

if [ ! -f "$TOKEN_FILE" ]; then
  if python3 "$ROOT_DIR/scripts/import-opencode-auth.py" "$TOKEN_FILE" >/dev/null 2>&1; then
    printf 'Imported OpenAI OAuth token from OpenCode.\n'
  else
    printf 'No reusable OpenCode OAuth token found. Starting browser login...\n'
    CHATGPT_CODEX_PROXY_TOKEN_FILE="$TOKEN_FILE" npm --prefix "$PROXY_DIR" run login
  fi
fi

ln -sf "$ROOT_DIR/bin/claude-gpt" "$TARGET_BIN"

case ":$PATH:" in
  *":$BIN_DIR:"*)
    ;;
  *)
    printf '\nAdd %s to PATH if `claude-gpt` is not found after this shell.\n' "$BIN_DIR"
    ;;
esac

printf '\nSetup complete. Command installed at: %s\nRun: claude-gpt\n' "$TARGET_BIN"
