#!/usr/bin/env bash
audi=1
day=1
dir="/home/zerodha-foss/streaming"
obs-cmd recording stop

bash ${dir}/upload-clip.sh
