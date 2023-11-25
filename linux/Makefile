cmd:
	sudo apt install -y exa grc bat git zsh htop
	
cheat:
	go install github.com/cheat/cheat/cmd/cheat@latest

install:
	ln -snvf ${PWD}/zsh/.zshrc ~/.zshrc
	ln -snvf ${PWD}/vim/.vimrc ~/.vimrc
	ln -snvf ${PWD}/tmux/.tmux.conf ~/.tmux.conf
	ln -s /usr/bin/batcat /usr/bin/bat
	
vim-plug:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

tmux-plug:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

omz:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

omz-plug:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-completions
	git clone https://github.com/zsh-users/zsh-autosuggestions
	mv zsh-* ~/.oh-my-zsh/plugins
