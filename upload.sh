#!/bin/bash
mv .static/.ftpauto ../
./e1sg.tcl .
mv .ftpauto .static/
cp ftpauto.sh .static/
cd .static
./ftpauto.sh
