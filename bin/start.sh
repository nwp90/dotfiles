#!/bin/bash

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

setup_display() {
    # use localhost:0 if using e.g. vcxsrv, use :0 for WSLg
    export DISPLAY=:0
}

mount_ds_fs() {
    local FS=$1

    # already mounted?
    /usr/bin/df -t 9p /mnt/ds/${FS} > /dev/null 2>&1 && return 0

    sudo /bin/mount -t drvfs '\\ds\'${FS} /mnt/ds/${FS} && return 0
}

mount_ds() {
    mount_ds_fs pub || echo "Mount failed for pub"
    mount_ds_fs Media || echo "Mount failed for Media"
    mount_ds_fs home || echo "Mount failed for home"
    mount_ds_fs photo || echo "Mount failed for photo"
    
    #sudo /bin/mount -t drvfs '\\ds\pub' /mnt/ds/pub
    #sudo /bin/mount -t drvfs '\\ds\Media' /mnt/ds/Media
    #sudo /bin/mount -t drvfs '\\ds\home' /mnt/ds/home
    #sudo /bin/mount -t drvfs '\\ds\photo' /mnt/ds/photo
}

check_wsl || exit
setup_ssh_agent
setup_display
mount_ds