#!/bin/bash
[[ -d ".static/.ftpauto" ]] && mv .static/.ftpauto ./
./e1sg.tcl .
[[ -d ".ftpauto" ]] && mv .ftpauto .static/
cp ftpauto.sh .static/
cp .env .static/
cd .static
./ftpauto.sh
