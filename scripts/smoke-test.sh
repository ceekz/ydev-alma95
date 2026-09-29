#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ydev-alma95}"
PLATFORM="${PLATFORM:-linux/amd64}"

docker run --rm --platform "$PLATFORM" "$IMAGE" bash -lc '
set -euo pipefail

echo "== OS =="
cat /etc/almalinux-release

echo "== GCC 11 =="
gcc --version | head -1
g++ --version | head -1
gfortran --version | head -1

cat >/tmp/hello.c <<"SRC"
#include <stdio.h>
int main(void) { puts("hello C"); return 0; }
SRC
gcc /tmp/hello.c -o /tmp/hello-c
/tmp/hello-c

cat >/tmp/hello.cpp <<"SRC"
#include <iostream>
int main() { std::cout << "hello C++" << std::endl; return 0; }
SRC
g++ /tmp/hello.cpp -o /tmp/hello-cpp
/tmp/hello-cpp

cat >/tmp/hello.f90 <<"SRC"
program hello
    print *, "hello Fortran"
end program hello
SRC
gfortran /tmp/hello.f90 -o /tmp/hello-f
/tmp/hello-f

echo "== GCC Toolset 13 =="
source /opt/rh/gcc-toolset-13/enable
gcc --version | head -1
g++ --version | head -1
gfortran --version | head -1

echo "== Languages =="
python --version
perl -e '\''print "$^V\n"'\''
ruby --version
java -version
javac -version

echo "== Libraries / tools =="
rpm -q eigen3-devel
emacs --version | head -1
'
