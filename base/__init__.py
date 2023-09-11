def pkg_install(*pkgs):
    cmd = "sudo pacman -S "
    cmd += " ".join(pkgs)
    pass
