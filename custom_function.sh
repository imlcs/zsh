#!/bin/bash

##############################################################################
# 回收站功能,替换系统原有的rm命令,
# rl: 显示回收站已有的文件
# ul: 恢复已经被删除并且回收站里面还存在的文件
# cleartrash: 清空回收站
[[ -d "~/.trash" ]] || mkdir -p ~/.trash
alias rm=trash
alias rl='ls ~/.trash/'
alias ul=undelfile

undelfile()
{
    mv -i --backup=t -v ~/.trash/$@ ./
}

trash()
{
    mv -i --backup=t -v $@ ~/.trash/
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
