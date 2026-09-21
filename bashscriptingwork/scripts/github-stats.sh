#!/bin/bash

# Цвета
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# Проверка зависимостей
for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Ошибка: не установлен $cmd. Установите: sudo apt install $cmd${NC}"
        exit 1
    fi
done

# Проверка аргумента
if [ $# -ne 1 ] || [[ "$1" != */* ]]; then
    echo -e "${RED}Использование: $0 владелец/репозиторий (например, tensorflow/tensorflow)${NC}"
    exit 1
fi
repo=$1

# Запрос к API
tmp=$(mktemp)
code=$(curl -s -o "$tmp" -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$repo")

case $code in
    200) ;;
    404) echo -e "${RED}Репозиторий '$repo' не найден.${NC}"; rm -f "$tmp"; exit 1 ;;
    403|429) echo -e "${RED}Превышен лимит запросов GitHub API. Попробуйте позже.${NC}"; rm -f "$tmp"; exit 1 ;;
    000) echo -e "${RED}Нет соединения с интернетом.${NC}"; rm -f "$tmp"; exit 1 ;;
    *) echo -e "${RED}Ошибка API (HTTP $code).${NC}"; rm -f "$tmp"; exit 1 ;;
esac

# Разбор JSON
name=$(jq -r '.full_name' "$tmp")
stars=$(jq -r '.stargazers_count' "$tmp")
forks=$(jq -r '.forks_count' "$tmp")
issues=$(jq -r '.open_issues_count' "$tmp")
owner=$(jq -r '.owner.login' "$tmp")
pushed=$(jq -r '.pushed_at' "$tmp")
rm -f "$tmp"

# Формат числа: 182347 -> 182,347
fmt() { echo "$1" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'; }

# Активность
now=$(date +%s)
last=$(date -d "$pushed" +%s)
diff=$(( now - last ))
if   [ $diff -lt 86400 ];    then act="Высокая";  ago="$((diff / 3600)) ч. назад"
elif [ $diff -lt 604800 ];   then act="Средняя";  ago="$((diff / 86400)) дн. назад"
else                              act="Низкая";   ago="$((diff / 86400)) дн. назад"
fi

# Цвет для issues
if [ "$issues" -gt 100 ]; then icol=$RED; else icol=$YELLOW; fi

# Вывод
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ${BOLD}🚀 GitHub Repository Analyzer${NC}${CYAN}          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo
echo -e "📦 Репозиторий: ${BOLD}$name${NC}"
echo -e "⭐ Звёзды:       ${YELLOW}$(fmt "$stars")${NC}"
echo -e "🔀 Форки:        ${GREEN}$(fmt "$forks")${NC}"
echo -e "🐛 Open Issues:  ${icol}$(fmt "$issues")${NC}"
echo -e "👤 Автор:        $owner"
echo -e "📊 Активность:   $act (обновлён $ago)"