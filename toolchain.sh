#!/bin/bash
# https://pdos.csail.mit.edu/6.828/2016/tools.html#chain

#brew upgrade
#brew install gcc@11

# tool versions
BINUTILSVERSION=binutils-2.43
GMPVERSION=gmp-6.3.0
MPFRVERSION=mpfr-4.2.1
MPCVERSION=mpc-1.1.0
GCCVERSION=gcc-14.2.0
GDBVERSION=gdb-10.2

# config
CORES=4
CACHEDIR=/tmp/toolchain
TARFILE=i386_buildchain.tar.gz

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
echo "BUILDDIR is $BUILDDIR"
echo "CACHEDIR is $CACHEDIR"
echo

if [ ! -d $CACHEDIR ]; then
    mkdir -p $CACHEDIR
fi

if [ ! -d $BUILDDIR ]; then
    mkdir -p $BUILDDIR
fi

cd $TOOLCHAINDIR
cd build

# Binutils
if [ ! -f $PREFIX/i386-elf/bin/ld ]; then
    echo "building Binutils"
    BINUTILSFILE=$BINUTILSVERSION.tar.bz2
    if [ ! -d $BINUTILSVERSION ]; then
        if [ -f $CACHEDIR/$BINUTILSFILE ]; then
            cp $CACHEDIR/$BINUTILSFILE .
        fi
        if [ ! -f $BINUTILSFILE ]; then
            echo "downloading $BINUTILSFILE"
            wget https://ftp.gnu.org/gnu/binutils/$BINUTILSFILE
            cp $BINUTILSFILE $CACHEDIR
        fi
        tar zxvf $BINUTILSFILE
    fi
    cd $BINUTILSVERSION
    if [ ! -f Makefile ]; then
        ./configure --prefix=$PREFIX --target=$TARGET --disable-werror
    fi
    make -j $CORES
    make install
    cd ..
else
    echo "$PREFIX/i386-elf/bin/ld exists"
fi

# GMP
if [ ! -f $PREFIX/lib/libgmp.a ]; then
    echo "building GMP"
    GMPFILE=$GMPVERSION.tar.bz2
    if [ ! -d $GMPVERSION ]; then
        if [ -f $CACHEDIR/$GMPFILE ]; then
            cp $CACHEDIR/$GMPFILE .
        fi
        if [ ! -f $GMPFILE ]; then
            echo "downloading $GMPFILE"
            wget https://ftp.gnu.org/pub/gnu/gmp/$GMPFILE
            cp $GMPFILE $CACHEDIR
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
else
    echo "$PREFIX/lib/libgmp.a exists"
fi

# MPFR
if [ ! -f $PREFIX/lib/libmpfr.a ]; then
    echo "building MPFR"
    MPFRFILE=$MPFRVERSION.tar.bz2
    if [ ! -d $MPFRVERSION ]; then
        if [ -f $CACHEDIR/$MPFRFILE ]; then
            cp $CACHEDIR/$MPFRFILE .
        fi
        if [ ! -f $MPFRFILE ]; then
            echo "downloading $MPFRFILE"
            wget https://www.mpfr.org/mpfr-current/$MPFRFILE
            cp $MPFRFILE $CACHEDIR
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
else
    echo "$PREFIX/lib/libmpfr.a exists"
fi

# MPC
if [ ! -f $PREFIX/lib/libmpc.a ]; then
    echo "building MPC"
    MPCFILE=$MPCVERSION.tar.gz
    if [ ! -d $MPCVERSION ]; then
        if [ -f $CACHEDIR/$MPCFILE ]; then
            cp $CACHEDIR/$MPCFILE .
        fi
        if [ ! -f $MPCFILE ]; then
            echo "downloading $MPCFILE"
            wget https://www.multiprecision.org/downloads/$MPCFILE
            cp $MPCFILE $CACHEDIR
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
else
    echo "$PREFIX/lib/libmpc.a exists"
fi

# GCC
if [ ! -f $PREFIX/bin/i386-elf-gcc ]; then
    echo "building GCC"
    GCCFILE=$GCCVERSION.tar.gz
    if [ ! -d $GCCVERSION ]; then
        if [ -f $CACHEDIR/$GCCFILE ]; then
            cp $CACHEDIR/$GCCFILE .
        fi
        if [ ! -f $GCCFILE ]; then
            echo "downloading $GCCFILE"
            wget https://ftp.gnu.org/gnu/gcc/$GCCVERSION/$GCCFILE
            cp $GCCFILE $CACHEDIR
        fi
        tar zxvf $GCCFILE
    fi
    cd $GCCVERSION
    mkdir build
    cd build
    if [ ! -f Makefile ]; then
        ../configure --prefix=$PREFIX \
        --target=$TARGET --disable-werror --disable-nls \
        --disable-libssp --disable-libmudflap \
        --without-headers --enable-languages=c,c++ \
        --with-gmp=$PREFIX --with-mpc=$PREFIX --with-mpfr=$PREFIX \
        --with-multilib-list=m32 \
        --enable-interwork --enable-multilib 
    fi
    make all-gcc    
    make install-gcc
    cd ..
    cd ..
else
    echo "$PREFIX/bin/i386-elf-gcc exists"
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

rm -f $TARFILE
tar tar $TARFILE $PREFIX/bin/*

echo
cd ../..
$PREFIX/bin/i386-elf-ld --version 
echo
$PREFIX/bin/i386-elf-gcc --version
