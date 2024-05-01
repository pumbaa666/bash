#!/bin/bash

# loop through all pages
getWebToon()
{
    i=1
    lastResult=0
    mangaId=$1
    ext="jpg"
    mkdir -p $mangaId
    while [ $lastResult == 0 ] ; do
        url="https://cdn.dogehls.xyz/galleries/$mangaId/$i.$ext"
        wget $url
        lastResult=$?
        echo "getting $url, result is $lastResult"
        mv $i.$ext $mangaId # TODO move with wget
        i=$((i+1))
    done
}

# 1950099 - The WebToon
getWebToon 1950099
echo "Done"