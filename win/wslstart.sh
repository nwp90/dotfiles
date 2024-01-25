#!/bin/bash

WINHOME_MOUNT="${WINHOME_MOUNT:=/mnt/winhome}"
DSNAME="${DSNAME:=ds.localdomain}"
WINUSER="${WINUSER:=phini20p}"

# set -e
# LOCALSOURCE=$(CDPATH= cd -- $(dirname -- "$0") && pwd -P)
# echo LOCALSOURCE=${LOCALSOURCE}
# . ${LOCALSOURCE}/wsltools.sh
# set +e

mount_ds() {
    # to get credentials right...
    # see https://learn.microsoft.com/en-us/archive/blogs/wsl/file-system-improvements-to-the-windows-subsystem-for-linux
    #
    # tl;dr - either mount the share in Windows before starting WSL,
    # use Windows Credential Manager, or make some perverted calls to
    # "net use" from within WSL.
    #
    mount_cifs_fs ds pub || echo "Mount failed for pub"
    mount_cifs_fs ds Media || echo "Mount failed for Media"
    mount_cifs_fs ds home || echo "Mount failed for home"
    mount_cifs_fs ds photo || echo "Mount failed for photo"
}

ensure_wsl
wsl_startup
mount_ds
add_id id_ed25519
