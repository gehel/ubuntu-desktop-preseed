#!/bin/sh
#ISO=ubuntu-13.04-desktop-amd64.iso
ISO=mini.iso
MOUNT_POINT=/mnt
IMAGE_DIR=image
IMAGE=custom.iso

BOOTCAT=boot.cat
ISOLINUX_BIN=isolinux.bin

wget -cv http://archive.ubuntu.com/ubuntu/dists/raring/main/installer-amd64/current/images/netboot/mini.iso

rm -rf $IMAGE_DIR
mkdir $IMAGE_DIR
umount $MOUNT_POINT
mount -o loop $ISO $MOUNT_POINT
rsync -av $MOUNT_POINT/ $IMAGE_DIR
umount $MOUNT_POINT
cp desktop.seed $IMAGE_DIR/
cp isolinux.cfg $IMAGE_DIR/

rm -rf initrd
mkdir initrd
cd initrd
gzip -d < ../image/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames
cp ../desktop.seed preseed.cfg
cp ../*.seed .
find . | cpio -H newc --create --verbose | gzip -9 > ../image/initrd.gz
cd ..

genisoimage -r -V "Custom Ubuntu Install CD" \
            -cache-inodes \
            -J -l -b $ISOLINUX_BIN \
            -c $BOOTCAT -no-emul-boot \
            -boot-load-size 4 -boot-info-table \
            -o $IMAGE $IMAGE_DIR

