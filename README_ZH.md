# ClaudeCode-GPT-Kit

通过本地 Codex 代理，让 `Claude Code` 使用 `ChatGPT Plus/Pro`。

英文说明见 [README.md](README.md)。

这个项目已经整理成开箱即用的形式：进入目录，执行一次初始化命令，之后直接运行 `claude-gpt` 即可。

## 项目包含什么

- `proxy/` - 基于 `chatgpt-codex-proxy` 的本地 Anthropic 兼容代理
- `bin/claude-gpt` - 启动包装命令，会自动拉起代理并启动 Claude Code
- `scripts/setup.sh` - 一次性初始化脚本，负责安装、构建、登录导入和命令安装
- `scripts/import-opencode-auth.py` - 如果本机已有 OpenCode 的 OpenAI OAuth 登录态，会自动导入

## 前置条件

- 已安装 [ClaudeCode](https://code.claude.com/docs/en/overview)，并且可以正常运行
- 已安装 `node` 和 `npm`
- 满足以下任一条件：
  - 你已经在 [OpenCode](https://opencode.ai/docs/) 里登录过 OpenAI
  - 你可以在初始化时通过浏览器完成 ChatGPT Plus/Pro 登录

## 快速开始

在当前目录执行：

```bash
chmod +x scripts/setup.sh bin/claude-gpt scripts/import-opencode-auth.py
./scripts/setup.sh
claude-gpt
```

完整流程就是这三步。

## 初始化脚本会做什么

`./scripts/setup.sh` 会自动完成：

1. 安装代理依赖
2. 构建代理
3. 生成 `proxy/.env`，并把 Sonnet 默认映射到 `gpt-5.3-codex`
4. 尝试从 `~/.local/share/opencode/auth.json` 导入 OpenAI OAuth token
5. 如果没有可复用的 OpenCode 登录态，则自动打开浏览器进行 ChatGPT Plus/Pro 登录
6. 安装本地命令链接，例如 `~/.local/bin/claude-gpt` 或当前 PATH 中可用的位置

## 日常使用

初始化完成后，直接运行：

```bash
claude-gpt
```

这个包装命令会自动：

- 在代理未启动时自动启动本地代理
- 把 Claude Code 指向 `http://127.0.0.1:19080`
- 复用保存在 `data/tokens.json` 里的 OpenAI OAuth 登录态

## 如何确认当前用的是 GPT

运行 `claude-gpt` 后，Claude 的界面仍然可能显示 Claude 的模型名，这是正常现象。

真正的后端调用会记录在：

```bash
cat logs/chatgpt-codex-proxy.log
```

看到类似下面这一行，就说明实际调用的是 GPT：

```text
Calling gpt-5.3-codex with effort=high
```

## 你可能会关心的文件

- `data/tokens.json` - 本项目实际使用的 OpenAI OAuth token
- `logs/chatgpt-codex-proxy.log` - 本地代理日志
- `proxy/.env` - 模型映射和代理默认配置

## 重新登录

如果保存的登录态失效，可以执行：

```bash
rm -f data/tokens.json
CHATGPT_CODEX_PROXY_TOKEN_FILE="$PWD/data/tokens.json" npm --prefix proxy run login
```

## 修改默认模型

编辑 `proxy/.env`。

例如：

```env
ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.3-codex-xhigh
```

修改后，关闭当前 Claude 会话，再重新运行 `claude-gpt` 即可生效。

## 常见问题

- `claude-gpt: command not found`
  - 把 `~/.local/bin` 或脚本提示的安装目录加入 PATH，然后重新打开终端
- 代理启动失败
  - 查看 `logs/chatgpt-codex-proxy.log`
- 初始化提示缺少登录态
  - 重新运行 `./scripts/setup.sh`
- Claude 界面仍然显示 Sonnet
  - 这只是客户端界面文案，不代表实际后端；请以代理日志为准

## OpenAI 认证保存在哪里

本项目实际使用的本地 OAuth token 文件是：

```bash
data/tokens.json
```

这个文件保存了本地代理实际使用的 OpenAI 登录信息。

初始化时，项目会优先尝试从 OpenCode 导入已有登录态，来源文件是：

```bash
~/.local/share/opencode/auth.json
```

所以你可能会看到两处认证数据：

- `~/.local/share/opencode/auth.json` - OpenCode 自己保存的登录态
- `data/tokens.json` - 本项目实际使用的登录态副本

如果 `data/tokens.json` 被删除或过期，可以重新登录：

```bash
rm -f data/tokens.json
CHATGPT_CODEX_PROXY_TOKEN_FILE="$PWD/data/tokens.json" npm --prefix proxy run login
```

## Warning ⚠️

本项目仅供个人在本地环境中使用。你需要自行确认并遵守 Anthropic、OpenAI、Claude Code、OpenCode 及其他相关服务的条款、政策和账号规则。请不要提交、分享或公开任何 token、日志或账号数据。
