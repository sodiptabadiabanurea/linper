# linper
Automated Linux Persistence Establishment

After configuring a few variables and running the script, it will go through and configure multiple methods of persistance using a combination of reverse and bind shells

## files
- README.md - or not
- linper.sh - main file; configure, then, execute on target

## usage
1. Configure attackBox, attackPort, and cron in linper.sh appropiately (the only one that needs any kind of quotation marks is cron)
2. Move linper.sh to target
3. ./linper.sh

## what it does
It writes reverse shells in the current users bashrc and crontab files. If you are root, it will parse the shadow file and write to /etc/rc.local, subsequently setting the executable bit.

It is designed not to overwrite anything on the system, only append to.

The backdoors are executed in the background of a sleep command to minimize the amount of times the backdoors print to screen. The one instance this will happen is if the python backdoor errors out AND the user causes a second error (both error message will, then, print to screen). It relies either on python or bash for handling the shell

Bashrc files are executed whenenver the user invokes a bash terminal, typically when they open terminal or ssh into the box
The crontab does not rely on files for execution, all files written to (to set the cron) are written to ram disk
/etc/rc.local is executed ata startup
