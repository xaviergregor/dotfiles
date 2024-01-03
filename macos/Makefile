SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
BREW_INSTALL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

brew-install:
	bash -c "$$( $(CURL) $(BREW_INSTALL) )"

brew-apps:
	brew install --cask visual-studio-code
	brew install --cask vlc
	brew install --cask adapter
	brew install --cask the-unarchiver
	brew install --cask keka
	brew install --cask balenaetcher
	brew install --cask appcleaner
	brew install --cask rectangle
	brew tap cjbassi/gotop
	brew install gotop
	brew install --cask discord
	brew install --cask iterm2
	brew install --cask utm
	brew install --cask handbrake

brew-cmd:
	brew install go
	brew install fd
	brew install duf
	brew install btop
	brew install golang
	brew install arp-scan
	brew install cmatrix
	brew install grc
	brew install htop
	brew install vim
	brew install nmap
	brew install tmux
	brew install weechat
	brew install wget
	brew install tor
	brew install iftop
	brew install nload
	brew install node
	brew install testdisk
	brew install pkg-config
	brew install tldr
	brew install shellcheck
	brew install eza
	brew install bat
	brew install wego
	brew install iproute2mac
	brew tap homebrew/cask-fonts
	brew install --cask font-droid-sans-mono-nerd-font
	brew install font-hack-nerd-font
	
cheat:
	go install github.com/cheat/cheat/cmd/cheat@latest

vim-plug:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tmux-plug:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

omz-install:
	sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

omz-plug:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-completions
	git clone https://github.com/zsh-users/zsh-autosuggestions
	mv zsh-* ~/.oh-my-zsh/plugins

install:
	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc
	mkdir -p ${HOME}/work/
	chflags hidden ~/work
	export GOPATH=$HOME/work
