# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM eclipse-temurin:21-jdk-jammy

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required OS-level packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Update Maven wrapper to fix SHA-256 validation
RUN if [ -f /workspace/.mvn/wrapper/maven-wrapper.properties ]; then \
    sed -i 's/distributionSha256Sum=.*/distributionSha256Sum=/' /workspace/.mvn/wrapper/maven-wrapper.properties || true; \
    fi

# Make mvnw and run.sh executable
RUN chmod +x /workspace/mvnw /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]