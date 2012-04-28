#!/bin/bash

sudo mkfs.msdos floppy.img
sudo losetup /dev/loop0 floppy.img
sudo mount /dev/loop0 /mnt
#sudo dd bs=512 count=2880 if=src/bootloader of=/dev/loop0
sudo dd bs=512 count=1 if=src/boot_loader.o of=/dev/loop0
sudo dd if=src/first_process.o of=/dev/loop0 ibs=1 obs=1 seek=512 count=200 conv=notrunc
sudo dd if=src/second_process.o of=/dev/loop0 ibs=1 obs=1 seek=1024 count=200 conv=notrunc
sudo umount /dev/loop0
sudo losetup -d /dev/loop0
