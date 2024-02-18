FROM archlinux:latest

RUN pacman -Syu --noconfirm

RUN useradd -ms /bin/zsh laenzi
WORKDIR /home/laenzi
USER laenzi
RUN touch /home/laenzi/.zshrc
