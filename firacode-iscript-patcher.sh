#!/bin/bash

NEW_NAME=${1:-Fira Code iScript}
FONTNAME_PY="https://raw.githubusercontent.com/chrissimpkins/fontname.py/master/fontname.py"
REGULAR_FONT="$(wget -qO- https://api.github.com/repos/tonsky/FiraCode/releases/latest \
    | sed -n '/browser_download_url/s/.*: \"\(.*\)\"/\1/p')?file=ttf/FiraCode-Regular.ttf"
SCRIPT_FONT="https://www.cdnfonts.com/download/script12-bt-cdnfonts.zip?file=SCRPT12N.TTF"

main() {
    python_venv
    fontname_tool

    mkdir -p .download && cd .download

    download_pkg $REGULAR_FONT "${NEW_NAME// /}-Regular"
    download_pkg $SCRIPT_FONT "${NEW_NAME// /}-Italic"

    cd .. && rm -rf .download

    python3 fontname.py "$NEW_NAME" *.ttf
    rm -f fontname.py
}

python_venv() {
    [ ! -d .venv ] && python3 -m venv .venv
    . ./.venv/bin/activate
    pip3 install fonttools
}

fontname_tool() {
    if [ ! -f $(basename $FONTNAME_PY) ]; then
        wget -q $FONTNAME_PY
        sed -i "/style = str(record)/a\\
                if style == 'Roman':\\
                    style = 'Italic'\\
                    record.string = 'Italic'
        " $(basename $FONTNAME_PY)
    fi
}

download_pkg() {
    wget -q ${1/\?*/}
    if [ "${1/\?*/}" != "$1" ]; then
        unzip -q $(basename ${1/\?*/})
        mv ${1/*\?file=/} ../"$2.ttf"
    else
        mv $(basename $1) ../.
    fi
}

main "$@"
