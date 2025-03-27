#!/bin/bash

export WINHOME="${WINHOME:-/mnt/winhome}"
CIFSNAME="${CIFSNAME:-foobar}"
WINUSER="${WINUSER:-${USER}}"

STARTED_AGENT=0

ensure_wsl() {
    check_wsl || exit
}

check_wsl() {
    # Best way I can think of to check at the moment
    if /usr/bin/uname -r | /bin/grep -q microsoft ; then
	return 0
    fi
    return 1
}

find_ssh_agent() {
    umask 077
    if [ ! -d ~/.ssh_agent ]; then
	echo "Creating ~/.ssh_agent" >&2
	/bin/mkdir ~/.ssh_agent
    fi
    if [ "$(/usr/bin/stat -c %a ~/.ssh_agent)" != '700' ]; then
	echo "Wrong permissions on ~/.ssh_agent" >&2
	return 1
    fi
    if [ ! -e ~/.ssh_agent/ssh_agent_output ]; then
	echo "Starting agent..." >&2
	/usr/bin/ssh-agent > ~/.ssh_agent/ssh_agent_output
	STARTED_AGENT=1
    fi
    if [ "$(/usr/bin/stat -c %a ~/.ssh_agent/ssh_agent_output)" != '600' ]; then
	echo "Wrong permissions on ~/.ssh_agent/ssh_agent_output" >&2
	return 1
    fi

    . ~/.ssh_agent/ssh_agent_output
    echo "SSH_AGENT_PID=${SSH_AGENT_PID}" >&2
    AGENT=$(/bin/ps -c -o comm=,uid= -q ${SSH_AGENT_PID})
    return 0
}

setup_ssh_agent() {
    find_ssh_agent || echo "Couldn't find agent" >&2
    echo "AGENT is '${AGENT}'" >&2
    while (
	[ "$(/usr/bin/awk '{print $1}' <<<${AGENT} )" != 'ssh-agent' ] ||
	[ "$(/usr/bin/awk '{print $2}' <<<${AGENT} )" != $UID ]
    ); do
	echo "Couldn't find agent with AGENT '${AGENT}'"
	rm  ~/.ssh_agent/ssh_agent_output
	find_ssh_agent
    done
}

ensure_winhome_mountpoint() {
    [ -d "${WINHOME}" ] && return 0
    [ ! -x "${WINHOME}" ] && /usr/bin/sudo /bin/mkdir -p ${WINHOME} && return 0
    echo "Problem creating ${WINHOME}" >&2
    return 1
}

setup_display() {
    # use localhost:0 if using e.g. vcxsrv, use :0 for WSLg
    export DISPLAY=:0
}

mount_win_fs() {
    local WINPATH="${1}" MOUNTPOINT="${2}"

    # already mounted?
    /usr/bin/df -t 9p "${MOUNTPOINT}" > /dev/null 2>&1 && return 0

    /usr/bin/sudo /bin/mount -t drvfs "${WINPATH}" "${MOUNTPOINT}" && return 0    
}

mount_winhome_fs() {
    local WINPATH WINUSER="$1"

    WINPATH='C:\Users\'"${WINUSER}"
    ensure_winhome_mountpoint || return 1
    mount_win_fs "${WINPATH}" ${WINHOME}
}

mount_cifs_fs() {
    local MNTDIR=$1 FS=$2

    # already mounted?
    /usr/bin/df -t 9p /mnt/${MNTDIR}/${FS} > /dev/null 2>&1 && return 0

    /usr/bin/sudo /bin/mount -t drvfs '\\'${CIFSNAME}'\'${FS} /mnt/${MNTDIR}/${FS} && return 0
}

add_id() {
    local IDFILE=$1 FILEID AGENTLINE

    FILEID=$(/usr/bin/ssh-keygen -l -E sha256 -f ${WINHOME}/.ssh/${IDFILE} | perl -pe 's/256 (SHA256:[a-zA-Z0-9\/]+)\s.*/$1/')

    if [ -n "${FILEID}" ]; then
        AGENTLINE=$(/usr/bin/ssh-add -l -E sha256 | /bin/grep "${FILEID}")
    fi
    
    if [ -z "${AGENTLINE}" ]; then
        echo "Loading key from ${WINHOME}/.ssh/${IDFILE}..." >&2
	/usr/bin/ssh-add ${WINHOME}/.ssh/${IDFILE}
    fi
}

wsl_startup() {
    setup_ssh_agent
    setup_display
    mount_winhome_fs "${WINUSER}"
}
