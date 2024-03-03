SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

cmd:
	sudo apt install -y grc bat zsh htop golang curl vim

	sudo apt update
	sudo apt install -y gpg
	sudo mkdir -p /etc/apt/keyrings
#	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
#	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

	if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
  	  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
	else
  	  echo "Le fichier /etc/apt/sources.list.d/gierens.list existe déjà."
	fi


	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	sudo apt update
	sudo apt install -y eza

	go install github.com/cheat/cheat/cmd/cheat@latest

	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	if [ ! -d ~/.tmux/plugins/tpm ]; then
 	   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	else
	    echo "Le dépôt existe déjà dans ~/.tmux/plugins/tpm"
	fi

	sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

install:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-completions
	git clone https://github.com/zsh-users/zsh-autosuggestions
	mv zsh-* ~/.oh-my-zsh/plugins

	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc
	sudo ln -snvf /usr/bin/batcat /usr/bin/bat
