# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
[[ -s ~/.autojump/etc/profile.d/autojump.sh  ]] && . ~/.autojump/etc/profile.d/autojump.sh
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="ys"
eval "$(thefuck --alias)"
alias f=fuck
##############################################################################
# rl: 显示回收站已有的文件
# ul: 恢复已经被删除并且回收站里面还存在的文件
# cleartrash: 清空回收站
[[ -d "~/.trash" ]] || mkdir -p ~/.trash
alias rm=trash
alias rl='ls ~/.trash/'
alias ul=undelfile

undelfile()
{
    mv --backup=t -v -i ~/.trash/$@ ./
}

trash()
{
    mv --backup=t -v -i $@ ~/.trash/
}

bashclear()
{
    read -p "clear sure?[Y/n]" confirm
    [ $confirm == 'y' ] || [ $confirm == 'Y' ] && /bin/rm -rf ~/.trash/*
}
zshclear()
{
    read "confirm?clear sure?[Y/n]"
    if [[ "$confirm" =~ ^[Yy]$ ]]
    then
        /bin/rm -rf ~/.trash/*
    fi
}

##############################################################################
# 文件快速备份命令, 备份格式 xxx_2019-02-20_09:58:32
function backup() {
    cp -a  $1 $1_$(\date "+%F_%T")
}

##############################################################################

# 消除 history 命令的行号, 默认显示最后5条命令, 显示多条命令的用法: nh 100
function nh() {
    if [[ -z $1 ]];then
        num=5
    else
        num=$1
    fi
    \history | sed 's/^[ ]*[0-9]\+[ ]*//' | tail -n $num
}

#############################################################################
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
stty -ixon
export HISTTIMEFORMAT="%Y%m%d-%H%M%S: "
alias pssh="pssh -P -h /usr/src/host"
alias pscp="pscp  -h /usr/src/host"
alias vi=vim
alias scl=systemctl
alias py=python
alias py3=python3
alias ls='ls --time-style=long-iso --color=auto'
alias cp="cp --backup=t -av"
alias mv="mv --backup=t -v"
alias pwd="pwd -P"
alias tree="tree -CF"
alias grep='egrep -i --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias mkdir="mkdir -pv"
alias du="du -h"
alias ipy="ipython"
alias c="clear"
alias sst="ss -anptl | column -t"
alias ssu="ss -anupl | column -t"
alias taf="tail -f"
alias dc="docker-compose"
alias dce="docker-compose exec"
alias dcd="docker-compose down"
alias dcu="docker-compose up -d"
alias mount='mount |column -t'
alias h='history' 
alias ping='ping -c 4 -i.2'
alias wget="wget -c"
alias iptlist="iptables -L -n --line-number | column -t"
alias iptin="iptables -L INPUT -n --line-number | column -t"
alias iptout="iptables -L OUPUT -n --line-number | column -t"
alias iptfw="iptables -L FORWARD -n --line-number | column -t"
alias ipe='curl ipinfo.io/ip'
alias addr="ip -4 addr"
alias www='python -m SimpleHTTPServer 8000'
alias untar='tar -xf'
alias df='df -h | egrep -v "tmpfs|overlay2|containers" | column -t'
alias stl='supervisorctl'
alias makemigrations="python3.6 manage.py makemigrations"
alias migrate="python3.6 manage.py migrate"
#################################################################
# kubernetes 命令别名
alias k="kubectl"
alias nodes="kubectl get nodes -o wide"
alias allpods="kubectl get pods --all-namespaces -o wide"
alias pods="kubectl get pods -o wide "
alias kds="kubectl describe "
alias rss="kubectl get rs -o wide "
alias dss="kubectl get ds -o wide "
alias sas="kubectl get sa -o wide "
alias roles="kubectl get roles -o wide"
alias nss="kubectl get ns -o wide"
alias pvs="kubectl get pv -o wide "
alias pvcs="kubectl get pvc -o wide"
alias svcs="kubectl get svc -o wide "
alias cms="kubectl get cm -o wide "
alias sts="kubectl get sts -o wide "
alias kexec="kubectl exec -it "
alias kde="kubectl delete"
alias ked="kubectl edit "
alias klo="kubectl logs "
alias kplain="kubectl explain "
alias kce="kubectl create "
alias kapply="kubectl apply"
alias dps="kubectl get deploy -o wide "
alias scs="kubectl get secrets "
alias kslo="kubectl logs --since=3s "
alias certs="kubectl get certificate "
alias crds="kubectl get crd"
alias igs="kubectl get ingress "
alias gts="kubectl get Gateways"
alias dts="kubectl get DestinationRules"
alias vss="kubectl get VirtualServices"
alias eps="kubectl get endpoints"
#################################################################

alias y=ydcv
alias ddu="ls -F | grep '/$' | xargs -i du -s {} | sort -rn | cut -f2 | xargs -i du -sh {}"
alias fdu="ls -F | grep -v '/$' | xargs -i du -s {} | sort -rn | cut -f2 | xargs -i du -sh {}"
source <(kubectl completion zsh)
