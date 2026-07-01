FROM ubuntu:24.04

# Install Java (JDK 21, 25) and Maven
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-25-jdk \
    maven \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME to JDK 21 as default (primary version)
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Create Maven toolchains configuration
RUN mkdir -p ~/.m2 && cat > ~/.m2/toolchains.xml << 'EOF'
<?xml version="1.0" encoding="UTF8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>21</version>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-21-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>25</version>
    </provides>
    <configuration>
      <jdkHome>/usr/lib/jvm/java-25-openjdk-amd64</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
EOF

WORKDIR /workspace

COPY . .

CMD ["bash", "run.sh"]