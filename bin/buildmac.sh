#!/usr/bin/env bash
cd `dirname $0`/..

if rm -rf space-darwin-x64; then

    ./node_modules/.bin/konrad
    
    IGNORE="/(.*\.dmg$|Icon$|watch$|icons$|.*md$|pug$|styl$|.*\.lock$|img/banner\.png)"
    
    node_modules/electron-packager/cli.js . --overwrite --icon=img/app.icns --ignore=$IGNORE
fi