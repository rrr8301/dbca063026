FROM ghcr.io/jguer/yay-builder:latest

WORKDIR /workspace

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]