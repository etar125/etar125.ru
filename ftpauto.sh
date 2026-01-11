#!/usr/bin/bash
# ftpauto.sh
# by etar125
# Copyright (c) 2026 etar125 Admanse

# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

echo "ftpauto v0.1.9 by etar125"

if [[ ! -f ".env" ]]; then
    echo "file .env not found"
    exit 1
fi
source .env
if [[ -z "$USERNAME" ]] || [[ -z "$PASSWORD" ]] || [[ -z "$HOSTNAME" ]] || [[ -z "$PORT" ]] || [[ -z "$REMOTEROOT" ]]; then
    echo "USERNAME, PASSWORD, HOSTNAME, PORT or REMOTEROOT is missing"
    exit 1
fi

mkdir -p .ftpauto

TMP_SCRIPT=$(mktemp)
TMP_MD5=$(mktemp)
cat > $TMP_SCRIPT << EOF
open -u $USERNAME,$PASSWORD -p $PORT $HOSTNAME
cd $REMOTEROOT
EOF

for d in $(find . -type d); do
    [[ "$d" == "." ]] && continue
    [[ ! -z "$(echo $d | grep \.ftpauto)" ]] && continue
    [[ ! -z "$(echo $d | grep \.static)" ]] && continue
    if [[ ! -d ".ftpauto/$d" ]]; then
        mkdir -p ".ftpauto/$d"
        cat >> $TMP_SCRIPT << EOF
mkdir -pf $d
EOF
    fi
done

echo "На загрузку..."

for f in $(find . -type f); do
    [[ "$f" == "./.env" ]] && continue
    [[ "$f" == "./.script" ]] && continue
    [[ "$f" == "./ftpauto.sh" ]] && continue
    [[ ! -z "$(echo $f | grep \.ftpauto/)" ]] && continue
    [[ ! -z "$(echo $f | grep \.static)" ]] && continue
    if [[ -f ".ftpauto/$f.md5" ]]; then
        md5sum $f > $TMP_MD5
        if cmp -s "$TMP_MD5" ".ftpauto/$f.md5"; then
            echo -e "$f \\033[32mактуален\\033[0m"
        else
            echo -e "$f \\033[33mнеактуален\\033[0m"
            cat >> $TMP_SCRIPT << EOF
put $f -o $f
EOF
            rm .ftpauto/$f.md5
            cp $TMP_MD5 .ftpauto/$f.md5
        fi
        rm $TMP_MD5
    else
        echo -e "MD5 \\033[31mотсутствует\\033[0m, $f \\033[32mнеактуален\\033[0m"
        md5sum $f > .ftpauto/$f.md5
        cat >> $TMP_SCRIPT << EOF
put $f -o $f
EOF
    fi
done

echo ":: На удаление"

cd .ftpauto
for d in $(find . -type d); do
    if [[ ! -d "../$d" ]]; then
        echo -e "$d \\033[33mудалена локально\\033[0m"
        cat >> $TMP_SCRIPT << EOF
rm -r $d
EOF
        rm -r $d
    fi
done

for f in $(find . -type f); do
    name=${f%????}
    if [[ ! -f "../$name" ]]; then
        echo -e "$name \\033[33mудалён локально\\033[0m"
        cat >> $TMP_SCRIPT << EOF
rm $name
EOF
        rm $f
    fi
done
cd ..

echo "quit" >> $TMP_SCRIPT

cat $TMP_SCRIPT > .script
cat $TMP_SCRIPT

echo "Press Enter to continue"
read

lftp -f $TMP_SCRIPT
rm $TMP_SCRIPT
