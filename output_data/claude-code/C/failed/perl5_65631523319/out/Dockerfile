FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y libgdbm-dev libdb-dev build-essential git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN git config diff.renameLimit 999999

RUN ./Configure -des -Dusedevel -Duseshrplib -Dusequadmath -Dusecbacktrace -Dusethreads -Dprefix="$HOME/perl-blead" -DDEBUGGING

RUN MALLOC_PERTURB_=254 MALLOC_CHECK_=3 make -j2 test_prep

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
