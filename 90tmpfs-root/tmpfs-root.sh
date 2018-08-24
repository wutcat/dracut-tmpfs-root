#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

command -v unpack_archive >/dev/null || . /lib/img-lib.sh

[ -e /lib/nfs-lib.sh ] && . /lib/nfs-lib.sh

PATH=/usr/sbin:/usr/bin:/sbin:/bin

imgfilename=$(getarg rd.tmpfs.imgfile)
tmpfssize=$(getarg rd.tmpfs.size)
tmpmntdir="/run/initramfs/tmp"

mkdir -m 0755 -p /run/initramfs/tmp

if [ "$isnfsroot" ]; then
    mount_nfs "${root#tmpfs:}" "$tmpmntdir"
    if [ "$?" != "0" ]; then
        die "Failed to mount NFS export with root image"
        exit 1
    fi
else
    mount -n "${root#tmpfs:}" /run/initramfs/tmp
    if [ "$?" != "0" ]; then
        die "Failed to mount block device with root image"
        exit 1
    fi
fi

mount -t tmpfs -o size=$tmpfssize tmpfs "$NEWROOT"
if [ "$?" != "0" ]; then
    die "Failed to mount tmpfs root"
    exit 1
fi

info "Unpacking archive to tmpfs root"
tar xpzf /run/initramfs/tmp/$imgfilename -C "$NEWROOT" && umount "$tmpmntdir"
