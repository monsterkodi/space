#!/usr/bin/env bash
cd `dirname $0`/..

rm -rf /Applications/space.app
cp -R space-darwin-x64/space.app /Applications

open /Applications/space.app 
