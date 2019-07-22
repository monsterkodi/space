#!/usr/bin/env bash

DIR=`dirname $0`
BIN=$DIR/../node_modules/.bin
cd $DIR/..

npm install

if rm -rf space-win32-x64; then

    if $BIN/konrad; then

        $BIN/electron-rebuild

        $BIN/electron-packager . --overwrite --icon=img/app.ico

        start space-win32-x64/space.exe
    fi
fi