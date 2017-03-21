sleep 10s
for i in $(ls /dev/ | grep 'sd[a-z][1-9]')
do
    mkdir -p /mnt/$i
    mount  -o iocharset=utf8,rw /dev/$i /mnt/$i
    if [ "$?" -ne 0 ];then
        mount -o rw /dev/$i /mnt/$i
    fi

done 