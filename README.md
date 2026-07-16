# Neovim Configuration

A fast, modern, and highly customized Neovim configuration optimized for development.

This setup includes LSP support, syntax highlighting, fuzzy finding, formatting, linting, and various quality-of-life enhancements.

## Keybindings Guide

https://neovim-keybindings-guide.vercel.app/

## Requirements

You need Neovim version 0.11.6

### Required Dependencies

1. Neovim (version 0.11.6)
2. Lua 5.4
3. Luarocks
4. LuaJIT
5. Nerd Fonts
6. ripgrep
7. fzf
8. Go (optional)
9. Python 3
10. Node.js
11. npm
12. clang
13. gcc
14. make
15. cmake
16. shellcheck
17. yazi (optional)
18. lazygit (optional)
19. diffutils

## Installing LSP Servers

Install the VS Code language servers:

```bash
sudo npm install -g vscode-langservers-extracted
```

Additional LSP servers, formatters, and linters can be installed through Mason:

```
:Mason
```

## Building Neovim from Source

For better compatibility with Treesitter, install Neovim version 0.11.6:

```bash
cd /tmp
git clone https://github.com/neovim/neovim
cd neovim
git checkout v0.11.6
make CMAKE_BUILD_TYPE=Release
sudo make install
nvim --version
```

## Removing Existing Neovim Cache

```bash
rm -rf ~/.config/nvim \
       ~/.local/share/nvim \
       ~/.local/state/nvim \
       ~/.cache/nvim
```

## Installation and Setup

```bash
cd /tmp
git clone --depth=1 https://github.com/sandipduley/neovim.git
cd neovim
cp -r nvim/ ~/.config/
```

## Docker

To try the configuration in a container before installing it locally:

```bash
docker run -it --name custom-name 0xlichi/neovim /bin/bash
```

## Folder Structure

```
nvim
├── init.lua
├── lazy-lock.json
└── lua
    ├── core
    │   ├── function_context.lua
    │   ├── keymaps.lua
    │   ├── options.lua
    │   └── snippets.lua
    └── plugins
        ├── alpha.lua
        ├── autocompletion.lua
        ├── bufferline.lua
        ├── colortheme-switcher.lua
        ├── comments.lua
        ├── debug.lua
        ├── flash.lua
        ├── gitsigns.lua
        ├── harpoon2.lua
        ├── indent-blankline.lua
        ├── lsp.lua
        ├── lualine.lua
        ├── markdown-render.lua
        ├── misc.lua
        ├── noice.lua
        ├── none-ls.lua
        ├── telescope.lua
        ├── tiny-inline-diagnostic.lua
        ├── toogle-term.lua
        ├── treesitter.lua
        ├── treesitter-textobjects.lua
        ├── treesj.lua
        ├── twilight.lua
        ├── undotree.lua
        └── yazi.lua

4 directories, 31 files
```
