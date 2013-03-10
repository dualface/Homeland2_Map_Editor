#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/bin/mac/Homeland2.app/Contents/MacOS/Homeland2 -workdir $DIR -file scripts/main_editor.lua -size 1280x800

