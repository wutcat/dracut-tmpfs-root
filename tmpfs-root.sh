#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

command -v unpack_archive >/dev/null || . /lib/img-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

imgfilename=$(getarg rd.tmpfs.imgfile)
tmpfssize=$(getarg rd.tmpfs.size)

mkdir -m 0755 -p /run/initramfs/tmp
mount -n "${root#tmpfs:}" /run/initramfs/tmp
if [ "$?" != "0" ]; then
    die "Failed to mount block device with root image"
    exit 1
fi

mount -t tmpfs -o size=$tmpfssize tmpfs "$NEWROOT"
if [ "$?" != "0" ]; then
    die "Failed to mount tmpfs root"
    exit 1
fi

info "Unpacking archive to tmpfs root"
tar xpzf /run/initramfs/tmp/$imgfilename -C "$NEWROOT" && umount "${root#tmpfs:}"
