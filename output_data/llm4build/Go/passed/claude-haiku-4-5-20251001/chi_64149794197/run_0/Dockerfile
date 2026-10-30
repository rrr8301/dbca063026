FROM golang:1.23-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apk add --no-cache \
    git \
    make \
    bash \
    ca-certificates

# Set GOPATH
ENV GOPATH=/workspace
ENV PATH=$GOPATH/bin:$PATH

# Create workspace directory structure
RUN mkdir -p $GOPATH/src/github.com/go-chi/chi

# Set working directory
WORKDIR $GOPATH/src/github.com/go-chi/chi

# Copy repository code
COPY . .

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]