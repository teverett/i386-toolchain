#!/bin/bash

# on OSX
# brew install gcc@14

GCC=gcc-4.9.0
BINUTILS=binutils-2.37
TOOLCHAINDIR=toolchain
HOME=`pwd`

export PREFIX=$HOME/toolchain
export TARGET=i386-elf
export CC=/usr/local/bin/gcc-14
export CXX=/usr/local/bin/g++-14
export LD=/usr/local/bin/gcc-14
export CFLAGS=-Wno-error=deprecated-declarations

# toolchain dir
if [ ! -d $TOOLCHAINDIR ]; then
    mkdir $TOOLCHAINDIR
fi
cd $TOOLCHAINDIR

# binutils
if [ ! -f $BINUTILS/binutils/objdump ]; then
    echo "making binutils"
    if [ ! -f $BINUTILS.tar.gz ]; then
        wget http://ftpmirror.gnu.org/binutils/$BINUTILS.tar.gz
    fi

    if [ ! -d $BINUTILS ]; then
        tar zxvf $BINUTILS.tar.gz
    fi

    cd $BINUTILS
    ./configure --prefix=$PREFIX --target=$TARGET --disable-nls 2>&1 configure.log
    make clean
    make
    cd ..
fi

# gcc
#if [ -f $GCC/binutils/objdump ]; then
#    echo "gcc exists"
#else
    echo "making gcc"
    if [ ! -f $GCC.tar.gz ]; then
        wget http://mirror.its.dal.ca/gnu/gcc/$GCC/$GCC.tar.gz
    fi

    if [ ! -d $GCC ]; then
        tar zxvf $GCC.tar.gz
    fi

    cd $GCC
    ./configure --prefix=$PREFIX --target=$TARGET --disable-nls --without-headers \
              --with-newlib --disable-threads --disable-shared \
              --disable-libmudflap --disable-libssp --enable-languages=c,c++ \
              --with-gmp=/usr/local/Cellar/gmp/6.3.0/ \
              --with-mpfr=/usr/local/Cellar/mpfr/4.2.1/ \
              --with-mpc=/usr/local/Cellar/libmpc/1.3.1/ 2>&1 configure.log

     make clean
     make
    cd ..
#fi
