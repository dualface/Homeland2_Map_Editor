#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CMD="$DIR/helloworld.app/Contents/MacOS/helloworld -relaunch-off -quick $QUICK_COCOS2DX_ROOT -disable-load-framework -workdir $DIR -size 1280x800"

until $CMD; do
    echo ""
    echo "------------------------------------------------------"
    echo ""
    echo ""
    echo ""
done

