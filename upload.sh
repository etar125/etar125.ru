#!/bin/bash
[[ -x "dst/.ftpauto" ]] && mv dst/.ftpauto ./
ssgc src dst
[[ -x ".ftpauto" ]] && mv .ftpauto dst/
cp ftpauto.sh dst/
cp .env dst/
cd dst
./ftpauto.sh
mv .ftpauto ../
cd ..
rm -r dst
