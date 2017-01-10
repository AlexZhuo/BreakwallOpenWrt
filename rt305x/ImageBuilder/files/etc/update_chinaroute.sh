TMP_DIR="/tmp/etc/update_gfw"
LIST_DIR="/etc/"
CHINAROUTE="/etc/ipset/china"
CHINAROUTE_URL="https://raw.githubusercontent.com/AlexZhuo/BlockedDomains/master/china"

echo 'ChinaRoute Updating...'
cp $CHINAROUTE $LIST_DIR/ChinaRoute.backup

wget --no-check-certificate -q -P $TMP_DIR $CHINAROUTE_URL
[ -e $TMP_DIR/china ] && cp $TMP_DIR/china $CHINAROUTE && echo '	ChinaRoute Updated. '|| echo '	Download CHINAROUTE Fail. '
rm -f $TMP_DIR/china
echo ''