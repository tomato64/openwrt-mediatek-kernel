#!/bin/bash

KERNEL=6.6.50
HASH=c7ba5574f52f25334add66c15190b578ac873739

rm -rf linux*
rm -rf openwrt
rm 00001-openwrt-mediatek-kernel*

git clone https://github.com/openwrt/openwrt.git
cd openwrt
git checkout $HASH
cd ..

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL.tar.xz
tar xvJf linux-$KERNEL.tar.xz
cd linux-$KERNEL
git init
git add .
git commit -m "init"

cp -fpR "../openwrt/target/linux/generic/files"/. \
	"../openwrt/target/linux/mediatek/files"/. \
	"../openwrt/target/linux/mediatek/files-6.6"/. \
	.

for patch in ../openwrt/target/linux/generic/backport-6.6/*.patch; do
	patch -p1 < "$patch"
done

for patch in ../openwrt/target/linux/generic/pending-6.6/*.patch; do
	patch -p1 < "$patch"
done

for patch in ../openwrt/target/linux/generic/hack-6.6/*.patch; do
	patch -p1 < "$patch"
done

for patch in ../openwrt/target/linux/mediatek/patches-6.6/*.patch; do
	patch -p1 < "$patch"
done

git add .
git commit -m "openwrt mediatek kernel $KERNEL"
git format-patch HEAD~1
mv 0001-openwrt-mediatek-kernel-$KERNEL.patch \
   ../00001-openwrt-mediatek-kernel-$KERNEL.patch

