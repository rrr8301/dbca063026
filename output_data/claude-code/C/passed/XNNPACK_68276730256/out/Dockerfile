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
    crossbuild-essential-armhf \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/arm-linux-gnueabihf/lib/ld-linux-armhf.so.3 /usr/lib/ld-linux-armhf.so.3
ENV LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib:${LD_LIBRARY_PATH}

RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 18 && \
    rm llvm.sh

RUN wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 && \
    chmod +x /usr/local/bin/bazel

RUN ln -sf /usr/bin/python3 /usr/bin/python

ARG USERNAME=xnnpack
ARG USER_UID=1001
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME
RUN useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN mkdir -p /home/$USERNAME/.cache/bazel
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /home/$USERNAME/.ccache && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ccache

ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV CCACHE_DIR=/home/xnnpack/.ccache

COPY run.sh /run.sh
RUN sudo chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
