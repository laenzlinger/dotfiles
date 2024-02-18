FROM archlinux:latest

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm zsh git chezmoi sudo

RUN echo "laenzi   ALL=(ALL) ALL" >> /etc/sudoers

RUN useradd -ms /bin/zsh laenzi
RUN echo "laenzi:pass" | chpasswd
WORKDIR /home/laenzi
USER laenzi
RUN touch /home/laenzi/.zshrc
