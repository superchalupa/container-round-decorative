#!/bin/bash

set -x
set +e


function download_it() {
    local download_nr
    local url
    local location
    download_nr=$1
    if [ "${download_nr##http}" = "$download_nr" ]; then
        # it doesnt start with http://
        url=http://www.thingiverse.com/download:$download_nr
    else
        # it starts with http, so just use it
        url=$download_nr
    fi
    location=$(wget --max-redirect=0 $url 2>&1 | grep ^Location: )
    location=$(echo $location | cut -d: -f2- )
    location=$(echo $location | cut -d' ' -f1)
    wget $location $wget_opts
}

function download_them() {
    for download_nr in "$@"; do
        download_it $download_nr
    done
}


while [ $# -gt 0 ]; do
    wget_opts=
    url=http://www.thingiverse.com/thing:$1
    TEMPDIR=TEMPDIR-$1
    mkdir $TEMPDIR
    pushd $TEMPDIR
    wget $url -O index.html -q
    title=$(grep '<title>' index.html | cut -d'>' -f2 | cut -d'<' -f1):$1
    downloads=$(grep '>download<' index.html | cut -d: -f2 | cut -d'"' -f1)
    shift

    git init
    download_them $downloads
    git add .
    git commit -m "initial import of thingiverse thing $1"

    popd
    mv $TEMPDIR "$title"
done
