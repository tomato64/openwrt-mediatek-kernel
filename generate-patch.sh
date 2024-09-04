#!/bin/bash

KERNEL=6.6.48
HASH=93cca954342e885caa8a15c0fd08bca1ef6d25df

rm -rf linux-$KERNEL
rm -rf openwrt

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
