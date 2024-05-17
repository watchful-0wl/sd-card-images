FROM public.ecr.aws/ubuntu/ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# Need Devuan's debootstrap, which also supports Debian and Ubuntu.
# Use Ubuntu's gpg to get Devuan's signing key.
RUN apt-get update && apt-get install -y gpg

# Add Devuan's signing key.
ARG RELEASE_KEY="94532124541922FB" # ceres key - https://www.devuan.org/os/keyring
RUN echo "Adding Devuan ceres signing key (https://www.devuan.org/os/keyring):" ${RELEASE_KEY}
RUN gpg --keyserver keyring.devuan.org --recv-keys ${RELEASE_KEY} && \
    gpg --export ${RELEASE_KEY} >/etc/apt/trusted.gpg.d/devuan_key.gpg

# Get Devuan's debootstrap.
RUN echo 'deb http://deb.devuan.org/merged ceres main ' > /etc/apt/sources.list.d/devuan.list
RUN apt-get update && \
    apt-get --assume-yes \
            --no-install-recommends \
            install -t ceres debootstrap

# Install everything else but debootstrap from Ubuntu.
RUN apt-get update && \
    apt-get --assume-yes \
            --no-install-recommends \
            install -t noble \
                    debian-archive-keyring \
                    ca-certificates \
                    qemu-user \
                    qemu-user-static \
                    qemu-system-arm \
                    qemu-system-x86 \
                    device-tree-compiler \
                    gcc \
                    gcc-arm-none-eabi \
                    make \
                    git \
                    bc \
                    bzip2 \
                    pigz \
                    bison \
                    flex \
                    python3-dev \
                    python3-pkg-resources \
                    python3-pyelftools \
                    python3-setuptools \
                    swig \
                    parted \
                    e2fsprogs \
                    dosfstools \
                    mtools \
                    pwgen \
                    libssl-dev \
                    libgnutls28-dev \
                    uuid-dev \
                    parallel \
                    ssh \
                    sshpass \
                    unzip && \
    ([ "$(uname -m)" = "aarch64" ] && \
     apt-get --assume-yes \
             install gcc-arm-linux-gnueabihf \
                     gcc-i686-linux-gnu \
                     gcc-x86-64-linux-gnu || :) && \
    ([ "$(uname -m)" = "x86_64" ] && \
     apt-get --assume-yes \
             install gcc-arm-linux-gnueabihf \
                     gcc-aarch64-linux-gnu \
                     gcc-i686-linux-gnu || :) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /var/log/*.log
RUN wget -q "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -O "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws
ENV PATH="/debimg/scripts:${PATH}"
COPY . /debimg
WORKDIR /debimg
