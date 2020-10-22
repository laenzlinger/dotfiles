FROM debian:stretch

RUN apt-get update \
 && apt-get install -y zsh git curl

RUN useradd -ms /bin/zsh laenzi
WORKDIR /home/laenzi
USER laenzi
RUN touch /home/laenzi/.zshrc
