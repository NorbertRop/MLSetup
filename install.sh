#!/bin/sh

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="MacOS"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    OS="Unsupported"
elif [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    OS="Unsupported"
elif [[ "$OSTYPE" == "win32" ]]; then
    # I'm not sure this can happen.
    OS="Unsupported"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    # ...
    OS="Unsupported"
else
    # Unknown.
    OS="Unsupported"
fi

if [[ $OS == "Unsupported" ]]; then
    echo "Unsupported OS"
fi

DEFAULT_PYTHON=3.10

if [[ $OS == "MacOS" ]]; then
    # MacOS comes with pre-installed zsh

    # install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
    echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >>~/.zshrc

    # install a command-line fuzzy finder
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # install zsh-autoswitch-virtualenv
    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv

    # install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Update oh-my-zsh
    sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i '' 's/plugins=(git)/plugins=(git docker-compose zsh-syntax-highlighting zsh-autosuggestions k z \n\tautoswitch_virtualenv)/' ~/.zshrc

    # install pyenv
    brew install pyenv
    echo '\nalias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"' >>~/.zshrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.zshrc
    echo 'eval "$(pyenv init -)"' >>~/.zshrc

    # install python
    pyenv install $DEFAULT_PYTHON
    pyenv global $DEFAULT_PYTHON

    # install poetry
    curl -sSL https://install.python-poetry.org | python3 -
    echo '\nexport PATH="/Users/norbert/.local/bin:$PATH"' >>~/.zshrc

    source ~/.zshrc

elif [[ $OS == "Linux" ]]; then
    # install zsh
    sudo apt install zsh

    # install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # install zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # install k (Directory listings for zsh with git features)
    git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k

    # install a command-line fuzzy finder
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    # install zsh-autoswitch-virtualenv
    git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" "$ZSH_CUSTOM/plugins/autoswitch_virtualenv"
    
    # install terminal and synapse
    sudo apt update
    sudo apt install guake synapse
    
    # install fonts
    sudo apt-get install fonts-powerline

    # install Powerlevel10k theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    # Update oh-my-zsh
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i 's/plugins=(git)/plugins=(git docker-compose zsh-syntax-highlighting zsh-autosuggestions k z \n\tautoswitch_virtualenv)/' ~/.zshrc

    # install pyenv
    curl https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >>~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>~/.zshrc
    echo 'eval "$(pyenv init -)"' >>~/.zshrc

    # install python
    pyenv install $DEFAULT_PYTHON
    pyenv global $DEFAULT_PYTHON

    # install poetry
    curl -sSL https://install.python-poetry.org | python3 -
    echo '\nexport PATH="/Users/norbert/.local/bin:$PATH"' >>~/.zshrc

    source ~/.zshrc
else
    return 1
fi
