#!/bin/bash
source ./base/*.sh
# source ./archlinux/*.sh

home=$HOME
curdir=`pwd`

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

    echo 1

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
    if [ -f $1 ]; then
        dir=`dirname $1`/.backup
        mkdir -p $dir
        filename=`basename $1`
        cp -av $1 $dir/$filename"."`date +"%Y%m%d_%H%M%S"`
    fi
}

backup_and_makelink(){
    backup_file $2
    ln -sfv $1 $2
}

link_dir(){
    echo "link dir: $1 -> $2"
    ln -s $1 $2
}

link_file(){
    echo "link file: $1 -> $2"
    ln -sfv $1 $2
}

setup_bash() {
    backup_and_makelink $curdir/.bashrc $home/.bashrc
}

setup_vim(){
    local plug_src=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    mkdir -p  ~/.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $plug_src
    
    backup_and_makelink $curdir/.gvimrc  $home/.gvimrc
    backup_and_makelink $curdir/.vimrc   $home/.vimrc
    pip3 install -U python-language-server
}

setup_vscode(){
    local vscode_dir="$home/.config/Code - OSS/User/"
    mkdir -p $vscode_dir
    backup_and_makelink $curdir/vscode/keybindings.json  $vscode_dir/keybindings.json
    backup_and_makelink $curdir/vscode/settings.json     $vscode_dir/settings.json
    # code --install-extention vscodevim.vim
    # code --install-extention golang.go
    # code --install-extention ms-vscode.cpptools
}

setup_nvim(){
    local plug_src=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    mkdir -p  ~/.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $plug_src
    
    local config_dir=$home/.config
    mkdir -p  $config_dir
    link_dir $curdir/config/nvim $config_dir/nvim
}

# setup_vundle(){
#    mkdir -p $home/.vim/bundle
#    setup_git_repo git://github.com/gmarik/vundle.git $home/.vim/bundle/Vundle.vim
# }

setup_zsh(){
    require_cmd zsh
    setup_git_repo git://github.com/ohmyzsh/ohmyzsh/.git $home/.oh-my-zsh
    if [ $? -eq 0 ]; then
        cp $home/.oh-my-zsh/templates/zshrc.zsh-template $home/.zshrc
    fi
    chsh -s /bin/zsh
    backup_and_makelink $curdir/.zshrc              $home/.zshrc
}

setup_archlinux(){
    setup_git_repo git://github.com/helmuthdu/aui.git $home/.aui
    info "see \"cd $home/.aui\""
}

setup_goagent(){
    setup_git_repo git://github.com/goagent/goagent.git  $home/goagent
}

setup_python(){
    require_cmd python
}

setup_git(){
    git config --global user.name       cupen
    git config --global user.email      xcupen@gmail.com
    git config --global push.default    current
}

setup_fonts(){
    require_cmd mkfontscale
    require_cmd mkfontdir
    require_cmd sudo
    setup_git_repo git@github.com:Lokaltog/powerline-fonts.git $home/.fonts

    localDir="/usr/share/fonts/TTF/powerline"
    sudo mkdir -p $localDir
    sudo cp -r ~/.fonts/* $localDir
    sudo fc-cache -vf $localDir
    sudo mkfontscale $localDir
    sudo mkfontdir $localDir

    wget -q https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p $home/.config/fontconfig/conf.d/
    mv 10-powerline-symbols.conf $home/.config/fontconfig/conf.d/
}

setup_conky(){
    backup_and_makelink $curdir/.conkyrc $home/.conkyrc
}

show_menu(){
    echo "==========================="
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
    let isContinue=1
    while (( isContinue )); do
        clear
        show_menu
        echo "You can choice one or more like \"1 3 5 7 9\""
        read choices
        for choice in $choices; do
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

check_requires() {
    bash check.sh
}



main(){
    declare -a menuItems=(
        check_requires
        setup_git
        setup_vim
        setup_vscode
        setup_nvim
        setup_bash
        setup_archlinux
        setup_goagent
        setup_zsh
        setup_fonts
    )
    choices_menu $menuItems
}

require bash
require curl
require git
main
