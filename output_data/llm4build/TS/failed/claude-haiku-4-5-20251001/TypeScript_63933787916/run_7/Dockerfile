FROM node:14-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code (including run.sh)
COPY . .

# Make run.sh executable
RUN chmod +x run.sh

# Run tests
ENTRYPOINT ["./run.sh"]