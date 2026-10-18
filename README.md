# 🔧 Dotfiles

> Mes fichiers de configuration pour un environnement de développement optimisé sur macOS et Linux

[![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.linux.org/)
[![Made with Love](https://img.shields.io/badge/Made%20with-❤️-red.svg)](https://github.com/xaviergregor/dotfiles)

## 📖 À propos

Ce dépôt contient l'ensemble de mes fichiers de configuration (dotfiles) pour créer un environnement de développement cohérent et reproductible sur plusieurs machines. Que vous configuriez un nouveau Mac ou une distribution Linux, ces dotfiles vous permettent d'être opérationnel en quelques commandes.

## ✨ Fonctionnalités

- 🍎 **Compatible macOS** — Configuration complète avec Homebrew, Brewfile et préférences système
- 🐧 **Compatible Linux** — Fonctionne sur Debian et Ubuntu (avec support Ghostty natif)
- 👻 **Ghostty** — Configuration terminal liée symboliquement sur macOS et Linux
- 🐚 **Oh My Zsh** — Shell configuré avec syntax highlighting, autosuggestions et completions
- ⚡ **vim-plug** — Gestionnaire de plugins Vim prêt à l'emploi
- 🖥️ **Tmux** — Configuration liée avec TPM (Tmux Plugin Manager)
- 📦 **Brewfile** — Gestion déclarative des dépendances macOS via `brew bundle`
- 🔗 **Liens symboliques** — Tous les fichiers de config sont liés depuis le dépôt vers `$HOME`
- 🐚 **Un seul `.zshrc`** — commun macOS / Linux, les différences sont gérées via `$OSTYPE`

## 🚀 Installation rapide

### Prérequis

- Git installé sur votre système
- Make (généralement préinstallé sur macOS et Linux)
- Homebrew (macOS uniquement — voir `make brew`)

### Cloner le dépôt

```bash
git clone https://github.com/xaviergregor/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

## 📋 Commandes disponibles

À lancer depuis `~/dotfiles`. Chaque commande peut être relancée sans risque.

| Commande | Description |
|---|---|
| `make apt` | Paquets système Debian / Ubuntu : `grc`, `bat`, `zsh`, `htop`, `golang`, `curl`, `vim`, `tmux`, `gcc`, `g++`, `ranger` (+ `eza` et `ghostty` s'ils existent dans les dépôts) |
| `make brew` | Installe Homebrew (macOS) |
| `make brew-install` | Installe les paquets du `Brewfile` (macOS) |
| `make shell` | Installe Oh My Zsh |
| `make zsh-plugins` | Installe zsh-syntax-highlighting, zsh-completions et zsh-autosuggestions |
| `make vim` | Installe vim-plug |
| `make tmux` | Installe TPM (Tmux Plugin Manager) |
| `make link` | Crée les liens symboliques (tableau ci-dessous) |
| `make prefs-mac` | Préférences système macOS, à lancer **sans** sudo. Crée `scripts/local.env` en posant les questions s'il manque |

Pour le Brewfile : `brew bundle check` vérifie ce qui manque, `brew bundle cleanup` liste ce qui n'y est plus.

### Fichiers liés (`make link`)

| Source (dépôt) | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.vimrc` | `~/.vimrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `config/htop/htoprc` | `~/.config/htop/htoprc` |
| `config/ghostty/config` | `~/.config/ghostty/config` |

---

## 🍎 Installation complète macOS

```bash
make brew
make brew-install
make shell          # remplace ~/.zshrc (sauvegardé en ~/.zshrc.pre-oh-my-zsh)
make zsh-plugins
make vim
make tmux
make link           # après make shell, pour remettre le .zshrc du dépôt
make prefs-mac      # optionnel
```

## 🐧 Installation complète Linux (Debian / Ubuntu)

```bash
make apt
make shell
make zsh-plugins
make vim
make tmux
make link
```

Ensuite : `:PlugInstall` dans vim, `prefix + I` dans tmux.

---

## 🤝 Contribution

Les suggestions et améliorations sont les bienvenues ! N'hésitez pas à :

- 🐛 Signaler des bugs
- 💡 Proposer de nouvelles fonctionnalités
- 🔀 Soumettre des pull requests

## 📝 Licence

Ce projet est sous licence MIT — voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

Inspiré par la communauté [dotfiles](https://dotfiles.github.io/) et les nombreux développeurs qui partagent leurs configurations.

---

<div align="center">

Fait avec ❤️ par Xavier Gregor

</div>
