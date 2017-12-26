#!/usr/bin/env bash
DOWNLOAD_IMAGES=0
SORT_IMAGES=1
CREATE_VIDEO=1
UPLOAD_VIDEO=0
CLEAN_LOCAL=0
CLEAN_FTP=0

. config.cfg

mkdir -p ${images_dir_abs_path}
mkdir -p ${sorted_images_dir_abs_path}
mkdir -p ${video_dir_abs_path}

ROOT_DIR=$PWD

function check_error {
    if [ $? -gt 0 ]
    then
        echo Process failed
        echo $?
        python ${ROOT_DIR}/email-alert.py
        exit 1
    fi
}

if [ ${DOWNLOAD_IMAGES} -eq 1 ]
then
    cd ${images_dir_abs_path}
    echo Download files from ${ftp_host}...
    wget --user=${ftp_user} --password=${ftp_pw} ftp://${ftp_host}/images/*
    check_error
    cd ${ROOT_DIR}
fi

if [ ${SORT_IMAGES} -eq 1 ]
then
    echo Sort files into directories...
    cd ${images_dir_abs_path}
    rm -rf ${sorted_images_dir_abs_path}/*
    for file in `ls -1`
    do
        DAY="$(echo ${file##*/} | cut -d'_' -f3 | cut -c1-8)"

        mkdir -p ${sorted_images_dir_abs_path}/${DAY}
        cp ${images_dir_abs_path}/${file##*/} ${sorted_images_dir_abs_path}/${DAY}/${file##*/}
        check_error
    done
    cd ${ROOT_DIR}
fi

if [ ${CREATE_VIDEO} -eq 1 ]
then
    cd ${sorted_images_dir_abs_path}
    echo Create videos...
    for dir in `ls -1`
    do
        ls ${dir##*/} -1 > frames.txt
        cd ${dir##*/}
        mencoder -nosound -ovc lavc -lavcopts \
vcodec=mpeg4:mbd=2:trell:autoaspect:vqscale=3 \
-vf scale=1920:1080 -mf type=jpeg:fps=10 \
mf://@../frames.txt -o ${video_dir_abs_path}/${dir##*/}.avi
        check_error
        cd ..
        rm frames.txt
        check_error
    done
    cd ..
fi

if [ ${UPLOAD_VIDEO} -eq 1 ]
then
    echo Upload videos...
    cd ${video_dir_abs_path}
    for dir in `ls -1 *avi`
    do
        DAY="$(echo ${dir##*/} | cut -d'.' -f1)"
        DAY_DELIMITED="$(echo $DAY | cut -c1-4).$(echo $DAY | cut -c5-6).$(echo $DAY | cut -c7-8)."
        python upload.py --file=${sorted_images_dir_abs_path}"/${dir##*/}" \
  --title="${DAY_DELIMITED}" --description="Időjárás ${DAY_DELIMITED}"
        check_error
    done
fi


