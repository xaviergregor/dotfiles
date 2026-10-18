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

### Tout installer d'un coup

```bash
make install
```

Détecte macOS ou Linux (Debian / Ubuntu) et enchaîne les étapes ci-dessous dans l'ordre. Relançable sans risque : ce qui est déjà installé est sauté. Les préférences macOS (`make prefs-mac`) restent à lancer à part.

---

## 📋 Commandes disponibles

### 📦 Installation des paquets système

| Commande | Description |
|---|---|
| `make debian` | Installe les paquets essentiels sur Debian |
| `make ubuntu` | Installe les paquets essentiels sur Ubuntu (+ Ghostty) |

Paquets installés : `grc`, `bat`, `zsh`, `htop`, `golang`, `curl`, `vim`, `tmux`, `gcc`, `g++`, `ranger`

Installés s'ils existent dans les dépôts de la version (sinon ignorés) : `eza`, et `ghostty` sur Ubuntu

---

### 🍺 Homebrew (macOS)

| Commande | Description |
|---|---|
| `make brew` | Installe Homebrew |
| `make brew-install` | Installe toutes les dépendances depuis le `Brewfile` |
| `make brew-check` | Vérifie que tout le Brewfile est installé |
| `make brew-clean` | Désinstalle ce qui n'est plus dans le Brewfile |

---

### 🐚 Shell & Plugins

| Commande | Description |
|---|---|
| `make shell` | Installe Oh My Zsh |
| `make zsh-plugins` | Installe les plugins zsh (syntax-highlighting, completions, autosuggestions) |

Plugins installés dans `~/.oh-my-zsh/custom/plugins/` :
- `zsh-syntax-highlighting`
- `zsh-completions`
- `zsh-autosuggestions`

---

### 🛠️ Outils

| Commande | Description |
|---|---|
| `make vim` | Installe vim-plug (`~/.vim/autoload/plug.vim`) |
| `make tmux` | Installe TPM — Tmux Plugin Manager (`~/.tmux/plugins/tpm`) |

---

### 🔗 Liens symboliques & configuration

| Commande | Description |
|---|---|
| `make mac` | Crée les liens symboliques pour macOS |
| `make linux` | Crée les liens symboliques pour Linux |
| `make prefs-mac` | Applique les préférences système macOS (via `scripts/prefs_mac.sh`, à lancer **sans** sudo) |

#### Fichiers liés sur macOS (`make mac`)

| Source (dépôt) | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.vimrc` | `~/.vimrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `config/htop/htoprc` | `~/.config/htop/htoprc` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `Brewfile` | `~/Brewfile` |

#### Fichiers liés sur Linux (`make linux`)

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
# 1. Installer Homebrew
make brew

# 2. Installer Oh My Zsh
make shell

# 3. Installer les plugins zsh
make zsh-plugins

# 4. Installer vim-plug
make vim

# 5. Installer TPM pour tmux
make tmux

# 6. Créer les liens symboliques
make mac

# 7. Installer les dépendances Homebrew
make brew-install

# 8. (Optionnel) Appliquer les préférences système
#    Si scripts/local.env n'existe pas, le script demande nom / email / téléphone et le crée
make prefs-mac
```

## 🐧 Installation complète Linux (Ubuntu)

```bash
# 1. Installer les paquets système
make ubuntu

# 2. Installer Oh My Zsh
make shell

# 3. Installer les plugins zsh
make zsh-plugins

# 4. Installer vim-plug
make vim

# 5. Installer TPM pour tmux
make tmux

# 6. Créer les liens symboliques
make linux
```

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
