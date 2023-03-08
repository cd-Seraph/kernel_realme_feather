#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=feather
export KBUILD_BUILD_USER="cd-Seraph"
ZIPNAME=Feather-OSS-KERNEL-RELEASE-"${DATE}".zip
git clone --depth=1 https://gitlab.com/Panchajanya1999/azure-clang.git clang

[ -d "AnyKernel" ] && rm -rf AnyKernel
[ -d "out" ] && rm -rf out || mkdir -p out

# Built In Timer
SECONDS=0

make O=out ARCH=arm64 vendor/feather_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      	ARCH=arm64 \
                      	CC="clang" \
                      	LD=ld.lld \
		      	        AR=llvm-ar \
		     	 	    NM=llvm-nm \
		      	        OBJCOPY=llvm-objcopy \
		      	        OBJDUMP=llvm-objdump \
                      	CLANG_TRIPLE=aarch64-linux-gnu- \
                      	CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      	CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      	CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

function zipping()
{
git clone --depth=1 https://github.com/cd-Seraph/AnyKernel3.git -b master AnyKernel
cp out/arch/arm64/boot/Image AnyKernel
cd AnyKernel
zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
cd ..
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
}
compile
zipping