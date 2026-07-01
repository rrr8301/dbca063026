FROM registry.opensuse.org/home/mia/images/images/mpv-ci:stable-deps

ENV CC=gcc
ENV CXX=g++
ENV CFLAGS="-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3"

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
