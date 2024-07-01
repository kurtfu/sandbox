FROM ubuntu:24.04

RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            build-essential \
            ca-certificates \
            clangd \
            clang-format \
            clang-tidy \
            cmake \
            cppcheck \
            curl \
            doxygen \
            gdb \
            git \
            graphviz \
            iwyu \
            lcov \
            llvm \
            ninja-build \
            pkg-config \
            python3 \
            tar \
            unzip \
            valgrind \
            zip \
        ; \
        rm -rf /var/lib/apt/lists/*

ENV VCPKG_FORCE_SYSTEM_BINARIES="1"
ENV VCPKG_ROOT="/vcpkg"

RUN git clone https://github.com/Microsoft/vcpkg.git && \
    ./vcpkg/bootstrap-vcpkg.sh

WORKDIR /sandbox
