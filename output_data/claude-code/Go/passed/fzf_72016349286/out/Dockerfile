FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install --yes \
    git \
    make \
    golang-1.23 \
    ruby-full \
    bundler \
    zsh \
    fish \
    tmux \
    shfmt

ENV PATH=/usr/lib/go-1.23/bin:$PATH

WORKDIR /app
COPY repo/ /app/

RUN gem install bundler && bundle install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
