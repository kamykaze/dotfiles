# Homebrew 6+ refuses to load formulae from third-party taps unless they are
# trusted. `trusted:` declares that here so `brew bundle` never stops to ask.
# Only the formulae actually used below are trusted, not the whole tap.
tap "apppackio/apppack", trusted: { formulae: ["apppack"] }
tap "armmbed/formulae", trusted: { formulae: ["arm-none-eabi-gcc"] }
tap "heroku/brew", trusted: { formulae: ["heroku"] }
tap "stripe/stripe-cli", trusted: { formulae: ["stripe"] }

# ============================================================
# CLI Tools
# ============================================================
brew "coreutils"
brew "fzf"
brew "gh"
brew "git"
brew "just"
brew "node"
brew "python@3.12"

# ============================================================
# Development Tools
# ============================================================
brew "cmake"
brew "ffmpeg"
brew "go"
brew "imagemagick"
brew "kanata"
brew "libfido2"
brew "libtiff"
brew "little-cms2"
brew "mysql"
brew "openjpeg"
brew "pillow"
brew "webp"

# ============================================================
# QMK / Hardware
# ============================================================
brew "armmbed/formulae/arm-none-eabi-gcc"
brew "haskell-stack"

# ============================================================
# Work / Misc
# ============================================================
brew "apppackio/apppack/apppack"
brew "heroku/brew/heroku"
brew "stripe/stripe-cli/stripe"

# ============================================================
# GUI Apps (Casks)
# ============================================================
# NOTE: karabiner-elements is deliberately NOT here. It is `auto_updates`, so brew
# cannot hold it back, and it ships whatever VirtualHIDDevice driver version it
# likes — 16.1.0 shipped driver 8.0.0 while kanata 1.12.0 requires 6.2.0, which
# silently breaks all mappings. scripts/karabiner-driver.sh pins the driver.
cask "visual-studio-code"          # Editor (required for vscode entries below)
cask "bettertouchtool"             # Trackpad / keyboard customization
cask "claude"                      # Claude Desktop (MCP integrations)
cask "google-drive"                # Cloud storage
cask "granola"                     # AI meeting notes
cask "jumpcut"                     # Clipboard manager
cask "session-manager-plugin"      # AWS SSM
cask "spotify"                     # Music streaming
cask "ticktick"                    # Task manager
cask "warp"                        # Terminal (with cloud sync)
cask "prusaslicer"                 # G-code generator for 3D printers (RepRap, Makerbot, Ultimaker etc.)
cask "brainfm"                     # Focus music
# cask "whispr-flow"               # Voice dictation — install manually if not available

# ============================================================
# VS Code Extensions
# ============================================================
vscode "agutierrezr.emmet-keybindings"
vscode "anthropic.claude-code"
vscode "bierner.github-markdown-preview"
vscode "bierner.markdown-checkbox"
vscode "bierner.markdown-emoji"
vscode "bierner.markdown-footnotes"
vscode "bierner.markdown-mermaid"
vscode "bierner.markdown-preview-github-styles"
vscode "bierner.markdown-yaml-preamble"
vscode "canadaduane.vscode-kmonad"
vscode "charliermarsh.ruff"
vscode "codezombiech.gitignore"
vscode "davidanson.vscode-markdownlint"
vscode "docker.docker"
vscode "eamodio.gitlens"
vscode "ecmel.vscode-html-css"
vscode "editorconfig.editorconfig"
vscode "github.copilot-chat"
vscode "github.vscode-github-actions"
vscode "github.vscode-pull-request-github"
vscode "kawamataryo.copy-python-dotted-path"
vscode "mechatroner.rainbow-csv"
vscode "ms-azuretools.vscode-containers"
vscode "ms-azuretools.vscode-docker"
vscode "ms-python.debugpy"
vscode "ms-python.isort"
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-python.vscode-python-envs"
vscode "ms-toolsai.jupyter"
vscode "ms-toolsai.jupyter-keymap"
vscode "ms-toolsai.jupyter-renderers"
vscode "ms-toolsai.vscode-jupyter-cell-tags"
vscode "ms-toolsai.vscode-jupyter-slideshow"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode.cmake-tools"
vscode "ms-vscode.cpp-devtools"
vscode "ms-vscode.cpptools"
vscode "ms-vscode.cpptools-extension-pack"
vscode "ms-vscode.cpptools-themes"
vscode "ms-vscode.vscode-speech"
vscode "prateekmahendrakar.prettyxml"
vscode "shd101wyy.markdown-preview-enhanced"
vscode "shopify.theme-check-vscode"
vscode "syler.sass-indented"
vscode "tamasfe.even-better-toml"
vscode "vscodevim.vim"
vscode "xabikos.javascriptsnippets"
vscode "xaver.clang-format"
vscode "ziyasal.vscode-open-in-github"
