FROM ghcr.io/jguer/yay-builder:latest

COPY run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /workspace

ENTRYPOINT ["/run.sh"]