FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    valgrind \
    libc6-dbg:i386 \
    g++-9 \
    g++-9-multilib \
    python3

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

ENV CMAKE_GENERATOR=Ninja
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV CTEST_PARALLEL_LEVEL=2
ENV ASAN_OPTIONS=strict_string_checks=true:detect_odr_violation=2:detect_stack_use_after_return=true:check_initialization_order=true:strict_init_order=true
ENV TSAN_OPTIONS=force_seq_cst_atomics=1

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
