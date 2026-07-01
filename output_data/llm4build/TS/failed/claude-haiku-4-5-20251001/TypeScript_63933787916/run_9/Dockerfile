FROM node:14-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Make run.sh executable (if it exists)
RUN if [ -f run.sh ]; then chmod +x run.sh; fi

# Run tests
CMD ["npm", "run", "test", "--", "--no-lint", "--bundle=true"]