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
GDBVERSION=gdb-10.2

# important directories
HOME=`pwd`
TOOLCHAINDIR=toolchain
BUILDDIR=$HOME/$TOOLCHAINDIR/build
HOMEBREW_PREFIX=`brew config | grep HOMEBREW_PREFIX |  awk '{print $2}'`
CELLAR=$HOMEBREW_PREFIX/Cellar/gcc@11/11.4.0/bin

echo "HomeBrew is at: $HOMEBREW_PREFIX"

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
echo "building Binutils"
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
echo "building GMP"
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
echo "building MPFR"
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
echo "building MPC"
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
echo "building GCC"
if [ ! -f $PREFIX/bin/i386-elf-gcc ]; then
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
fi

# GDB
    # GDBFILE=$GDBVERSION.tar.gz
    # if [ ! -d $GDBVERSION ]; then
    #     if [ ! -f $GDBFILE ]; then
    #         wget https://ftp.gnu.org/gnu/gdb/$GDBFILE
    #     fi
    #     tar zxvf $GDBFILE
    # fi
    # cd $GDBVERSION
    # mkdir build
    # cd build
    # if [ ! -f Makefile ]; then
    #     ../configure --prefix=$PREFIX --target=$TARGET --disable-werror
    # fi
    # make
    # #make install
    # cd ..
