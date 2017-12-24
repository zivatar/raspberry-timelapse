#!/usr/bin/env bash
DOWNLOAD_IMAGES=0
SORT_IMAGES=1
CREATE_VIDEO=0
UPLOAD_VIDEO=0

. config.cfg

cd images

if [ ${DOWNLOAD_IMAGES} -eq 1 ]
then
echo Download files from ${ftp_host}...
ftp -inv ${ftp_host} << EOF
    user ${ftp_user} ${ftp_pw}
    cd images
    mget *
    bye
EOF
fi

cd ../sorted_images
if [ ${SORT_IMAGES} -eq 1 ]
then
echo Sort files into directories
for file in ../images/*; do
  DAY="$(echo ${file##*/} | cut -d'_' -f3 | cut -c1-8)"
  mkdir -p ${DAY}
  cp ../images/${file##*/} ${DAY}/${file##*/}
done
fi