#!/bin/bash

#
# Build libwebsockets static library for Android
#
# requires debian package xutils-dev for makedepend (openssl make depend)
#

# This is based on http://stackoverflow.com/questions/11929773/compiling-the-latest-openssl-for-android/
# via https://github.com/warmcat/libwebsockets/pull/502

# your NDK path
export NDK=/home/ffmpeg/android-ndk-r13b

set -e


export FILE_PATH=android-arm
export TOOLCHAIN_PATH=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
export TOOL=bin/arm-linux-androideabi
export ARCH_FLAGS="-mthumb"
export HEADERS=${TOOLCHAIN_PATH}/sysroot/usr/include
export LIBS=${TOOLCHAIN_PATH}/sysroot/usr/lib
export OPENSSL_ARCH="android"
export OPENSSL_PARAMS="no-shared no-idea no-mdc2 no-rc5 no-zlib no-zlib-dynamic enable-tlsext no-ssl2 no-ssl3 enable-ec enable-ecdh enable-ecp"


function build_ws(){

    # setup environment to use the gcc/ld from the android toolchain
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
	export CXX=$NDK_TOOLCHAIN_BASENAME-g++
	export LINK=${CXX}
	export LD=$NDK_TOOLCHAIN_BASENAME-ld
	export AR=$NDK_TOOLCHAIN_BASENAME-ar
	export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
	export STRIP=$NDK_TOOLCHAIN_BASENAME-strip

	# setup buildflags
	export ARCH_LINK=
	export CPPFLAGS=" ${ARCH_FLAGS} -I${HEADERS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
	export CXXFLAGS=" ${ARCH_FLAGS} -I${HEADERS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
	export CFLAGS=" ${ARCH_FLAGS} -I${HEADERS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
	export LDFLAGS=" ${ARCH_LINK} "

	# configure and build zlib
	[ ! -f ./${FILE_PATH}/lib/libz.a ] && {
	cd zlib-1.2.8
	PATH=$TOOLCHAIN_PATH:$PATH ./configure --static --prefix=$TOOLCHAIN_PATH/..
    mv ./Makefile ./Makefile.old
    sed "s/AR=libtool/AR=`echo ${AR}|sed 's#\/#\\\/#g'`/" ./Makefile.old > Makefile.mid
    sed "s/ARFLAGS=-o/ARFLAGS=-r/" ./Makefile.mid > Makefile
	PATH=$TOOLCHAIN_PATH:$PATH make
	PATH=$TOOLCHAIN_PATH:$PATH make install
	cd ..
	}

	# configure and build openssl
	[ ! -f ./${FILE_PATH}/lib/libssl.a ] && {
	PREFIX=$TOOLCHAIN_PATH/..
	cd openssl-1.0.2g

	./Configure ${OPENSSL_ARCH} --prefix=${PREFIX} ${OPENSSL_PARAMS}
	PATH=$TOOLCHAIN_PATH:$PATH make depend
	PATH=$TOOLCHAIN_PATH:$PATH make
	PATH=$TOOLCHAIN_PATH:$PATH make install_sw
	cd ..
	}

	# configure and build libwebsockets
	[ ! -f ./${FILE_PATH}/lib/libwebsockets.a ] && {
	cd libwebsockets
	[ ! -d build ] && mkdir build
	cd build
	PATH=$TOOLCHAIN_PATH:$PATH cmake \
	  -DCMAKE_C_COMPILER=$CC \
	  -DCMAKE_AR=$AR \
	  -DCMAKE_RANLIB=$RANLIB \
	  -DCMAKE_C_FLAGS="$CFLAGS" \
	  -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN_PATH/.. \
	  -DLWS_WITH_SHARED=OFF \
	  -DLWS_WITH_STATIC=ON \
	  -DLWS_WITHOUT_DAEMONIZE=ON \
	  -DLWS_WITHOUT_TESTAPPS=ON \
	  -DLWS_IPV6=OFF \
	  -DLWS_USE_BUNDLED_ZLIB=OFF \
	  -DLWS_WITH_SSL=ON  \
	  -DLWS_WITH_HTTP2=ON \
	  -DLWS_OPENSSL_LIBRARIES="$TOOLCHAIN_PATH/../lib/libssl.a;$TOOLCHAIN_PATH/../lib/libcrypto.a" \
	  -DLWS_OPENSSL_INCLUDE_DIRS=$TOOLCHAIN_PATH/../include \
	  -DCMAKE_BUILD_TYPE=Release \
	  ..
	PATH=$TOOLCHAIN_PATH:$PATH make
	PATH=$TOOLCHAIN_PATH:$PATH make install
	cd ../..
	}

	echo " build success"
}

build_ws
