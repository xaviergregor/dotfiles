SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

cmd:
	sudo apt install -y grc bat zsh htop golang curl vim

	sudo apt update
	sudo apt install -y gpg
	sudo mkdir -p /etc/apt/keyrings
	wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
	echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

	sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
	sudo apt update
	sudo apt install -y eza

	go install github.com/cheat/cheat/cmd/cheat@latest

	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

install:
	#git clone https://github.com/zsh-users/zsh-syntax-highlighting
	#git clone https://github.com/zsh-users/zsh-completions
	#git clone https://github.com/zsh-users/zsh-autosuggestions
	#mv zsh-* ~/.oh-my-zsh/plugins

    if [ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ]; then \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting; \
    else \
        echo "Le plugin zsh-syntax-highlighting est déjà présent dans ~/.oh-my-zsh/plugins."; \
    fi

    if [ ! -d ~/.oh-my-zsh/plugins/zsh-completions ]; then \
        git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions; \
    else \
        echo "Le plugin zsh-completions est déjà présent dans ~/.oh-my-zsh/plugins."; \
    fi

    if [ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then \
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions; \
    else \
        echo "Le plugin zsh-autosuggestions est déjà présent dans ~/.oh-my-zsh/plugins."; \
    fi



	ln -snvf ${PWD}/.zshrc ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	ln -snvf ${PWD}/htoprc ~/.config/htop/htoprc
	sudo ln -snvf /usr/bin/batcat /usr/bin/bat
