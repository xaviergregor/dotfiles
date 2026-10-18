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

## ⚡ Installation guidée

```bash
make install
```

Le script détecte macOS ou Linux (Debian / Ubuntu), vérifie ce qui est déjà en place et propose la liste des étapes :

```
==> macOS 15.1 (arm64) détecté

  [✓] 1. Homebrew               déjà installé
  [ ] 2. Paquets du Brewfile    12 manquant(s)
  [✓] 3. Oh My Zsh              déjà installé
  [ ] 4. Plugins zsh            manquants : zsh-completions
  [✓] 5. vim-plug               déjà installé
  [ ] 6. TPM (tmux)             absent
  [ ] 7. Liens symboliques      1 à créer, ~/.zshrc pointe ailleurs
  [ ] 8. Préférences macOS      optionnel, réglages système

Étapes à lancer ? [Entrée = 2 4 6 7 | a = tout | q = quitter] :
```

- **Entrée** lance ce qui manque (les préférences macOS restent optionnelles), ou tape les numéros voulus (`2 4 7`).
- Les fichiers existants remplacés par un lien sont sauvegardés en `.bak-<date>`.
- À la fin : installation des plugins vim et tmux, et proposition de passer le shell par défaut à zsh.

| Commande | Description |
|---|---|
| `make install` | Liste interactive |
| `make install YES=1` | Installe tout ce qui manque, sans question |
| `make install DRY=1` | Affiche les commandes sans rien exécuter |

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
| `make link` | Crée les liens symboliques selon l'OS détecté (`make mac` / `make linux` sont des alias) |
| `make prefs-mac` | Applique les préférences système macOS (via `scripts/prefs_mac.sh`, à lancer **sans** sudo ; crée `scripts/local.env` en posant les questions s'il manque) |

#### Fichiers liés sur macOS

| Source (dépôt) | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.vimrc` | `~/.vimrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `config/htop/htoprc` | `~/.config/htop/htoprc` |
| `config/ghostty/config` | `~/.config/ghostty/config` |
| `Brewfile` | `~/Brewfile` |

#### Fichiers liés sur Linux

| Source (dépôt) | Destination |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.vimrc` | `~/.vimrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `config/htop/htoprc` | `~/.config/htop/htoprc` |
| `config/ghostty/config` | `~/.config/ghostty/config` |

---

## 🧰 Installation manuelle

`make install` enchaîne les mêmes cibles ; elles restent utilisables une par une.

```bash
# macOS
make brew && make brew-install
make shell && make zsh-plugins
make vim && make tmux
make link
make prefs-mac   # optionnel

# Linux
make debian      # ou : make ubuntu
make shell && make zsh-plugins
make vim && make tmux
make link
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
