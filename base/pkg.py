def install(*pkgs):
    cmd = "sudo pacman -S "
    cmd += " ".join(pkgs)
    pass
