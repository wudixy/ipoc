cat $1 | while read line 
do
	ssh-copy-id -i ~/.ssh/id_rsa.pub appmon@$line
done
