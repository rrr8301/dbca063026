# Use an official Node.js runtime as a parent image
FROM node:22

# Set the working directory in the container
WORKDIR /app

# Copy package.json and yarn.lock into the container at /app
COPY package.json yarn.lock ./

# Enable Corepack
RUN corepack enable

# Set the Yarn version explicitly if needed
RUN corepack prepare yarn@4.12.0 --activate

# Create a .yarnrc.yml file to set the registry
RUN echo "npmRegistryServer: 'https://registry.yarnpkg.com'" > .yarnrc.yml

# Clear Yarn cache to avoid potential issues with corrupted caches
RUN yarn cache clean

# Install dependencies
# Adding --network-timeout to handle potential network issues
RUN yarn install --network-timeout 100000 || (yarn cache clean && yarn install --network-timeout 100000)

# Copy the rest of the application code into the container
COPY . .

# Build the application
RUN yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run the application
CMD ["yarn", "nx", "serve"]