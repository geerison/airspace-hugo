#!/bin/bash
set -x
set -e

rm -rf ./hugo_0.62.2_linux_amd64

curl -L https://github.com/spf13/hugo/releases/download/v0.62.2/hugo_0.62.2_Linux-64bit.tar.gz | tar zxf -

HUGO=./hugo
cd exampleSite
$HUGO version
$HUGO

rsync -av -e 'ssh -p 22' ~/clone/public/ c14838admin@wh09.rackhost.hu: /public

