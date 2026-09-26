FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y \
    locales \
    openjdk-11-jdk \
    mysql-server \
    curl \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Set up UTF-8 locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install Node.js 16 from NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Start MySQL service
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Setup MySQL database and user
RUN service mysql start && \
    sleep 2 && \
    mysql -e 'CREATE DATABASE AmbryRepairRequests;' -uroot -proot && \
    mysql -e 'USE AmbryRepairRequests; SOURCE ./ambry-mysql/src/main/resources/AmbryRepairRequests.ddl;' -uroot -proot && \
    mysql -e "CREATE USER 'travis'@'localhost' IDENTIFIED BY '';" -uroot -proot || true && \
    mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'travis'@'localhost';" -uroot -proot && \
    mysql -e 'FLUSH PRIVILEGES;' -uroot -proot

# Install Azurite
RUN npm install -g azurite

# Copy and set up run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
