#!/bin/bash
homedir="/home/arya"
streamingdir="${homedir}/streaming"
ssh="root@188.245.101.133"
vids="${homedir}/Videos"
file="${vids}/$(ls -Art ${vids} | tail -n 1)"
basethumb="${streamingdir}/basethumb.svg"
titlefile="${streamingdir}/title.txt"
audi="1"

if [[ "${file}" != "$(cat ${streamingdir}/lastrec.txt)" ]]; then
    txt="$(cat $titlefile)"
    uuid="$(uuidgen)"
    dir="08d44181-12a5-4b6a-b41b-65c9f6de26a5" # DIRECTORY ON SERVER
    title="${txt} | Audi ${audi} | IndiaFOSS 2024"
    desc="This is the raw footage of a talk, presented at IndiaFOSS 2024. You can see the talks of IndiaFOSS through these videos until our professionally edited videos are uploaded."
    date="$(date +'%Y-%m-%d %H:%M:%S')"
    length="$(ffmpeg -i ${file} 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,// | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')"
    thumbnail="/tmp/thumb.jpg"

    sed "s/TALKNAME_REPLACEME/${title}/" ${basethumb} >/tmp/thumb.svg
    convert /tmp/thumb.svg "${thumbnail}"

    scp "${file}" "${ssh}":/root/osp/osp-app/data/www/videos/${dir}/${uuid}.mp4      #-p ${port}
    scp "${thumbnail}" "${ssh}":/root/osp/osp-app/data/www/videos/${dir}/${uuid}.jpg #-p ${port}
    ssh ${ssh} "chown -R www-data:www-data /root/osp/osp-app/data/www/videos"        #-p ${port}

    query="INSERT INTO RecordedVideo (uuid,videoDate,owningUser,channelName, channelID, description, topic, views, length, videoLocation, thumbnailLocation, gifLocation, pending, allowComments, published, originalStreamID) VALUES('${uuid}','${date}', 1, '${title}', ${audi}, '${desc}', 1, 0, ${length}, '${dir}/${uuid}.mp4', '${dir}/${uuid}.jpg', NULL, 0, 1, 1, NULL);"
    echo ${query} >/tmp/query.txt
    scp "/tmp/query.txt" "${ssh}":/root/osp/osp-mariadb/query.txt # -p ${port}
    ssh -p ${port} ${ssh} 'docker exec osp-osp_db-1 bash -c "/usr/bin/mariadb -p -u root --password=REPLACEME -D osp < /var/lib/mysql/query.txt"'
    echo $file >~/lastrec.txt
else 
	echo "no new recording, exiting"
fi
