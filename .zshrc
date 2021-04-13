# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

#ZSH_THEME="linuxonly"
ZSH_THEME="amuse"
# ZSH_THEME="powerlevel10k/powerlevel10k"

[[ ! -d $ZSH/themes/powerlevel10k ]] && ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy/mm/dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z)

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local


# vim
export EDITOR=vim

# pyspark 
# @see https://gist.github.com/tommycarpi/f5a67c66a8f2170e263c#link-spark-with-ipython-notebook
export PARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=ipython
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"

# etcd
export ETCDCTL_API=3

# path
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH=/home/cupen/.nimble/bin:$PATH

# aliases
alias visudo="sudo visudo"
alias rm='rm -i'
alias vi='vim'
alias tmux='tmux -2'
alias docker='sudo docker'
alias xclip='xclip -selection clipboard'
alias grep='grep --color'


# bind key
bindkey '[1~'   beginning-of-line  # Linux console
bindkey '[H'    beginning-of-line  # xterm
bindkey 'OH'    beginning-of-line  # gnome-terminal
bindkey '[2~'   overwrite-mode     # Linux console, xterm, gnome-terminal
bindkey '[3~'   delete-char        # Linux console, xterm, gnome-terminal
bindkey '[4~'   end-of-line        # Linux console
bindkey '[F'    end-of-line        # xterm
bindkey 'OF'    end-of-line        # gnome-terminal

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
