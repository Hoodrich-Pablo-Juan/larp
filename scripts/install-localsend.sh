#!/bin/bash
if ! command -v localsend &> /dev/null; then
    git clone https://aur.archlinux.org/localsend-bin.git /tmp/localsend-bin
    cd /tmp/localsend-bin
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/localsend-bin
fi
