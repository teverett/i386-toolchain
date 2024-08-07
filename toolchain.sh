#!/bin/bash
# https://pdos.csail.mit.edu/6.828/2016/tools.html#chain

#brew upgrade
#brew install gcc@11

# tool versions
BINUTILSVERSION=binutils-2.21.1
GMPVERSION=gmp-5.0.2
MPFRVERSION=mpfr-4.2.1
MPCVERSION=mpc-1.1.0
GCCVERSION=gcc-9.5.0

# important directories
HOME=`pwd`
CELLAR=/usr/local/Cellar/gcc@11/11.4.0/bin
TOOLCHAINDIR=toolchain
BUILDDIR=$HOME/$TOOLCHAINDIR/build

export PREFIX=$HOME/$TOOLCHAINDIR/bin
export TARGET=i386-elf
export CC=$CELLAR/gcc-11
export CXX=/$CELLAR/g++-11
export LD=/$CELLAR/gcc-11
export CFLAGS=-Wno-error=deprecated-declarations

echo "PREFIX is: $PREFIX"

if [ ! -d $TOOLCHAINDIR ]; then
    mkdir -p $BUILDDIR
fi

cd $TOOLCHAINDIR
cd build

# Binutils
if [ ! -f $PREFIX/i386-elf/bin/ld ]; then
    BINUTILSFILE=$BINUTILSVERSION.tar.bz2
    if [ ! -d $BINUTILSVERSION ]; then
        if [ ! -f $BINUTILSFILE ]; then
            wget https://ftp.gnu.org/gnu/binutils/$BINUTILSFILE
        fi
        tar zxvf $BINUTILSFILE
    fi
    cd $BINUTILSVERSION
    if [ ! -f Makefile ]; then
        ./configure --prefix=$PREFIX --target=$TARGET --disable-werror
    fi
    make
    make install
    cd ..
fi

# GMP
if [ ! -f $PREFIX/lib/libgmp.a ]; then
    GMPFILE=$GMPVERSION.tar.bz2
    if [ ! -d $GMPVERSION ]; then
        if [ ! -f $GMPFILE ]; then
            wget https://gmplib.org/download/gmp/$GMPFILE
        fi
        tar zxvf $GMPFILE
    fi
    cd $GMPVERSION
    if [ ! -f Makefile ]; then
        ./configure --prefix=$PREFIX
    fi
    make
    make install
    cd ..
fi

# MPFR
if [ ! -f $PREFIX/lib/libmpfr.a ]; then
    MPFRFILE=$MPFRVERSION.tar.bz2
    if [ ! -d $MPFRVERSION ]; then
        if [ ! -f $MPFRFILE ]; then
            wget https://www.mpfr.org/mpfr-current/$MPFRFILE
        fi
        tar zxvf $MPFRFILE
    fi
    cd $MPFRVERSION
    if [ ! -f Makefile ]; then
        ./configure --prefix=$PREFIX --with-gmp=$PREFIX
    fi
    make
    make install
    cd ..
fi

# MPC
if [ ! -f $PREFIX/lib/libmpc.a ]; then
    MPCFILE=$MPCVERSION.tar.gz
    if [ ! -d $MPCVERSION ]; then
        if [ ! -f $MPCFILE ]; then
            wget https://www.multiprecision.org/downloads/$MPCFILE
        fi
        tar zxvf $MPCFILE
    fi
    cd $MPCVERSION
    if [ ! -f Makefile ]; then
        ./configure --prefix=$PREFIX --with-gmp=$PREFIX
    fi
    make
    make install
    cd ..
fi

# GCC
GCCFILE=$GCCVERSION.tar.gz
if [ ! -d $GCCVERSION ]; then
    if [ ! -f $GCCFILE ]; then
        wget https://ftp.gnu.org/gnu/gcc/$GCCVERSION/$GCCFILE
    fi
    tar zxvf $GCCFILE
fi
cd $GCCVERSION
mkdir build
cd build
if [ ! -f Makefile ]; then
    ../configure --prefix=$PREFIX \
    --target=$TARGET --disable-werror --disable-nls \
    --disable-libssp --disable-libmudflap --with-newlib \
    --without-headers --enable-languages=c,c++ \
    --with-gmp=$PREFIX --with-mpc=$PREFIX --with-mpfr=$PREFIX \
    --with-as=$PREFIX \
    --with-ld=$PREFIX
fi
make all-gcc
make install-gcc
cd ..
