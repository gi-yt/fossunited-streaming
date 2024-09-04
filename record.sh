#!/usr/bin/env bash
audi=1
day=1
dir="/home/arya/streaming"
obs-cmd recording stop

bash ~/upload-clip.sh &
sleep 5

title="$(cat ${dir}/title.txt)"

newtitle="$(grep -A1 ${title} ${dir}/audi${audi}-day${day}-schedule | tail -n1)"
echo "${newtitle}" > "${dir}/title.txt"

obs-cmd recording start
