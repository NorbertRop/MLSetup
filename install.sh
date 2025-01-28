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
PLUGINS+='plugins=(git docker-compose zsh-syntax-highlighting zsh-autosuggestions k z'
PLUGINS+='\n'
PLUGINS+='\tautoswitch_virtualenv rye)'
ZSHRC_PLUGINS=$(printf '%s\n' "$PLUGINS")

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
    sudo apt install -y zsh eza

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

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

    # curl -sSf https://rye.astral.sh/get | bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.zshrc

    echo "\nalias ls='exa --icons -F -H --group-directories-first --git -1'" >> ~/.zshrc
else
    exit 1
fi
