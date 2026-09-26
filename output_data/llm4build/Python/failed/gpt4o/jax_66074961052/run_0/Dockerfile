FROM index.docker.io/library/ubuntu@sha256:4e0171b9275e12d375863f2b3ae9ce00a4c53ddda176bd55868df97ac6f21a6e

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y libssl-dev git curl wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN apt-get update && \
    apt-get install -y python3.14 python3.14-venv python3.14-dev && \
    rm -rf /var/lib/apt/lists/*

RUN python3.14 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install uv~=0.5.30

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]