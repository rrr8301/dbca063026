# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml to the working directory
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Copy the rest of the application code to the working directory
COPY . .

# Install dependencies
RUN pnpm install --filter ./packages/vuetify...

# Install Playwright Chromium
RUN pnpm exec playwright install chromium

# Ensure run.sh has execute permissions
RUN chmod +x ./run.sh

# Set the entry point to the run.sh script
ENTRYPOINT ["./run.sh"]