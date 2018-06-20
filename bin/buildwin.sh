#!/usr/bin/env bash
cd `dirname $0`/..

if rm -rf space-win32-x64; then
    
    konrad

    node_modules/.bin/electron-rebuild

    node_modules/electron-packager/cli.js . --overwrite --icon=img/app.ico --win32metadata.FileDescription=space
    
    rm -rf space-win32-x64/resources/app/inno

fi