import os


def with_sudo(code) -> str:
    return "sudo " + code

def run(code):
    os.system(code)
    pass


def run_if(code, sudo=False):
    if sudo: code = with_sudo(code)
    prompt = "\t[yes or no]?"
    print(code)
    print(prompt, end=" ")
    if str.strip(input()) not in ["y", "yes"]:
        print("\rskipped")
        return
    run(code)
    pass


def install_fcitx():
    code = "pacman -S --noconfirm fcitx5 fcitx5-configtool fcitx5-qt fcitx5-gtk fcitx5-pinyin-zhwiki fcitx5-chinese-addons"
    run_if(code, sudo=True)

    env_vars = """
    # auto generated
    GTK_IM_MODULE=fcitx5
    QT_IM_MODULE=fcitx5
    XMODIFIERS=@im=fcitx5
    INPUT_METHOD=fcitx5
    SDL_IM_MODULE=fcitx5
    GLFW_IM_MODULE=ibus
    """.replace(" ","").strip()

    with open("/etc/environment", "wb") as fp:
        content = fp.read()
        with open("/etc/environment_bak", "wb") as fpbak:
            fpbak.write(content)
            pass
        if env_vars not in content:
            content += "\n" + env_vars
            fp.write(content)
            pass
        pass
    pass


def install_base():
    code = "pacman -S --noconfirm base-devel git tig htop tmux gvim telnet"
    run_if(code, sudo=True)
    pass


def install_fonts():
    code = "pacman -S --noconfirm wqy-microhei ttf-hack ttf-hack-nerd ttf-nerd-fonts-symbols"
    run_if(code, sudo=True)
    pass


def install_yay():
    if os.path.isfile("/usr/bin/yay"):
        print("yay is installed")
        return
    dpath = f"/tmp/yay-bin"
    if not os.path.isdir(dpath):
        run(f"git clone https://aur.archlinux.org/yay-bin.git --progress --depth 1 {dpath}")
        pass
    run(f"cd {dpath} && makepkg -si")
    pass


def install_grub():
    code = "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub"
    run_if(code, sudo=True)
    code = "grub-mkconfig -o /boot/grub/grub.cfg"
    run_if(code, sudo=True)
    pass


def main():
    install_base()
    install_yay()
    # install_fcitx()
    # install_fonts()
    install_grub()
    pass

if __name__ == "__main__":
    main()

