s=`date +%Y-%m-%d%t%H:%M:%S`
s2=`date +%Y-%m-%d`' 23:59:00'
start=`date +%s -d "$s"`
end=`date +%s -d "$s2"`
#echo $(($end-$start))
num3=$(($end-$start))
#echo $num3

num4=`expr $num3 / 60`
echo $num4
