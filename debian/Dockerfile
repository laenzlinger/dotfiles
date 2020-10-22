FROM debian:stretch

RUN apt-get update \
 && apt-get install -y zsh git curl neovim

RUN useradd -ms /bin/zsh laenzi \
 && mkdir /home/laenzi/bin

WORKDIR /home/laenzi

USER laenzi

