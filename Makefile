SHELL := /bin/bash
# Dossier du Makefile, quel que soit l'endroit d'où make est lancé
DOTFILES := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
BREW_INSTALL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
ZSH_CUSTOM ?= $(HOME)/.oh-my-zsh/custom

# Paquets requis, puis paquets absents de certaines versions (installés un par un)
APT_PKGS := grc bat zsh htop golang curl vim tmux gcc g++ ranger
APT_OPTIONAL := eza

.PHONY: install debian ubuntu brew vim tmux shell zsh-plugins mac linux \
        brew-install brew-check brew-clean prefs-mac

# make install : enchaîne les étapes selon l'OS (relançable sans risque)
#   macOS  : brew, brew-install, shell, zsh-plugins, vim, tmux, mac
#   Linux  : debian ou ubuntu, shell, zsh-plugins, vim, tmux, linux
UNAME  := $(shell uname -s)
DISTRO := $(shell . /etc/os-release 2>/dev/null && echo $$ID)

ifeq ($(UNAME),Darwin)
install: brew brew-install shell zsh-plugins vim tmux mac
else ifneq ($(filter $(DISTRO),debian ubuntu),)
install: $(DISTRO) shell zsh-plugins vim tmux linux
else
install: shell zsh-plugins vim tmux linux
	@echo "⚠ Distribution '$(DISTRO)' non gérée : paquets système à installer à la main"
endif

ubuntu: APT_OPTIONAL += ghostty

debian ubuntu: ## Installe les paquets système
	sudo apt update && sudo apt install -y $(APT_PKGS)
	@for p in $(APT_OPTIONAL); do \
		sudo apt install -y $$p || echo "⚠ $$p indisponible dans les dépôts de cette version, ignoré"; \
	done

brew:
	@command -v brew >/dev/null || [ -x /opt/homebrew/bin/brew ] && echo "✓ Homebrew déjà installé" \
		|| bash -c "$$( $(CURL) $(BREW_INSTALL) )"

vim:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tmux:
	@[ -d ~/.tmux/plugins/tpm ] && echo "✓ tpm déjà installé" \
		|| git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# RUNZSH=no : ne lance pas zsh à la fin (sinon make install s'arrête là)
# L'installeur sauvegarde le ~/.zshrc existant en ~/.zshrc.pre-oh-my-zsh
shell:
	@[ -d ~/.oh-my-zsh ] && echo "✓ Oh My Zsh déjà installé" \
		|| RUNZSH=no sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

zsh-plugins:
	@for repo in zsh-syntax-highlighting zsh-completions zsh-autosuggestions; do \
		dir="$(ZSH_CUSTOM)/plugins/$$repo"; \
		[ -d "$$dir" ] && echo "✓ $$repo déjà installé" \
			|| git clone --depth=1 "https://github.com/zsh-users/$$repo" "$$dir"; \
	done

mac:
	ln -snvf $(DOTFILES)/.zshrc ~/.zshrc
	ln -snvf $(DOTFILES)/.vimrc ~/.vimrc
	ln -snvf $(DOTFILES)/.tmux.conf ~/.tmux.conf
	mkdir -p $(HOME)/.config/htop/
	ln -snvf $(DOTFILES)/config/htop/htoprc ~/.config/htop/htoprc
	mkdir -p $(HOME)/.config/ghostty/
	ln -snvf $(DOTFILES)/config/ghostty/config ~/.config/ghostty/config
	ln -snvf $(DOTFILES)/Brewfile ~/Brewfile

linux:
	ln -snvf $(DOTFILES)/.zshrc ~/.zshrc
	ln -snvf $(DOTFILES)/.vimrc ~/.vimrc
	ln -snvf $(DOTFILES)/.tmux.conf ~/.tmux.conf
	mkdir -p $(HOME)/.config/htop/
	ln -snvf $(DOTFILES)/config/htop/htoprc ~/.config/htop/htoprc
	mkdir -p $(HOME)/.config/ghostty/
	ln -snvf $(DOTFILES)/config/ghostty/config ~/.config/ghostty/config

# PATH complété : brew n'y est pas encore juste après sa 1re installation
brew-install: ## Installe les dépendances depuis le Brewfile
	PATH="/opt/homebrew/bin:/usr/local/bin:$$PATH" brew bundle --file=$(DOTFILES)/Brewfile

brew-check: ## Vérifie que tout est installé
	brew bundle check --verbose

brew-clean: ## Désinstalle ce qui n'est plus dans le Brewfile
	brew bundle cleanup --force

prefs-mac: ## Sans sudo : le script le demande lui-même pour les réglages système
	$(DOTFILES)/scripts/prefs_mac.sh
