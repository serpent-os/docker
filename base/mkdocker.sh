#!/bin/bash
set -e

if [[ "$EUID" -ne "0" ]]; then
    echo "Must be run as root."
    exit 1
fi

rm -rf rootDir
moss repo add -D rootDir volatile https://dev.serpentos.com/volatile/x86_64/stone.index
moss install -D rootDir -y moss bash dash nss curl bash-completion util-linux coreutils procps

# basic config
mkdir -pv rootDir/var/cache/ldconfig
moss-container -u 0 -d rootDir/ -- ldconfig
moss-container -u 0 -d rootDir/ -- systemd-sysusers
moss-container -u 0 -d rootDir/ -- systemd-tmpfiles --create
moss-container -u 0 -d rootDir/ -- systemd-firstboot --force --setup-machine-id --delete-root-password --locale=en_US.UTF-8 --timezone=UTC --root-shell=/usr/bin/bash

# Clear the cache..
rm -rf rootDir/.moss/cache/downloads
docker rmi serpentos/base:latest || :

docker build --tag serpentos/base:latest .
