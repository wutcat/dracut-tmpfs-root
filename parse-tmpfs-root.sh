#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh
# cmdline parsing script for tmpfs-root module, ex:
# root=tmpfs:/dev/vda1 tmpfs.imgfile=rootfs.tar.gz

[ -z "$root" ] && root=$(getarg root=)

imgfilename=$(getarg tmpfs.imgfile)
tmpfssize=$(getarg tmpfs.size)

if [ "${root%%:*}" = "tmpfs" ]; then
    tmpfsroot=$root
fi

[ "${tmpfsroot%%:*}" = "tmpfs" ] || return

modprobe -q loop

case "$tmpfsroot" in
    live:LABEL=*|LABEL=*) \
        root="${root#tmpfs:}"
        root="$(echo $root | sed 's,/,\\x2f,g')"
        root="tmpfs:/dev/disk/by-label/${root#LABEL=}"
        rootok=1 ;;
    live:UUID=*|UUID=*) \
        root="${root#tmpfs:}"
        root="tmpfs:/dev/disk/by-uuid/${root#UUID=}"
        rootok=1 ;;
    live:PARTUUID=*|PARTUUID=*) \
        root="${root#tmpfs:}"
        root="tmpfs:/dev/disk/by-partuuid/${root#PARTUUID=}"
        rootok=1 ;;
    live:PARTLABEL=*|PARTLABEL=*) \
        root="${root#tmpfs:}"
        root="tmpfs:/dev/disk/by-partlabel/${root#PARTLABEL=}"
        rootok=1 ;;
    live:/dev/*)
        rootok=1 ;;
esac
info "root was $liveroot, is now $root"

# make sure that init doesn't complain
[ -z "$root" ] && root="live"

wait_for_dev -n "${root#tmpfs:}"
