FROM maven:3.9-eclipse-temurin-21

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY repo/ /app/

RUN mvn --version && java -version

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
