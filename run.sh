#!/usr/bin/env bash
DOWNLOAD_IMAGES=0
SORT_IMAGES=1
CREATE_VIDEO=1
UPLOAD_VIDEO=1
CLEAN_LOCAL=0
CLEAN_FTP=0

. config.cfg

mkdir -p images
mkdir -p sorted_images

if [ ${DOWNLOAD_IMAGES} -eq 1 ]
then
cd images
echo Download files from ${ftp_host}...
wget --user=${ftp_user} --password=${ftp_pw} ftp://${ftp_host}/images/*
cd ..
fi


if [ ${SORT_IMAGES} -eq 1 ]
then
cd sorted_images
echo Sort files into directories
for file in ../images/*; do
  DAY="$(echo ${file##*/} | cut -d'_' -f3 | cut -c1-8)"
  mkdir -p ${DAY}
  cp ../images/${file##*/} ${DAY}/${file##*/}
done
cd ..
fi

if [ ${CREATE_VIDEO} -eq 1 ]
then
cd sorted_images
echo Create videos...
for dir in ./*; do
  ls ${dir##*/} -1 > frames.txt
  cd ${dir##*/}
  mencoder -nosound -ovc lavc -lavcopts \
vcodec=mpeg4:mbd=2:trell:autoaspect:vqscale=3 \
-vf scale=1920:1080 -mf type=jpeg:fps=10 \
mf://@../frames.txt -o ../${dir##*/}.avi
  cd ..
  rm frames.txt
  exit
done
cd ..
fi

if [ ${UPLOAD_VIDEO} -eq 1 ]
then
echo Upload videos...
for dir in sorted_images/*.avi; do
  DAY="$(echo ${dir##*/} | cut -d'.' -f1)"
  DAY_DELIMITED="$(echo $DAY | cut -c1-4).$(echo $DAY | cut -c5-6).$(echo $DAY | cut -c7-8)."
  python upload.py --file="sorted_images/${dir##*/}" \
  --title="${DAY_DELIMITED}" --description="Időjárás ${DAY_DELIMITED}"
done
fi