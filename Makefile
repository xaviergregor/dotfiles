SHELL := /bin/bash
CURL  := curl -fsSL

# ─── URLs ─────────────────────────────────────────────────────────────────────
OHMYZSH_URL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
BREW_URL    := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# ─── OS Detection ─────────────────────────────────────────────────────────────
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  OS := macos
else ifeq ($(UNAME_S),Linux)
  _DISTRO := $(shell . /etc/os-release 2>/dev/null && echo "$${ID}")
  ifeq ($(_DISTRO),ubuntu)
    OS := ubuntu
  else
    OS := debian
  endif
else
  OS := unknown
endif

# ─── Paquets apt ──────────────────────────────────────────────────────────────
APT_PKGS := grc bat zsh htop curl vim tmux gcc g++ ranger fzf eza golang

# ─── Couleurs ANSI ────────────────────────────────────────────────────────────
CLR   := \033[0m
GREEN := \033[0;32m
CYAN  := \033[0;36m
YLW   := \033[1;33m
RED   := \033[0;31m
BOLD  := \033[1m
DIM   := \033[2m

# Macros de log (usage : $(call log_ok,message))
log_info = @printf " $(CYAN)➜$(CLR)  %s\n" "$(1)"
log_ok   = @printf " $(GREEN)✔$(CLR)  %s\n" "$(1)"
log_warn = @printf " $(YLW)⚠$(CLR)  %s\n"  "$(1)"
log_err  = @printf " $(RED)✘$(CLR)  %s\n"  "$(1)"

# ─── Phony ────────────────────────────────────────────────────────────────────
.PHONY: all setup help check \
        cmd brew brewfile shell zsh-plugins vim tmux ghostty \
        dotfiles dotfiles-mac dotfiles-linux \
        mac linux ubuntu debian \
        hostname

.DEFAULT_GOAL := help

# ─────────────────────────────────────────────────────────────────────────────
# HELP
# ─────────────────────────────────────────────────────────────────────────────
help:
	@printf "\n$(BOLD)$(CYAN) ◈  ZeroCool — Dotfiles & Machine Setup$(CLR)\n"
	@printf " $(DIM)OS détecté : $(BOLD)$(OS)$(CLR)\n\n"
	@printf " $(BOLD)Point d'entrée$(CLR)\n"
	@printf "   $(GREEN)make setup$(CLR)          Setup complet pour l'OS courant\n"
	@printf "   $(GREEN)make check$(CLR)          Vérifie que tous les fichiers sources existent\n"
	@printf "\n $(BOLD)Modules$(CLR)\n"
	@printf "   $(CYAN)make cmd$(CLR)            Installe les paquets apt          $(DIM)[Linux]$(CLR)\n"
	@printf "   $(CYAN)make brew$(CLR)           Installe Homebrew                 $(DIM)[macOS]$(CLR)\n"
	@printf "   $(CYAN)make brewfile$(CLR)       Installe les paquets du Brewfile  $(DIM)[macOS]$(CLR)\n"
	@printf "   $(CYAN)make shell$(CLR)          Installe Oh My Zsh\n"
	@printf "   $(CYAN)make zsh-plugins$(CLR)    Clone les plugins zsh\n"
	@printf "   $(CYAN)make vim$(CLR)            Installe vim-plug\n"
	@printf "   $(CYAN)make tmux$(CLR)           Installe TPM\n"
	@printf "   $(CYAN)make ghostty$(CLR)        Installe Ghostty                  $(DIM)[Ubuntu]$(CLR)\n"
	@printf "   $(CYAN)make dotfiles$(CLR)       Symlink les dotfiles              $(DIM)[auto OS]$(CLR)\n"
	@printf "\n $(BOLD)Système$(CLR)\n"
	@printf "   $(CYAN)make hostname$(CLR)              Renomme la machine $(DIM)(interactif ou NAME=…)$(CLR)\n"
	@printf "\n $(BOLD)Alias dotfiles directs$(CLR)\n"
	@printf "   mac  ·  linux  ·  ubuntu  ·  debian\n\n"

# ─────────────────────────────────────────────────────────────────────────────
# SETUP COMPLET (auto OS)
# ─────────────────────────────────────────────────────────────────────────────
all: setup

setup:
ifeq ($(OS),macos)
	$(call log_info,macOS détecté — setup complet…)
	@$(MAKE) --no-print-directory brew dotfiles-mac brewfile shell zsh-plugins vim tmux
else ifeq ($(OS),ubuntu)
	$(call log_info,Ubuntu détecté — setup complet…)
	@$(MAKE) --no-print-directory cmd ghostty shell zsh-plugins vim tmux dotfiles-linux
else ifeq ($(OS),debian)
	$(call log_info,Debian détecté — setup complet…)
	@$(MAKE) --no-print-directory cmd shell zsh-plugins vim tmux dotfiles-linux
else
	$(call log_err,OS non reconnu : $(UNAME_S))
	@exit 1
endif

# ─────────────────────────────────────────────────────────────────────────────
# PAQUETS
# ─────────────────────────────────────────────────────────────────────────────
cmd:
ifeq ($(OS),macos)
	$(call log_warn,macOS : utilise 'make brew' puis installe via Brewfile)
else
	$(call log_info,Mise à jour apt…)
	@sudo apt update -qq
	$(call log_info,Installation : $(APT_PKGS))
	@sudo apt install -y $(APT_PKGS)
	$(call log_ok,Paquets installés)
endif

brew:
	$(call log_info,Installation de Homebrew…)
	@bash -c "$$($(CURL) $(BREW_URL))"

brewfile:
ifeq ($(OS),macos)
	$(call log_info,Installation des paquets Homebrew via Brewfile…)
	@if [ ! -f "$(PWD)/Brewfile" ]; then \
		printf " $(RED)✘$(CLR)  Brewfile introuvable : $(PWD)/Brewfile\n"; \
		exit 1; \
	fi
	@brew bundle --file="$(PWD)/Brewfile"
	$(call log_ok,Brewfile installé)
else
	$(call log_warn,Brewfile est uniquement pour macOS)
endif

ghostty:
ifeq ($(OS),ubuntu)
	$(call log_info,Installation de Ghostty…)
	@sudo apt install -y ghostty
	$(call log_ok,Ghostty installé)
else ifeq ($(OS),macos)
	$(call log_warn,Sur macOS : installe Ghostty depuis https://ghostty.org ou via Brewfile)
else
	$(call log_warn,Ghostty n'est pas disponible via apt sur Debian — voir https://ghostty.org)
endif

# ─────────────────────────────────────────────────────────────────────────────
# OUTILS DEV
# ─────────────────────────────────────────────────────────────────────────────
vim:
	$(call log_info,Installation de vim-plug…)
	@curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	$(call log_ok,vim-plug installé — lance :PlugInstall dans vim)

tmux:
	$(call log_info,Installation de TPM…)
	@if [ -d ~/.tmux/plugins/tpm ]; then \
		printf " $(YLW)⚠$(CLR)  TPM déjà présent — mise à jour\n"; \
		git -C ~/.tmux/plugins/tpm pull -q; \
	else \
		git clone -q https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; \
	fi
	$(call log_ok,TPM prêt — prefix + I dans tmux pour charger les plugins)

# ─────────────────────────────────────────────────────────────────────────────
# SHELL
# ─────────────────────────────────────────────────────────────────────────────
shell:
	$(call log_info,Installation de Oh My Zsh…)
	@if [ -d ~/.oh-my-zsh ]; then \
		printf " $(YLW)⚠$(CLR)  Oh My Zsh déjà installé — skip\n"; \
	else \
		RUNZSH=no sh -c "$$($(CURL) $(OHMYZSH_URL))"; \
	fi

zsh-plugins:
	$(call log_info,Installation des plugins zsh…)
	@for repo in \
		"zsh-users/zsh-syntax-highlighting" \
		"zsh-users/zsh-completions" \
		"zsh-users/zsh-autosuggestions"; do \
		name=$$(basename $$repo); \
		dest=~/.oh-my-zsh/custom/plugins/$$name; \
		if [ -d "$$dest" ]; then \
			printf " $(YLW)⚠$(CLR)  $$name présent — mise à jour\n"; \
			git -C "$$dest" pull -q; \
		else \
			printf " $(CYAN)➜$(CLR)  Clonage $$name…\n"; \
			git clone -q https://github.com/$$repo "$$dest"; \
		fi; \
	done
	$(call log_ok,Plugins zsh prêts)

# ─────────────────────────────────────────────────────────────────────────────
# DOTFILES
# ─────────────────────────────────────────────────────────────────────────────
dotfiles:
ifeq ($(OS),macos)
	@$(MAKE) --no-print-directory dotfiles-mac
else
	@$(MAKE) --no-print-directory dotfiles-linux
endif

dotfiles-mac:
	$(call log_info,Symlinking dotfiles — macOS…)
	@ln -snvf "$(PWD)/.zshrc_mac"            "$(HOME)/.zshrc"
	@ln -snvf "$(PWD)/.vimrc"                "$(HOME)/.vimrc"
	@ln -snvf "$(PWD)/.tmux.conf"            "$(HOME)/.tmux.conf"
	@mkdir -p "$(HOME)/.config/htop"
	@ln -snvf "$(PWD)/config/htop/htoprc"    "$(HOME)/.config/htop/htoprc"
	@mkdir -p "$(HOME)/.config/ghostty"
	@ln -snvf "$(PWD)/config/ghostty/config" "$(HOME)/.config/ghostty/config"
	@ln -snvf "$(PWD)/Brewfile"              "$(HOME)/Brewfile"
	$(call log_ok,Dotfiles macOS liés)

dotfiles-linux:
	$(call log_info,Symlinking dotfiles — Linux…)
	@ln -snvf "$(PWD)/.zshrc_linux"          "$(HOME)/.zshrc"
	@ln -snvf "$(PWD)/.vimrc"                "$(HOME)/.vimrc"
	@ln -snvf "$(PWD)/.tmux.conf"            "$(HOME)/.tmux.conf"
	@mkdir -p "$(HOME)/.config/htop"
	@ln -snvf "$(PWD)/config/htop/htoprc"    "$(HOME)/.config/htop/htoprc"
	@mkdir -p "$(HOME)/.config/ghostty"
	@ln -snvf "$(PWD)/config/ghostty/config" "$(HOME)/.config/ghostty/config"
	$(call log_ok,Dotfiles Linux liés)

# Alias pour compat + appel direct
mac:    dotfiles-mac
linux:  dotfiles-linux
ubuntu: dotfiles-linux
debian: dotfiles-linux

# ─────────────────────────────────────────────────────────────────────────────
# CHECK — Vérifie que les sources existent avant de symlinkier
# ─────────────────────────────────────────────────────────────────────────────
check:
	$(call log_info,Vérification des fichiers sources…)
	@missing=0; \
	for f in \
		".zshrc_mac" ".zshrc_linux" ".vimrc" ".tmux.conf" \
		"config/htop/htoprc" "config/ghostty/config"; do \
		if [ -e "$(PWD)/$$f" ]; then \
			printf " $(GREEN)✔$(CLR)  %-38s\n" "$$f"; \
		else \
			printf " $(RED)✘$(CLR)  %-38s $(DIM)(manquant)$(CLR)\n" "$$f"; \
			missing=$$((missing+1)); \
		fi; \
	done; \
	if [ $$missing -gt 0 ]; then \
		printf "\n $(YLW)⚠$(CLR)  $$missing fichier(s) manquant(s) dans $(PWD)\n\n"; \
		exit 1; \
	else \
		printf "\n $(GREEN)✔$(CLR)  Tous les fichiers sont présents\n\n"; \
	fi

# ─────────────────────────────────────────────────────────────────────────────
# HOSTNAME — Renomme la machine
#   Interactif    : make hostname
#   Non-interactif: make hostname NAME="mon-pc"
# ─────────────────────────────────────────────────────────────────────────────
hostname:
	@CURRENT=$$(hostname); \
	if [ -n "$(NAME)" ]; then \
		NEW="$(NAME)"; \
	else \
		printf " $(CYAN)➜$(CLR)  Nom actuel  : $$CURRENT\n"; \
		printf " $(CYAN)➜$(CLR)  Nouveau nom : "; \
		read -r NEW; \
	fi; \
	if [ -z "$$NEW" ]; then \
		printf " $(RED)✘$(CLR)  Nom vide — abandon\n"; \
		exit 1; \
	fi; \
	if [ "$$(uname -s)" = "Darwin" ]; then \
		LOCAL=$$(echo "$$NEW" | tr ' ' '-'); \
		sudo scutil --set ComputerName  "$$NEW"; \
		sudo scutil --set HostName      "$$NEW"; \
		sudo scutil --set LocalHostName "$$LOCAL"; \
		printf " $(CYAN)➜$(CLR)  ComputerName  : $$CURRENT → $$NEW\n"; \
		printf " $(CYAN)➜$(CLR)  HostName      : $$CURRENT → $$NEW\n"; \
		printf " $(CYAN)➜$(CLR)  LocalHostName : $$CURRENT → $$LOCAL\n"; \
		printf " $(GREEN)✔$(CLR)  Nom changé — un redémarrage peut être nécessaire\n"; \
	else \
		OLD=$$(cat /etc/hostname | tr -d '[:space:]'); \
		echo "$$NEW" | sudo tee /etc/hostname > /dev/null; \
		sudo sed -i "s/\b$$OLD\b/$$NEW/g" /etc/hosts; \
		sudo hostname "$$NEW"; \
		printf " $(CYAN)➜$(CLR)  /etc/hostname : $$OLD → $$NEW\n"; \
		printf " $(CYAN)➜$(CLR)  /etc/hosts    : $$OLD → $$NEW\n"; \
		printf " $(CYAN)➜$(CLR)  hostname(1)   : appliqué immédiatement\n"; \
		printf " $(GREEN)✔$(CLR)  Nom changé — effectif sans redémarrage\n"; \
	fi
