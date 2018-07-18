#!/bin/bash

export NDK=/home/ffmpeg/android-ndk-r13b
export SYSROOT=$NDK/platforms/android-9/arch-arm/
export TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
export CPU=arm
export PREFIX=$(pwd)/android/$CPU 
export ADDI_CFLAGS="-marm"
function build_one
{
./configure \
 --prefix=$PREFIX \
 --enable-shared \
 --disable-static \
 --disable-doc \
 --disable-ffmpeg \
 --disable-ffplay \
 --disable-ffprobe \
 --disable-ffserver \
 --disable-avdevice \
 --disable-doc \
 --disable-symver \
 --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
 --target-os=linux \
 --arch=arm \
 --enable-cross-compile \
 --sysroot=$SYSROOT \
 --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
 --extra-ldflags="$ADDI_LDFLAGS" \
 $ADDITIONAL_CONFIGURE_FLAG
make clean
make
make install
}

build_one
