#!/bin/bash
[[ -z "$1" ]] && exit 1
1md $1 | 1md2ht -
