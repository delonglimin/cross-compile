#!/bin/bash

#
# Build libwebsockets static library for Android
#
# requires debian package xutils-dev for makedepend (openssl make depend)
#

# This is based on http://stackoverflow.com/questions/11929773/compiling-the-latest-openssl-for-android/
# via https://github.com/warmcat/libwebsockets/pull/502

# path to NDK
export NDK=/home/ffmpeg/android-ndk-r13b
export SYSROOT=$NDK/platforms/android-9/arch-arm/
set -e



# setup environment to use the gcc/ld from the android toolchain
export TOOLCHAIN_PATH=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin
export TOOL=arm-linux-androideabi
export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
export CC=$NDK_TOOLCHAIN_BASENAME-gcc
export CXX=$NDK_TOOLCHAIN_BASENAME-g++
export LINK=${CXX}
export LD=$NDK_TOOLCHAIN_BASENAME-ld
export AR=$NDK_TOOLCHAIN_BASENAME-ar
export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
export STRIP=$NDK_TOOLCHAIN_BASENAME-strip

# setup buildflags
export ARCH_FLAGS="-mthumb"
export ARCH_LINK=
export CPPFLAGS="--sysroot=$SYSROOT"
export CXXFLAGS="--sysroot=$SYSROOT"
export CFLAGS="--sysroot=$SYSROOT"
export LDFLAGS="--sysroot=$SYSROOT"



# configure and build libwebsockets
cd ..
cd ..
cd libwebsockets
[ ! -d build ] && mkdir build
cd build
PATH=$TOOLCHAIN_PATH:$PATH cmake \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_AR=$AR \
  -DCMAKE_RANLIB=$RANLIB \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_INSTALL_PREFIX=/home/buildws/libws \
  -DLWS_WITH_SHARED=OFF \
  -DLWS_WITH_STATIC=ON \
  -DLWS_WITHOUT_DAEMONIZE=ON \
  -DLWS_WITHOUT_TESTAPPS=ON \
  -DLWS_IPV6=OFF \
  -DLWS_WITH_BUNDLED_ZLIB=OFF \
  -DLWS_WITH_SSL=ON  \
  -DLWS_WITH_HTTP2=ON \
  -DLWS_OPENSSL_LIBRARIES="/home/buildws/ssl/lib/libssl.a;/home/buildws/ssl/lib/libcrypto.a" \
  -DLWS_OPENSSL_INCLUDE_DIRS=/home/buildws/ssl/include \
  -DCMAKE_BUILD_TYPE=Debug \
  ..
PATH=$TOOLCHAIN_PATH:$PATH make
PATH=$TOOLCHAIN_PATH:$PATH make install
cd ../..

