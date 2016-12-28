appmon@NOVPLNMD04:~/ipoc/threadlog> awk '{if ($1 ~ /^top/) {tm=$3;print $0} }' top_20161227.log 

