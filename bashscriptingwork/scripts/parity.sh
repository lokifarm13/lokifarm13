#!/bin/bash
read -p "Введите число: " n
if [ $((n % 2)) -eq 0 ]; then
    echo "$n — чётное"
else
    echo "$n — нечётное"
fi