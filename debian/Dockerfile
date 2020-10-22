FROM debian:stretch

RUN apt-get update \
 && apt-get install -y zsh git curl

RUN useradd -ms /bin/bash laenzi
WORKDIR /home/laenzi
USER laenzi

