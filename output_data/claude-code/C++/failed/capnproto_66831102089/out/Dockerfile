FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-upgrade --no-install-recommends -y \
    clang-20 libc++-20-dev libc++abi-20-dev libclang-rt-20-dev lld-20 llvm-20 \
    git build-essential python3 ca-certificates curl wget openjdk-21-jdk-headless zip unzip

# Install Bazel (latest LTS release)
RUN mkdir -p /opt/bazel && \
    curl -fsSL https://github.com/bazelbuild/bazel/releases/download/9.0.0/bazel-9.0.0-linux-x86_64 -o /opt/bazel/bazel && \
    chmod +x /opt/bazel/bazel && \
    ln -s /opt/bazel/bazel /usr/local/bin/bazel

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
