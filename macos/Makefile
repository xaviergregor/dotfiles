SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
BREW_INSTALL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

brew:
	bash -c "$$( $(CURL) $(BREW_INSTALL) )"

vim:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tmux:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

shell:
	sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

zsh-plugins:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-completions
	git clone https://github.com/zsh-users/zsh-autosuggestions
	mv zsh-* ~/.oh-my-zsh/plugins

zsh-theme:
	mv dracula.zsh-theme ~/.oh-my-zsh/themes

install:
	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	mkdir -p ${HOME}/.config/htop/
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc
	mkdir -p ${HOME}/work/
	chflags hidden ~/work
	export GOPATH=$HOME/work
