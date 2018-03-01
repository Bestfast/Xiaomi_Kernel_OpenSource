#!/bin/bash
set -e
#CI stuff
sudo apt-get update --quiet
# This gets updates for server/ci
sudo apt-get install --yes build-essential bc kernel-package libncurses5-dev bzip2 liblz4-tool git curl
## Copy this script inside the kernel directory
KERNEL_DIR=$PWD
KERNEL_TOOLCHAIN=$KERNEL_DIR/toolchain/bin/aarch64-linux-android-
rm -rf toolchain
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 --single-branch toolchain
KERNEL_DEFCONFIG=sagit_defconfig
JOBS="-j$(nproc --all)"

export CROSS_COMPILE=$KERNEL_TOOLCHAIN
export ARCH=arm64
export SUBARCH=arm64
make clean
make mrproper
make $KERNEL_DEFCONFIG
make $JOBS
mkdir -p out
make O=out clean
make O=out mrproper
make O=out $KERNEL_DEFCONFIG
make O=out -j$(nproc --all)

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
