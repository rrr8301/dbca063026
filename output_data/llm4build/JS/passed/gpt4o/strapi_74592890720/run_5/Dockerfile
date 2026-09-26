# Use an official Node.js runtime as a parent image
FROM node:22

# Set the working directory in the container
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package.json yarn.lock ./

# Enable Corepack
RUN corepack enable

# Install dependencies
RUN yarn install

# Copy the rest of the application code into the container
COPY . .

# Build the application
RUN yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run the application
CMD ["yarn", "nx", "serve"]