ps -ef | grep 'nmon -f' | grep -v grep | awk '{print $2}' | xargs kill
