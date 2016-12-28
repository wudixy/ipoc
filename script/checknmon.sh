havenmon=`ps -ef | grep 'nmon -f' | grep -v grep | grep -v ansible| wc -l`
#havenmon=`ps -ef | grep 'wudi -f' | grep -v grep | grep -v ansible| wc -l`
echo $havenmon
if [ $havenmon -gt 0 ];then
	echo 'have'
	exit 0
else
	echo 'not found'
	exit 1
fi
