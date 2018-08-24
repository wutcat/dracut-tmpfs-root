#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    # a live host-only image doesn't really make a lot of sense
    [[ $hostonly ]] && return 1
    return 255
}

depends() {
    echo img-lib network nfs
    return 0
}

installkernel() {
    instmods loop
}

install() {
    inst_multiple umount
    inst_hook cmdline 30 "$moddir/parse-tmpfs-root.sh"
    inst_hook mount 30 "$moddir/tmpfs-root.sh"
    inst_hook pre-pivot 99 "$moddir/tmpfs-fix-selinux.sh"
}
