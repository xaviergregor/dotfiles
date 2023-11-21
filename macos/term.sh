echo "---------------------------------------"
echo "            INSTALLATION macOs           "
echo "---------------------------------------"
echo ""

# installation de Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Cherche mise a jour
brew update

# Applications

echo "Zenmap"
brew install --cask zenmap

echo "Visual Studio Code"
brew install --cask visual-studio-code

echo "VLC"
brew install --cask vlc

echo "Transmission"
brew install --cask transmission

echo "Mactracker"
brew install --cask mactracker

echo "Adapter"
brew install --cask adapter

echo "The Unarchiver"
brew install --cask the-unarchiver

echo "Keka"
brew install --cask keka

echo "Etcher"
brew install --cask balenaetcher

echo "Raspberry Pi imager"
brew install --cask raspberry-pi-imager

echo "AppCleaner"
brew install --cask appcleaner

echo "Rectangle"
brew install --cask rectangle

echo "GoTop"
brew tap cjbassi/gotop
brew install gotop

echo "JDownloader"
brew install --cask jdownloader

echo "Discord"
brew install --cask discord

echo "iTerm2"
brew install --cask iterm2

# Nettoyage

brew cleanup

# Installation des commandes

brew install go
brew install fd
brew install duf
brew install btop
brew install golang
brew install ansiweather
brew install arp-scan
brew install cmatrix
brew install grc
brew install htop
brew install vim
brew install nmap
brew install thefuck
brew install tmux
brew install webkit2png
brew install weechat
brew install wget
brew install tor
brew install lnav
brew install lynis
brew install fcrackzip
brew install iftop
brew install ifstat
brew install imagesnap
brew install nethogs
brew install nload
brew install node
brew install testdisk
brew install pkg-config
brew install librtlsdr
brew install fping
brew install tldr
brew install shellcheck
brew install eza
brew install svn
brew install bat
brew install wego
brew install iproute2mac
brew tap homebrew/cask-fonts
brew install --cask font-droid-sans-mono-nerd-font
brew install font-hack-nerd-font

# Node
sudo npm install -g vtop

#CHEAT
go get -u github.com/cheat/cheat/cmd/cheat



echo "---------------------------------------"
echo "  INSTALLATION ENVIRONNEMENT TERMINAL  "
echo "---------------------------------------"
echo ""

# Personnalisation

mkdir ~/work
chflags hidden ~/work


export GOPATH=$HOME/work

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
cp .tmux.conf ~/
cp .wegorc ~/

