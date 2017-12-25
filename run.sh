#!/usr/bin/env bash
DOWNLOAD_IMAGES=1
SORT_IMAGES=0
CREATE_VIDEO=0
UPLOAD_VIDEO=0
CLEAN_LOCAL=0
CLEAN_FTP=0

. config.cfg

mkdir -p images
mkdir -p sorted_images

if [ ${DOWNLOAD_IMAGES} -eq 1 ]
then
cd images
echo Download files from ${ftp_host}...
ftp -inv ${ftp_host} << EOF
    user ${ftp_user} ${ftp_pw}
    cd images
    mget *
    bye
EOF
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
echo Create videos
for dir in ./*; do
  ls ${dir##*/} -1tr > frames.txt
  cd ${dir##*/}
  mencoder -nosound -ovc lavc -lavcopts \
vcodec=mpeg4:mbd=2:trell:autoaspect:vqscale=3 \
-vf scale=1920:1080 -mf type=jpeg:fps=20 \
mf://@../frames.txt -o ../${dir##*/}.avi

done
cd ..
fi