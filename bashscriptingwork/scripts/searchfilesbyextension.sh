#!/bin/bash
ext=${1:-}
[ -z "$ext" ] && read -p "Расширение (например, sh): " ext
ext=${ext#.}
find . -type f -name "*.$ext"