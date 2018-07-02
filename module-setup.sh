#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    # a live host-only image doesn't really make a lot of sense
    [[ $hostonly ]] && return 1
    return 255
}

depends() {
    echo img-lib
    return 0
}

installkernel() {
    instmods loop
}

install() {
    inst_multiple umount
    inst_hook mount 99 "$moddir/tmpfs-root.sh"
}
