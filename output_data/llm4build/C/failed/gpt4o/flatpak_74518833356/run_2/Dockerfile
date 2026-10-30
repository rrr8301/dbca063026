FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    libglib2.0-dev attr gettext bison dbus gtk-doc-tools \
    libfuse3-dev ostree libostree-dev libarchive-dev libzstd-dev libcap-dev libattr1-dev libdw-dev libelf-dev python3-pyparsing \
    libjson-glib-dev shared-mime-info desktop-file-utils libpolkit-agent-1-dev libpolkit-gobject-1-dev \
    libseccomp-dev libcurl4-openssl-dev libsystemd-dev libxml2-utils libgpgme11-dev gobject-introspection \
    libgirepository1.0-dev libappstream-dev libdconf-dev clang socat meson libdbus-1-dev e2fslibs-dev bubblewrap xdg-dbus-proxy \
    meson ninja-build libyaml-dev libstemmer-dev gperf itstool libmalcontent-0-dev libxau-dev libgdk-pixbuf2.0-dev openssl libc6-dev \
    git fuse3 policykit-1

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]