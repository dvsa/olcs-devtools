#!/usr/bin/env bash

for d in ../*/ ; do
    cd "$d"
    latestTag=`git describe --abbrev=0 --tags`
    for crt_tag in $(git tag) ; do
        hash=`git rev-parse $crt_tag`
        echo "$hash -> $crt_tag" >> CHANGELOG.md
    done
done