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

# Install dependencies
RUN yarn install --immutable --inline-builds || yarn install --check-files

# Copy the rest of the application code into the container
COPY . .

# Build the application
RUN yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run the application
CMD ["yarn", "nx", "serve"]