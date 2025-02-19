FROM ghcr.io/linuxserver/baseimage-kasmvnc:kali

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Kali Linux"

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
     curl \
     dnsutils \
     emacs \
     iputils-ping \
     netcat-openbsd \
     nmap \
     openssh-client \
     openssl \
     ssh \
     unzip \
     wget \
     smbclient \
     traceroute \
     wget \
  && apt-get --purge remove -y .\*-doc$ \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
