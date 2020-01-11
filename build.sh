#!/bin/bash
set -x
set -e

rm -rf ./hugo_0.62.2_linux_amd64

curl -L https://github.com/spf13/hugo/releases/download/v0.62.2/hugo_0.62.2_Linux-64bit.tar.gz | tar zxf -

HUGO=./hugo_0.62.2_linux_amd64/hugo_0.62.2_linux_amd64

$HUGO version
$HUGO
