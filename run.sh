#!/usr/bin/env bash
DOWNLOAD_IMAGES=0

. config.cfg
echo Download files from ${ftp_host}...
cd images

if [ ${DOWNLOAD_IMAGES} -eq 1 ]
then
ftp -inv ${ftp_host} << EOF
    user ${ftp_user} ${ftp_pw}
    cd images
    mget *
    bye
EOF
fi

