#!/usr/bin/sh
set -eu

#------------------------------------------------------------------------------
# SESSION VARIABLES
#------------------------------------------------------------------------------

CURDIR=$PWD

#------------------------------------------------------------------------------
# SHELL FUNCTIONS
#------------------------------------------------------------------------------

extract() {
    if expr "$1" : '.*=.*' > /dev/null; then
        echo "${1#*=}"
    else
        echo ""
    fi
}

help() {
    cat << EOF | sed 's/^    //'
    Usage: $0 [OPTION]...

    Options:
      --prefix=<path>             Specify the installation path
                                  (default: /usr/local)
      --enable-tools=<tool>...    List of tools to be installed
                                  [<tool>={all, binutils,gcc,gdb,cmake,llvm,iwyu}]
                                  (default: all)
      --binutils-version=<value>  GNU Binutils version to be installed
                                  (default: ${binutils_version})
      --gcc-version=<value>       GCC version to be installed
                                  (default: ${gcc_version})
      --gdb-version=<value>       GDB version to be installed
                                  (default: ${gdb_version})
      --cmake-version=<value>     CMake version to be installed
                                  (default: ${cmake_version})
      --llvm-version=<value>      LLVM version to be installed
                                  (default: ${llvm_version})
      --iwyu-version=<value>      include-what-you-use version to be installed
                                  (default: ${iwyu_version})
EOF
}

download_and_install_binutils() {
    if ! expr "$1" : '[0-9]\+\.[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    wget https://ftp.gnu.org/gnu/binutils/binutils-"$1".tar.gz
    tar -xvf binutils-"$1".tar.gz

    mkdir binutils-"$1"/build
    cd binutils-"$1"/build

    ../configure --prefix="$2" --disable-multilib --disable-nls

    make -j"$(nproc)"
    make install

    cd "$CURDIR"
    rm -rf binutils-"$1" binutils-"$1".tar.gz
}

download_and_install_gcc() {
    if ! expr "$1" : '[0-9]\+\.[0-9]\+\.[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    wget https://ftp.gnu.org/gnu/gcc/gcc-"$1"/gcc-"$1".tar.gz
    tar -xvf gcc-"$1".tar.gz

    mkdir gcc-"$1"/build
    cd gcc-"$1"/build

    ../configure --prefix="$2" --enable-languages=c,c++ --disable-multilib --disable-nls

    make -j"$(nproc)"
    make install

    if ! grep -q "$2/lib64" /etc/ld.so.conf; then
        sed -i "1s;^;$2/lib64\n;" /etc/ld.so.conf
        ldconfig
    fi

    cd "$CURDIR"
    rm -rf gcc-"$1" gcc-"$1".tar.gz
}

download_and_install_gdb() {
    if ! expr "$1" : '[0-9]\+\.[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    wget https://ftp.gnu.org/gnu/gdb/gdb-"$1".tar.gz
    tar -xvf gdb-"$1".tar.gz

    mkdir gdb-"$1"/build
    cd gdb-"$1"/build

    ../configure --prefix="$2"

    make -j"$(nproc)"
    make install

    cd "$CURDIR"
    rm -rf gdb-"$1" gdb-"$1".tar.gz
}

download_and_install_cmake() {
    if ! expr "$1" : '[0-9]\+\.[0-9]\+\.[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    wget https://github.com/Kitware/CMake/releases/download/v"$1"/cmake-"$1".tar.gz
    tar -xvf cmake-"$1".tar.gz

    mkdir cmake-"$1"/build
    cd cmake-"$1"/build

    ../configure --prefix="$2" --parallel="$(nproc)"

    make -j"$(nproc)"
    make install

    cd "$CURDIR"
    rm -rf cmake-"$1" cmake-"$1".tar.gz
}

download_and_install_llvm() {
    if ! expr "$1" : '[0-9]\+\.[0-9]\+\.[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    git clone --depth 1 --branch llvmorg-"$1" https://github.com/llvm/llvm-project.git

    mkdir llvm-project/build
    cd llvm-project/build

    cmake -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lldb;lld" -DCMAKE_INSTALL_PREFIX="$2" -DCMAKE_BUILD_TYPE=Release ../llvm

    make -j"$(nproc)"
    make install

    cd "$CURDIR"
    rm -rf llvm-project
}

download_and_install_iwyu() {
    if ! expr "$1" : '[0-9]\+' > /dev/null; then
        echo "Invalid version: $1"
        exit 1
    fi

    git clone --branch clang_"$1" https://github.com/include-what-you-use/include-what-you-use.git

    mkdir include-what-you-use/build
    cd include-what-you-use/build

    cmake -DCMAKE_INSTALL_PREFIX="$2" -DCMAKE_PREFIX_PATH="$2/lib" -DCMAKE_BUILD_TYPE=Release ..

    make -j"$(nproc)"
    make install

    cp ../iwyu_tool.py "$2/bin"

    cd "$CURDIR"
    rm -rf include-what-you-use
}

#------------------------------------------------------------------------------
# MAIN SCRIPT
#------------------------------------------------------------------------------

prefix=/usr/local

binutils_version=2.43
gcc_version=14.2.0
gdb_version=15.2
cmake_version=3.31.0
llvm_version=19.1.3
iwyu_version=19

tools=all

while [ $# -gt 0 ]; do
    case $1 in
        --prefix*)
            prefix=$(extract "$1")
        ;;
        --enable-tools*)
            tools=$(extract "$1")
        ;;
        --binutils-version*)
            binutils_version=$(extract "$1")
        ;;
        --gcc-version*)
            gcc_version=$(extract "$1")
        ;;
        --gdb-version*)
            gdb_version=$(extract "$1")
        ;;
        --cmake-version*)
            cmake_version=$(extract "$1")
        ;;
        --llvm-version*)
            llvm_version=$(extract "$1")
        ;;
        --iwyu-version*)
            iwyu_version=$(extract "$1")
        ;;
        -h|--help)
            help
            exit 0
        ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
        ;;
    esac
    shift
done

if echo "${tools}" | grep -q "all"; then
    tools="binutils,gcc,gdb,cmake,llvm,iwyu"
fi

if echo "${tools}" | grep -q "binutils"; then
    download_and_install_binutils "${binutils_version}" "${prefix}"
fi

if echo "${tools}" | grep -q "gcc"; then
    download_and_install_gcc "${gcc_version}" "${prefix}"
fi

if echo "${tools}" | grep -q "gdb"; then
    download_and_install_gdb "${gdb_version}" "${prefix}"
fi

if echo "${tools}" | grep -q "cmake"; then
    download_and_install_cmake "${cmake_version}" "${prefix}"
fi

if echo "${tools}" | grep -q "llvm"; then
    download_and_install_llvm "${llvm_version}" "${prefix}"
fi

if echo "${tools}" | grep -q "iwyu"; then
    download_and_install_iwyu "${iwyu_version}" "${prefix}"
fi
