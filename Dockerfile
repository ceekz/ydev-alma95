# syntax=docker/dockerfile:1

ARG ALMALINUX_VERSION=9.5
FROM almalinux:${ALMALINUX_VERSION}

ARG ALMALINUX_VERSION

LABEL org.opencontainers.image.title="ydev-alma95" \
      org.opencontainers.image.description="AlmaLinux 9.5 CLI development environment modeled after the TUT HPC ydev login server" \
      org.opencontainers.image.source="https://github.com/ceekz/ydev-alma95"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# AlmaLinux 9.5 is an archived point release.  Pin repositories to the
# AlmaLinux vault so rebuilds do not silently move to a later 9.x release.
RUN rm -f /etc/yum.repos.d/*.repo && \
    printf '%s\n' \
      '[baseos]' \
      "name=AlmaLinux ${ALMALINUX_VERSION} - BaseOS" \
      "baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/BaseOS/\$basearch/os/" \
      'enabled=1' \
      'gpgcheck=1' \
      'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9' \
      '' \
      '[appstream]' \
      "name=AlmaLinux ${ALMALINUX_VERSION} - AppStream" \
      "baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/AppStream/\$basearch/os/" \
      'enabled=1' \
      'gpgcheck=1' \
      'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9' \
      '' \
      '[crb]' \
      "name=AlmaLinux ${ALMALINUX_VERSION} - CRB" \
      "baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/CRB/\$basearch/os/" \
      'enabled=1' \
      'gpgcheck=1' \
      'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9' \
      > /etc/yum.repos.d/almalinux-vault.repo && \
    dnf clean all && \
    dnf -y makecache

# The AlmaLinux container image contains reduced variants such as
# coreutils-single and curl-minimal.  Replace them with the regular packages
# to more closely resemble a normal RHEL installation.
RUN dnf -y install --allowerasing \
        coreutils \
        curl

# Basic command-line and development tools.
RUN dnf -y install \
        bash \
        diffutils \
        file \
        findutils \
        gawk \
        grep \
        less \
        sed \
        which \
        hostname \
        iproute \
        procps-ng \
        openssh-clients \
        rsync \
        wget \
        git \
        tar \
        gzip \
        bzip2 \
        xz \
        zip \
        unzip \
        patch \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkgconf-pkg-config \
        vim-enhanced \
        environment-modules \
        glibc-langpack-ja \
        tzdata

# GNU compiler collections:
#   - GCC 11.5 is the default compiler.
#   - GCC Toolset 13 provides GCC 13.3.1 and can be enabled with:
#       source /opt/rh/gcc-toolset-13/enable
RUN dnf -y install \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        glibc-devel \
        libstdc++-devel \
        gcc-toolset-13-gcc \
        gcc-toolset-13-gcc-c++ \
        gcc-toolset-13-gcc-gfortran

# Programming languages.
RUN dnf -y install \
        python3.12 \
        python3.12-devel \
        python3.12-pip \
        perl \
        ruby

# ydev provides `python` as Python 3.12.
RUN ln -sfn /usr/bin/python3.12 /usr/bin/python

# Java development environment.
RUN dnf -y install \
        java-1.8.0-openjdk \
        java-1.8.0-openjdk-devel

# Numerical/development libraries and editor.
RUN dnf -y install \
        eigen3-devel \
        emacs-nox

ENV LANG=ja_JP.UTF-8

# Build-time sanity checks for the versions intentionally reproduced here.
# OpenJDK is checked only for Java 8 compatibility because its update level
# may differ from the TUT ydev host while remaining within the same Java 8 line.
RUN set -eux; \
    test "$(gcc -dumpfullversion -dumpversion)" = "11.5.0"; \
    test "$(/opt/rh/gcc-toolset-13/root/usr/bin/gcc -dumpfullversion -dumpversion)" = "13.3.1"; \
    python --version 2>&1 | grep -qx 'Python 3.12.5'; \
    perl -e 'exit(($] >= 5.032 && $] < 5.033) ? 0 : 1)'; \
    ruby --version | grep -q '^ruby 3\.0\.7'; \
    rpm -q --qf '%{VERSION}\n' eigen3-devel | grep -qx '3.4.0'; \
    java -version 2>&1 | grep -q 'version "1\.8\.0_'; \
    javac -version 2>&1 | grep -q '^javac 1\.8\.0_'; \
    emacs --version | head -1 | grep -qx 'GNU Emacs 27.2'

RUN dnf clean all && \
    rm -rf /var/cache/dnf

WORKDIR /work

CMD ["/bin/bash"]
