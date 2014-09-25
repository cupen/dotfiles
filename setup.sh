#!/bin/bash
source ./base/*.sh
# source ./archlinux/*.sh

home=$HOME

##
#
# $1 directory of repo
# $2 branch of repo
##
upgrade_git_repo() {
    info "Trying to update git repo: $1"
    
    dir=$1
    branch=$2
    # git branch --no-color 2> /dev/null
    if [ ! -d $dir"/.git" ]; then
        error $dir' was not a valid git repo.'
    fi
    
    cd $dir &&
    git pull --progress origin $branch || error "git returned "$?
}

clone_git_repo(){
    info "Trying to clone git repo: $1"

    url=${1?"Missing a paramer:url"}
    dir=${2=""}
    branch=$3
    if [ ${#branch} -gt 0 ]; then
        git clone --progress --depth=1 -b $branch $url $dir || error "git clone returned "$?
    else
        git clone --progress --depth=1 --single-branch $url $dir || error "git clone returned "$?
    fi
}

##
#
# $1 url of repo
# $2 directory of repo
# $3 git branch
##
setup_git_repo() {
    url=${1?"Missing a paramer:url"}
    dir=${2=""}
    branch=$3

    if [ -d $dir ]; then
        upgrade_git_repo $dir $branch
        return 1
    else
        clone_git_repo $url $dir $branch
        return 0
    fi
}

backup_file(){
    if [ -f $a ]; then
        dir=`dirname $1`/.backup
        mkdir -p $dir
        filename=`basename $1`
        cp -av $1 $dir/$filename"."`date +"%Y%m%d_%H%M%S"`
    fi
}

backup_file_and_makelink(){
    backup_file $2
    ln -fv $1 $2
}

setup_bash() {
    check_command_exists bash
    backup_file_and_makelink ./.bashrc $home/.bashrc
}

setup_vim(){
    setup_git_repo git://github.com/spf13/spf13-vim.git $home/.spf13-vim-3 "3.0"
    if [ $? -eq 0 ]; then
        # bash $home/.spf13/bootstrap.sh
        backup_file_and_makelink ./.gvimrc        $home/.gvimrc
        backup_file_and_makelink ./.vimrc.local   $home/.vimrc.local
        backup_file_and_makelink ./.vimrc.bundles.local $home/.vimrc.bundles.local
    fi
}

# setup_vundle(){
#    mkdir -p $home/.vim/bundle
#    setup_git_repo git://github.com/gmarik/vundle.git $home/.vim/bundle/Vundle.vim
# }

setup_zsh(){
    check_command_exists zsh
    setup_git_repo git://github.com/robbyrussell/oh-my-zsh.git $home/.oh-my-zsh
    if [ $? -eq 0 ]; then
        cp $home/.oh-my-zsh/templates/zshrc.zsh-template $home/.zshrc
    fi
    # chsh -s /bin/zsh
}

setup_archlinux(){
    setup_git_repo git://github.com/helmuthdu/aui.git $home/.aui
    info "see \"cd $home/.aui\""
}

setup_goagent(){
    setup_git_repo git://github.com/goagent/goagent.git  $home/goagent
}

setup_python(){
    check_command_exists python
}

setup_git(){
    check_command_exists git
    git config --global user.name       cupen
    git config --global user.email      cupen@foxmail.com
    git config --global push.default    current
}

setup_conky(){
    backup_file_and_makelink ./.conkyrc $home/.conkyrc
}

show_menu () {
    echo "==========================="
    let menuItems=$1
    let index=0
    for item in ${menuItems[@]}; do
        echo $index". Run "$item
        let index++
    done
    echo "a. All"
    echo "q. Quit"
    echo "==========================="

}

choices_menu(){
    local $menuItems=$1
    let isContinue=1
    while (( isContinue )); do
        clear
        show_menu menuItems
        echo "You can choice one or more like \"1 3 5 7 9\""
        read choices
        for choice in $choices ; do
            case "$choice" in
            'a')
                echo "All!!!"
                for item in ${menuItems[@]}; do
                    echo "Running "$item
                    $item
                done
                echo ========= FINISHED ===========
                read
                ;;

            'q')
                echo "Quit!!!"
                let isContinue=0
                ;;

            *)
                declare cmd=${menuItems[$choice]}
                # echo "choice="$choice " | cmd="$cmd
                if [ ${#cmd} -eq 0 ]; then
                    echo "Invalid choice :"$choice
                else
                    echo "Choiced "$choice
                    $cmd
                fi
                echo ========= FINISHED ===========
                read
                ;;
            esac
        done
    done
}

main(){
    declare -a menuItems=(
        setup_git
        setup_vim
        setup_bash
        setup_archlinux
        setup_goagent
        setup_zsh
    )
    choices_menu menuItems
}

main
