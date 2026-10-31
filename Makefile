DOTFILES := $(CURDIR)
ZSH_CUSTOM := $(HOME)/.oh-my-zsh/custom

.PHONY: apt dnf brew brew-install shell zsh-plugins vim tmux link prefs-mac

apt:
	sudo apt update
	sudo apt install -y grc bat zsh htop golang curl vim tmux gcc g++ ranger fzf
	-sudo apt install -y eza       # absent de Debian 12
	-. /etc/os-release && [ "$$ID" = ubuntu ] && sudo apt install -y ghostty   # Ubuntu uniquement

dnf:
	sudo dnf install -y grc bat zsh htop golang curl vim-enhanced tmux gcc gcc-c++ ranger fzf eza
	-sudo dnf copr enable -y scottames/ghostty && sudo dnf install -y ghostty   # dépôt COPR non officiel

brew:
	command -v brew || bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew-install:
	PATH="/opt/homebrew/bin:$$PATH" brew bundle --file=Brewfile

shell:
	[ -d ~/.oh-my-zsh ] || RUNZSH=no sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

zsh-plugins:
	for p in zsh-syntax-highlighting zsh-completions zsh-autosuggestions; do \
		[ -d $(ZSH_CUSTOM)/plugins/$$p ] || git clone --depth=1 https://github.com/zsh-users/$$p $(ZSH_CUSTOM)/plugins/$$p; \
	done

vim:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tmux:
	[ -d ~/.tmux/plugins/tpm ] || git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

link:
	mkdir -p ~/.config/htop ~/.config/ghostty
	ln -snvf $(DOTFILES)/.zshrc ~/.zshrc
	ln -snvf $(DOTFILES)/.vimrc ~/.vimrc
	ln -snvf $(DOTFILES)/.tmux.conf ~/.tmux.conf
	ln -snvf $(DOTFILES)/config/htop/htoprc ~/.config/htop/htoprc
	ln -snvf $(DOTFILES)/config/ghostty/config ~/.config/ghostty/config

prefs-mac:
	./scripts/prefs_mac.sh
