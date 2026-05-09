#!/bin/bash
[[ -x ".static/.ftpauto" ]] && mv .static/.ftpauto ./
./e1sg.tcl .
[[ -x ".ftpauto" ]] && mv .ftpauto .static/
cp ftpauto.sh .static/
cp .env .static/
cd .static
./ftpauto.sh
