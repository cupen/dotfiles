#!/bin/bash
source ./base/*.sh
# source ./archlinux/*.sh

home_dir=$HOME
work_dir=`pwd`

##
#
# $1 directory of repo
# $2 branch of repo
##
git_repo_update() {
    info "Trying to update git repo: $1"
    
    dir=$1
    branch=$2
    # git branch --no-color 2> /dev/null
    if [ ! -d "$dir/.git" ]; then
        error $dir' is not a valid git repo.'
    fi
    
    cd $dir &&
    git pull --progress origin $branch || error "git returned "$?
}

git_repo_clone(){
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
git_repo() {
    url=${1?"Missing a paramer:url"}
    dir=${2=""}
    branch=$3

    if [ -d $dir ]; then
        git_repo_update $dir $branch
        return 1
    else
        git_repo_clone $url $dir $branch
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
    backup_and_makelink $work_dir/.bashrc $home_dir/.bashrc
}

setup_vim(){
    local plug_src=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    mkdir -p  ~/.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $plug_src
    
    backup_and_makelink $work_dir/.gvimrc  $home_dir/.gvimrc
    backup_and_makelink $work_dir/.vimrc   $home_dir/.vimrc
    vim -c PlugInstall
    require python3
    python3 -m pip install -U python-language-server
}

setup_vscode(){
    # local vscode_dir="$home_dir/.config/Code - OSS"
    local vscode_dir="$home_dir/.config/Code"
    mkdir -p $vscode_dir
    backup_and_makelink $work_dir/vscode/keybindings.json  $vscode_dir/User/keybindings.json
    backup_and_makelink $work_dir/vscode/settings.json     $vscode_dir/User/settings.json
    # code --install-extention vscodevim.vim
    # code --install-extention golang.go
    # code --install-extention ms-vscode.cpptools
}

setup_nvim(){
    local plug_src=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    mkdir -p  ~/.vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $plug_src
    
    local config_dir=$home_dir/.config
    mkdir -p  $config_dir
    link_dir $work_dir/config/nvim $config_dir/nvim
}

# setup_vundle(){
#    mkdir -p $home_dir/.vim/bundle
#    git_repo git://github.com/gmarik/vundle.git $home_dir/.vim/bundle/Vundle.vim
# }

setup_zsh(){
    require zsh
    git_repo https://github.com/ohmyzsh/ohmyzsh.git $home_dir/.ohmyzsh
    if [ $? -eq 0 ]; then
        cp $home_dir/.ohmyzsh/templates/zshrc.zsh-template $home_dir/.zshrc
    fi
    chsh -s /bin/zsh
    backup_and_makelink $work_dir/.zshrc              $home_dir/.zshrc
    # git_repo https://github.com/romkatv/powerlevel10k.git  $home_dir/.oh-my-zsh/custom/themes/powerlevel10k
}

setup_tmux(){
    backup_and_makelink $work_dir/.tmux.conf              $home_dir/.tmux.conf
}

setup_archlinux(){
    git_repo git://github.com/helmuthdu/aui.git $home_dir/.aui
    info "see \"cd $home_dir/.aui\""
}

setup_goagent(){
    git_repo git://github.com/goagent/goagent.git  $home_dir/goagent
}

setup_python(){
    require python
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
}

setup_starship(){
    mkdir -p $home_dir/.config
    backup_and_makelink $work_dir/starship.toml            $home_dir/.config/starship.toml
}

setup_git(){
    git config --global user.name      cupen
    git config --global user.email     xcupen@gmail.com
    git config --global push.default   current
    git config --global core.autocrlf  input
    git config --global alias.ss  status
    git config --global alias.ci  commit
    git config --global alias.ls  log --stat
    git config --global alias.update "pull --rebase --autostash"
}

setup_fonts(){
    require mkfontscale
    require mkfontdir
    require sudo
    git_repo git@github.com:Lokaltog/powerline-fonts.git $home_dir/.fonts

    localDir="/usr/share/fonts/TTF/powerline"
    sudo mkdir -p $localDir
    sudo cp -r ~/.fonts/* $localDir
    sudo fc-cache -vf $localDir
    sudo mkfontscale $localDir
    sudo mkfontdir $localDir

    wget -q https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p $home_dir/.config/fontconfig/conf.d/
    mv 10-powerline-symbols.conf $home_dir/.config/fontconfig/conf.d/
}

setup_conky(){
    backup_and_makelink $work_dir/.conkyrc $home_dir/.conkyrc
}

setup_delta(){
    backup_file $home_dir/.gitconfig
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global merge.conflictStyle zdiff3

    git config --global delta.navigate true
    git config --global delta.dark true
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    git config --global delta.wrap-max-lines 1024
}

setup_docker(){
    echo "starting docker"
    sudo systemctl start  docker
    sudo systemctl enable docker
    newgrp docker
    echo "started docker"
    docker info
}

show_menu(){
    echo "==========================="
    let index=0
    for item in ${menuItems[@]}; do
        echo $index": Run "$item
        let index++
    done
    echo "a: All"
    echo "q: Quit"
    echo "==========================="

}

choices_menu(){
    let isContinue=1
    while (( isContinue )); do
        clear
        show_menu
        echo "Choice one or more like \"1 3 5 7 9\""
        echo "NOTE: q is quit"
        echo -e "> \c"
        read choices
        for choice in $choices; do
            case "$choice" in
            'all')
                echo "All!!!"
                for item in ${menuItems[@]}; do
                    echo "Running "$item
                    $item
                done
                echo ========= FINISHED ===========
                ;;

            'q')
                echo "Quit"
                let isContinue=0
                exit 0
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
                ;;
            esac
            read
        done
    done
}

check_requires() {
    bash check.sh
}

require() {
    type $1 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        echo "$2 install '$1' first."
        exit 1
    fi
}

main(){
    declare -a menuItems=(
        check_requires
        setup_zsh
        setup_starship
        setup_vim
        setup_tmux
        setup_git
        setup_vscode
        setup_nvim
        setup_bash
        setup_archlinux
        setup_goagent
        setup_fonts
        setup_delta
	setup_docker
    )
    choices_menu $menuItems
}

require bash
require curl
require git
require delta
main
