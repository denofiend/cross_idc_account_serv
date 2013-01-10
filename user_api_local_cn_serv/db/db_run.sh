#########################################################################
# File Name: run.sh
# Author: DenoFiend
# mail: denofiend@gmailcom
# Created Time: 2013年01月10日 星期四 10时46分50秒
#########################################################################
#!/bin/bash

echo ${PWD}

sudo /usr/local/nginx/sbin/nginx -p ${PWD}/ -s stop
sudo /usr/local/nginx/sbin/nginx -p ${PWD}/

tail -f logs/error.log

