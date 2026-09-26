FROM node:22

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata git curl wget && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

WORKDIR /workspace

COPY . /workspace
RUN git config --global --add safe.directory '*'

RUN npm install -g pnpm

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/usr/local/bin/run.sh"]