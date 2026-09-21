#!/bin/bash
file=${1:-}
[ -z "$file" ] && read -p "Путь к файлу: " file
if [ ! -f "$file" ]; then
    echo "Файл не найден: $file"; exit 1
fi
echo "Строк в $file: $(wc -l < "$file")"