#!/usr/bin/env bash

set -ex

mkdir build
cd build

# configuration
# change -DLIB_INSTALL_DIR=lib to -DCMAKE_INSTALL_LIBDIR=lib for release after 0.6
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIB_INSTALL_DIR=lib
    -DDETACH_KERNEL_DRIVER=OFF
    -DINSTALL_UDEV_RULES=OFF
    -DPROVIDE_UDP_SERVER=ON
    -DWITH_RPC=ON
)

cmake .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# delete static library per conda-forge policy
rm $PREFIX/lib/librtlsdr.a

# copy udev rule and kernel blacklist so they are accessible by users
if [[ $target_platform == linux* ]] ; then
    mkdir -p $PREFIX/lib/udev/rules.d/
    cp ../rtl-sdr.rules $PREFIX/lib/udev/rules.d/
    mkdir -p $PREFIX/etc/modprobe.d/
    cp ../debian/rtl-sdr-blacklist.conf $PREFIX/etc/modprobe.d/
fi
