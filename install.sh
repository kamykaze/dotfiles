#!/usr/bin/env bash
function link_file {
    source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}" ]; then
        echo "${target} already exists...skipping"
    else
        echo "${source} linked to ${target}"
        ln -si ${source} ${target}
    fi
}

for i in _*
do
    link_file $i
done

#git submodule sync
#git submodule init
#git submodule update
#git submodule foreach git pull origin master
#git submodule foreach git submodule init
#git submodule foreach git submodule update

