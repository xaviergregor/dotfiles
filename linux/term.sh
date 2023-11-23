## Commands installation
sudo apt-get install exa -y
sudo apt-get install grc -y
sudo apt-get install bat -y
sudo apt install git -y
sudo apt install zsh -y

## Lien batcat bat
ln -s /usr/bin/batcat /usr/bin/bat

#Vim-Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

#Tmux Plugins Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


#Oh My ZSH!
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Themes et Plugins ZSH
git clone https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions

mv zsh-* ~/.oh-my-zsh/plugins

cp .vimrc ~/
cp .zshrc ~/
