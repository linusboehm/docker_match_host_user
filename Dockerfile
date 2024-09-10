FROM alpine:latest

ARG USER_ID
ARG GROUP_ID
ARG USER

RUN yum -y install \
    wget \
    git

ENV GOSU_VERSION 1.17
RUN set -eux; \
  \
  rpmArch="$(rpm --query --queryformat='%{ARCH}' rpm)"; \
  case "$rpmArch" in \
    aarch64) dpkgArch='arm64' ;; \
    armv[67]*) dpkgArch='armhf' ;; \
    i[3456]86) dpkgArch='i386' ;; \
    ppc64le) dpkgArch='ppc64el' ;; \
    riscv64 | s390x) dpkgArch="$rpmArch" ;; \
    x86_64) dpkgArch='amd64' ;; \
    *) echo >&2 "error: unknown/unsupported architecture '$rpmArch'"; exit 1 ;; \
  esac; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  gpgconf --kill all; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu --version; \
  gosu nobody true


# Create a default user (the UID and GID will be changed at runtime)
ARG USERNAME=user
RUN useradd -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /app
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["pwd"]
