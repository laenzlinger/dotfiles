FROM debian:buster

RUN apt-get update \
 && apt-get install -y git curl tmux zsh zsh-syntax-highlighting zsh-autosuggestions

RUN useradd -ms /bin/zsh laenzi
WORKDIR /home/laenzi
USER laenzi
RUN touch /home/laenzi/.zshrc
