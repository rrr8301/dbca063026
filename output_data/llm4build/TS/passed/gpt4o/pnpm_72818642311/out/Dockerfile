# Use an official Node.js runtime as a parent image
FROM node:22.13.0

# Set the working directory in the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml to the working directory
COPY package.json pnpm-lock.yaml ./

# Install pnpm
RUN npm install -g pnpm

# Set the registry to the default npm registry
RUN pnpm config set registry https://registry.npmjs.org/

# Install project dependencies
RUN pnpm install --shamefully-hoist || echo "Failed to install dependencies. Please check the package.json and pnpm-lock.yaml."

# Copy the rest of the application code to the working directory
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the application
CMD ["pnpm", "start"]