SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

cmd:
	sudo apt install -y exa grc bat zsh htop
	
cheat:
	go install github.com/cheat/cheat/cmd/cheat@latest

install:
	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	ln -s /usr/bin/batcat /usr/bin/bat
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc

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
