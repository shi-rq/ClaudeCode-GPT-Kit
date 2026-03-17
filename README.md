# ClaudeCode-GPT-Kit

Run `Claude Code` on `ChatGPT Plus/Pro` through a local Codex proxy.

For Chinese instructions, see [README_ZH.md](README_ZH.md).

This project is packaged to be easy to hand off: enter the folder, run one setup command, and then launch `claude-gpt`.

## What is included

- `proxy/` - a local Anthropic-compatible proxy based on `chatgpt-codex-proxy`
- `bin/claude-gpt` - a wrapper command that auto-starts the proxy and launches Claude Code
- `scripts/setup.sh` - one-time setup for install, build, login/import, and command installation
- `scripts/import-opencode-auth.py` - imports an existing OpenCode OpenAI OAuth login when available

## Prerequisites

- `claude` is installed and works on your machine
- `node` and `npm` are installed
- one of these is true:
  - you already logged into OpenAI inside OpenCode
  - you can complete a browser login for ChatGPT Plus/Pro during setup

## Quick Start

From this folder:

```bash
chmod +x scripts/setup.sh bin/claude-gpt scripts/import-opencode-auth.py
./scripts/setup.sh
claude-gpt
```

That is the full setup flow.

## What setup does

`./scripts/setup.sh` will:

1. install proxy dependencies
2. build the proxy
3. create `proxy/.env` with `gpt-5.3-codex` as the default Sonnet mapping
4. try to import an OpenAI OAuth token from `~/.local/share/opencode/auth.json`
5. if no reusable OpenCode token exists, open a browser login flow and save the token locally
6. install a local command symlink such as `~/.local/bin/claude-gpt` or another PATH-visible location

## Daily usage

After setup, run:

```bash
claude-gpt
```

The wrapper will automatically:

- start the local proxy if it is not already running
- point Claude Code to `http://127.0.0.1:19080`
- reuse the saved OpenAI OAuth token from `data/tokens.json`

## Verify it is really using GPT

After launching `claude-gpt`, the Claude UI may still show Claude model names. That is expected.

The real backend call is logged in:

```bash
cat logs/chatgpt-codex-proxy.log
```

Look for a line like:

```text
Calling gpt-5.3-codex with effort=high
```

## Important files

- `data/tokens.json` - the OpenAI OAuth token actually used by this project
- `logs/chatgpt-codex-proxy.log` - local proxy logs
- `proxy/.env` - model mapping and proxy defaults

## Re-login

If the saved login stops working:

```bash
rm -f data/tokens.json
CHATGPT_CODEX_PROXY_TOKEN_FILE="$PWD/data/tokens.json" npm --prefix proxy run login
```

## Change the default model

Edit `proxy/.env`.

Example:

```env
ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.3-codex-xhigh
```

Then close the current Claude session and run `claude-gpt` again.

## Troubleshooting

- `claude-gpt: command not found`
  - add `~/.local/bin` or the install path printed by setup to your PATH, then reopen the shell
- proxy fails to start
  - inspect `logs/chatgpt-codex-proxy.log`
- setup says login is missing
  - rerun `./scripts/setup.sh`
- Claude UI still says Sonnet
  - that is only the client UI label; verify the actual backend in the proxy log

## Where OpenAI auth is stored

This project uses a local OAuth token file at:

```bash
data/tokens.json
```

That file contains the OpenAI login actually used by the local proxy.

During setup, the project first tries to import an existing OpenCode login from:

```bash
~/.local/share/opencode/auth.json
```

So you may see auth data in two places:

- `~/.local/share/opencode/auth.json` - OpenCode's own saved login
- `data/tokens.json` - the token copy this project actually uses

If `data/tokens.json` is deleted or expires, log in again with:

```bash
rm -f data/tokens.json
CHATGPT_CODEX_PROXY_TOKEN_FILE="$PWD/data/tokens.json" npm --prefix proxy run login
```
