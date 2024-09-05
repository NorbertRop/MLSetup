#!/bin/bash

os_type=$(uname)

case "$os_type" in
    Linux*)
        echo "Linux detected"
        OS="Linux"
        ;;
    Darwin*)
        echo "macOS detected"
        OS="MacOS"
        ;;
    *)
        echo "Unsupported OS"
        OS="Unsupported"
        ;;
esac

if [ "$OS" = "Unsupported" ]; then
    echo "Unsupported OS"
fi

PLUGINS=''
PLUGINS+='export PYENV_ROOT="$HOME\/\.pyenv"'
PLUGINS+='\n'
PLUGINS+='command -v pyenv >\/dev\/null || export PATH="$PYENV_ROOT\/bin:$PATH"'
PLUGINS+='\n'
PLUGINS+='eval "$(pyenv init -)"'
PLUGINS+='\n'
PLUGINS+='plugins=(git docker-compose zsh-syntax-highlighting zsh-autosuggestions k z'
PLUGINS+='\n'
PLUGINS+='\tautoswitch_virtualenv)'
ZSHRC_PLUGINS=$(printf '%s\n' "$PLUGINS")

DEFAULT_PYTHON=3.11
: ${IS_SERVER:=1}

if [ "$OS" = "MacOS" ]; then
    # MacOS comes with pre-installed zsh

    # install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/norbertropiak/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew update

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # install k (Directory listings for zsh with git features)
    brew install coreutils
    git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k
    echo '\n# Set PATH for coreutils.' >>~/.zshrc
    echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.zshrc

    # install a command-line fuzzy finder
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # install zsh-autoswitch-virtualenv
    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv

    # install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Update oh-my-zsh
    sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i '' "s/plugins=(git)/${ZSHRC_PLUGINS}/" ~/.zshrc

    # install pyenv
    brew install pyenv
    echo '\nalias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"' >>~/.zshrc
    
    brew install openssl readline sqlite3 xz zlib tcl-tk

    # install python
    pyenv install $DEFAULT_PYTHON
    pyenv global $DEFAULT_PYTHON

    # install poetry
    curl -sSL https://install.python-poetry.org | python3 -
    echo '\nexport PATH="/Users/norbert/.local/bin:$PATH"' >>~/.zshrc

    source ~/.zshrc

elif [ "$OS" == "Linux" ]; then
    sudo apt update
    # install zsh
    sudo apt install zsh

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # install k (Directory listings for zsh with git features)
    git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k

    # install a command-line fuzzy finder
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # install zsh-autoswitch-virtualenv
    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv
    
    # install terminal and synapse
    if [[ $IS_SERVER == 0 ]]; then
        sudo apt install guake synapse
    fi
    
    # install fonts
    sudo apt-get install fonts-powerline

    # install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Update oh-my-zsh
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i "s/plugins=(git)/${ZSHRC_PLUGINS}/" ~/.zshrc

    # install pyenv
    curl https://pyenv.run | bash

    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

    sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    # install python
    pyenv install $DEFAULT_PYTHON
    pyenv global $DEFAULT_PYTHON

    # install poetry
    curl -sSL https://install.python-poetry.org | python3 -
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
else
    exit 1
fi
