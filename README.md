A fast, modern, and highly customized Neovim configuration optimized for
development.\
This setup includes **LSP support, syntax highlighting, fuzzy finding,
formatting, linting**, and various quality-of-life enhancements.

---

## Keybindings guide

```bash
https://neovim-keybindings-guide.vercel.app/
```

---

## 📌 Requirements

You need **Neovim version above 0.10.x**.\
Some plugins do not work well below **0.11.x**.

If your version is lower, build Neovim from source:\
https://github.com/neovim/neovim/blob/master/INSTALL.md

### ✔️ Required

1.  **Neovim** version **above 0.11.x**
2.  **lua 5.4**
3.  **luarocks**
4.  **LuaJIT**
5.  **Nerd Fonts**
6.  **ripgrep**
7.  **fzf**
8.  **go -- optional**
9.  **python3**
10. **nodejs**
11. **npm**
12. **clang**
13. **gcc**
14. **make**
15. **cmake**
16. **shellcheck**
17. **yazi -- optional**
18. **lazygit -- optional**
19. **diffutils**

---

## 📦 Install VsCode LSP Servers

```bash
sudo npm install -g vscode-langservers-extracted
```

---

## 📦 Install GO Tools -- Only needed when you are working with golang

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

```

---

## ⚙️ You can install more LSP Servers, Formatter or Linter using Mason

```bash
:Mason
```

---

## ⚔️ Optional: If you configured Neovim previously, remove it to prevent any conflicts.

#### Arch

```bash
sudo pacman -Rns neovim
```

#### Debian

```bash
sudo apt autoremove --purge neovim
```

#### Red Hat

```bash
sudo dnf remove neovim neovim-runtime
```

---

## 🗡️ Remove neovim cache

```bash
rm -rf ~/.config/nvim\
      ~/.local/share/nvim\
     ~/.local/state/nvim\
    ~/.cache/nvim
```

---

## 🔌 Installation and Setup

```bash
cd /tmp
git clone --depth=1 https://github.com/sandipduley/neovim.git
cd neovim
cp -r nvim/ ~/.config/
```

---

## 🐋 Docker

```bash
docker run -it --name custom-name 0xlichi/neovim /bin/bash
```

---

## 📁 Neovim Folder Structure

        nvim/
        ├── init.lua
        ├── lazy-lock.json
        ├── lazyvim.json
        └── lua
            ├── core
            │   ├── keymaps.lua
            │   ├── function_context.lua
            │   ├── options.lua
            │   └── snippets.lua
            └── plugins
                ├── alpha.lua
                ├── autocompletion.lua
                ├── bufferline.lua
                ├── cmp.lua
                ├── colortheme-switcher.lua
                ├── comments.lua
                ├── dankcolors.lua
                ├── debug.lua
                ├── extra-plugins.lua
                ├── gitsigns.lua
                ├── indent-blankline.lua
                ├── lazygit.lua
                ├── lsp.lua
                ├── lualine.lua
                ├── neotree.lua
                ├── none-ls.lua
                ├── render-markdown.lua
                ├── telescope.lua
                ├── tiny-inline-diagnostic.lua
                ├── toogle-term.lua
                ├── treesitter.lua
                ├── undotree.lua
                └── yazi.lua

#### 4 directories, 29 files

---

## 🚧 Issue

#### Failed to install ruff || python-lsp-server

###### Arch

```bash
sudo pacman -Sy python3 pipx

pipx install python-lsp-server
```

###### Ubuntu

```bash
sudo apt install python3 pipx

pipx install python-lsp-server
```

###### Red Hat

```bash
sudo dnf install python3-lsp-server
```

---
