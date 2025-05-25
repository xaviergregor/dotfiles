SHELL := /bin/bash
CURL := curl -fsSL
OHMYZSH_INSTALL := https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
BREW_INSTALL := https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

cmd:
	sudo apt install -y grc bat zsh htop golang curl vim tmux gcc g++ ranger 
	
brew:
	bash -c "$$( $(CURL) $(BREW_INSTALL) )"

vim: 
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	
tmux:
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

yazi:
	git clone https://github.com/dracula/yazi.git ~/.config/yazi/flavors/dracula.yazi

shell:
	sh -c "$$( $(CURL) $(OHMYZSH_INSTALL) )"

zsh-plugins:
	git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

mac:
	ln -snvf ${PWD}/.zshrc_mac ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	mkdir -p ${HOME}/.config/htop/
	ln -snvf ${PWD}/config/htop/htoprc ~/.config/htop/htoprc
	mkdir -p ${HOME}/.config/ghostty/
	ln -snvf ${PWD}/config/ghostty/config ~/.config/ghostty/config
	mkdir -p ${HOME}/.config/skhd
	ln -snvf ${PWD}/config/skhd/skhdrc ~/.config/skhd/skhdrc
	ln -snvf ${PWD}/Brewfile ~/Brewfile
	mkdir -p ${HOME}/.config/yazi
	ln -snvf ${PWD}/config/yazi/theme.toml ~/.config/yazi/theme.toml
	ln -snvf ${PWD}/config/yazi/yazi.toml ~/.config/yazi/yazi.toml
	
linux:
	ln -snvf ${PWD}/.zshrc_linux ~/.zshrc
	ln -snvf ${PWD}/.vimrc ~/.vimrc
	ln -snvf ${PWD}/.tmux.conf ~/.tmux.conf
	mkdir -p ${HOME}/.config/htop/
	ln -snvf ${PWD}/config/htop/htoprc ~/.config/htop/htoprc
	mkdir -p ${HOME}/.config/ghostty/
	ln -snvf ${PWD}/config/ghostty/config ~/.config/ghostty/config
	mkdir -p ${HOME}/.config/yazi
	ln -snvf ${PWD}/config/yazi/theme.toml ~/.config/yazi/theme.toml
	ln -snvf ${PWD}/config/yazi/yazi.toml ~/.config/yazi/yazi.toml
	
