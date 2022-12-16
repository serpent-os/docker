#!/bin/bash
set -e

if [[ "$EUID" -ne "0" ]]; then
    echo "Must be run as root."
    exit 1
fi

rm -rf rootDir
moss ar -D rootDir -p 0 protosnek https://dev.serpentos.com/protosnek/x86_64/stone.index
moss ar -D rootDir -p 10 volatile https://dev.serpentos.com/volatile/x86_64/stone.index
moss it -D rootDir -y moss bash dash nss curl

# TODO: Stateless profile! This is ugly as sin.
mkdir rootDir/root
echo "root:x:0:0:root:/root:/bin/bash" >> rootDir/etc/passwd
echo "root:x:0:0:root:/root:/bin/bash" >> rootDir/etc/passwd-
echo "root:x:0:" >> rootDir/etc/group
echo "root:x:0:" >> rootDir/etc/group-
mkdir rootDir/tmp

install -m 00644 profile rootDir/etc/profile

# Clear the cache..
rm -rf rootDir/.moss/cache/downloads
docker rmi serpentos/base:latest || :

docker build --tag serpentos/base:latest .
