SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

cmd:
	sudo apt install -y grc bat zsh htop golang curl vim tmux gcc g++ ranger

	sudo apt update
	sudo apt install -y gpg
	sudo mkdir -p /etc/apt/keyrings
	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	sudo apt update
	sudo apt install -y eza

	
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

install:
	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	mkdir -p ${HOME}/.config/htop/
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc
	sudo ln -snvf /usr/bin/batcat /usr/bin/bat
	
