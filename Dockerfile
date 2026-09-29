# syntax=docker/dockerfile:1

ARG ALMALINUX_VERSION=9.5
FROM almalinux:${ALMALINUX_VERSION}

ARG ALMALINUX_VERSION

LABEL org.opencontainers.image.title="ydev-alma95" \
      org.opencontainers.image.description="AlmaLinux 9.5 CLI development environment modeled after the TUT HPC ydev login server" \
      org.opencontainers.image.source="https://github.com/ceekz/ydev-alma95"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#
# AlmaLinux 9.5 repositories
#
# AlmaLinux 9.5 is an archived point release.  Use the AlmaLinux vault
# explicitly so that package versions do not silently move to a later
# AlmaLinux 9.x release.
#
RUN rm -f /etc/yum.repos.d/*.repo && \
    cat > /etc/yum.repos.d/almalinux-vault.repo <<EOF
[baseos]
name=AlmaLinux ${ALMALINUX_VERSION} - BaseOS
baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/BaseOS/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9

[appstream]
name=AlmaLinux ${ALMALINUX_VERSION} - AppStream
baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/AppStream/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9

[crb]
name=AlmaLinux ${ALMALINUX_VERSION} - CRB
baseurl=https://vault.almalinux.org/${ALMALINUX_VERSION}/CRB/\$basearch/os/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-9
EOF

RUN dnf clean all && \
    dnf -y makecache

#
# The AlmaLinux container image contains reduced variants such as
# coreutils-single and curl-minimal.  Replace them with the regular
# packages to provide an environment closer to a normal RHEL installation.
#
RUN dnf -y install --allowerasing \
        coreutils \
        curl

#
# Basic command-line and development tools
#
RUN dnf -y install \
        bash \
        ca-certificates \
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
        iputils \
        procps-ng \
        psmisc \
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

#
# Development libraries
#
# Debian equivalents:
#
#   libssl-dev     -> openssl-devel
#   zlib1g-dev     -> zlib-devel
#   libexpat1-dev  -> expat-devel
#
RUN dnf -y install \
        openssl-devel \
        zlib-devel \
        expat-devel

#
# Network utilities
#
# Debian dnsutils corresponds roughly to bind-utils, which provides
# commands such as dig, host, and nslookup.
#
RUN dnf -y install \
        bind-utils

#
# GNU compiler collection
#
# GCC 11.5 is the default compiler on ydev.
# GCC Toolset 13 provides GCC 13.3.1 and can be enabled with:
#
#   source /opt/rh/gcc-toolset-13/enable
#
RUN dnf -y install \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        glibc-devel \
        libstdc++-devel \
        gcc-toolset-13-gcc \
        gcc-toolset-13-gcc-c++ \
        gcc-toolset-13-gcc-gfortran

#
# Programming languages
#
RUN dnf -y install \
        python3.12 \
        python3.12-devel \
        python3.12-pip \
        perl \
        ruby

#
# ydev provides /usr/bin/python as Python 3.12.
# Reproduce that interface for scripts using "#!/usr/bin/python".
#
RUN ln -sfn /usr/bin/python3.12 /usr/bin/python

#
# Perl database modules
#
# Debian equivalent:
#
#   libdbd-mysql-perl -> perl-DBD-MySQL
#
RUN dnf -y install \
        perl-DBD-MySQL

#
# Java development environment
#
RUN dnf -y install \
        java-1.8.0-openjdk \
        java-1.8.0-openjdk-devel

#
# Numerical / development libraries
#
RUN dnf -y install \
        eigen3-devel

#
# Editors
#
# emacs-nox provides the command-line Emacs environment without
# pulling the full graphical desktop stack into the base image.
#
RUN dnf -y install \
        emacs-nox

#
# Japanese fonts
#
# This provides Noto Sans CJK fonts for Japanese text.
#
RUN dnf -y install \
        google-noto-sans-cjk-jp-fonts

#
# Locale
#
ENV LANG=ja_JP.UTF-8

#
# Build-time sanity checks
#
# These checks ensure that the major components expected from this image
# are actually installed and usable.
#
# OpenJDK is intentionally checked only for Java 8 compatibility because
# its patch level may differ from the TUT ydev installation.
#
RUN set -eux; \
    \
    test "$(gcc -dumpfullversion -dumpversion)" = "11.5.0"; \
    \
    test "$(/opt/rh/gcc-toolset-13/root/usr/bin/gcc \
        -dumpfullversion -dumpversion)" = "13.3.1"; \
    \
    test "$(/opt/rh/gcc-toolset-13/root/usr/bin/g++ \
        -dumpfullversion -dumpversion)" = "13.3.1"; \
    \
    test "$(/opt/rh/gcc-toolset-13/root/usr/bin/gfortran \
        -dumpfullversion -dumpversion)" = "13.3.1"; \
    \
    python --version 2>&1 | grep -qx 'Python 3.12.5'; \
    \
    perl -e 'exit(($] >= 5.032 && $] < 5.033) ? 0 : 1)'; \
    \
    perl -MDBD::mysql -e 'print "$DBD::mysql::VERSION\n"'; \
    \
    ruby --version | grep -q '^ruby 3\.0\.7'; \
    \
    rpm -q --qf '%{VERSION}\n' eigen3-devel | grep -qx '3.4.0'; \
    \
    java -version 2>&1 | grep -q 'version "1\.8\.0_'; \
    javac -version 2>&1 | grep -q '^javac 1\.8\.0_'; \
    \
    emacs --version | head -1 | grep -qx 'GNU Emacs 27.2'; \
    \
    command -v dig; \
    command -v host; \
    command -v nslookup; \
    command -v ping; \
    command -v pstree; \
    command -v killall; \
    \
    test -s /etc/pki/tls/certs/ca-bundle.crt; \
    \
    rpm -q openssl-devel; \
    rpm -q zlib-devel; \
    rpm -q expat-devel; \
    rpm -q perl-DBD-MySQL; \
    rpm -q google-noto-sans-cjk-jp-fonts

#
# Remove package-manager caches from the final image.
#
RUN dnf clean all && \
    rm -rf /var/cache/dnf

WORKDIR /work

CMD ["/bin/bash"]
