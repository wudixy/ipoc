cat $1 | while read line
do
    name=`ssh -qn appmon@$line hostname`
    echo $name ansible_ssh_host=$line #>> anhost
done 
