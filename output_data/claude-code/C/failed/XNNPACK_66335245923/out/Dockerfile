FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common wget gnupg && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update

RUN apt-get install -y \
    sudo \
    build-essential \
    vim \
    git \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    ccache \
    gcc-9 g++-9 \
    gcc-13 g++-13 \
    clang-18 llvm-18 lld-18

RUN rm -rf /var/lib/apt/lists/*

# Install Bazel
RUN wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 && \
    chmod +x /usr/local/bin/bazel

RUN ln -sf /usr/bin/python3 /usr/bin/python

# Create xnnpack user
ARG USERNAME=xnnpack
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN mkdir -p /home/$USERNAME/.cache/bazel
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set environment variables for the build
ENV CC=gcc-9
ENV CXX=g++-9
ENV PATH="/home/$USERNAME/.local/bin:${PATH}"

WORKDIR /app
COPY repo/ /app/

RUN chown -R $USERNAME:$USERNAME /app

COPY run.sh /run.sh
RUN chmod +x /run.sh

USER $USERNAME

ENTRYPOINT ["/run.sh"]
