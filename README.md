# linper
Automated Linux Persistence Establishment

After configuring a few variables and running the script, it will go through and configure multiple methods of persistance using reverse shells in various location.

## files
- README.md - or not
- linper.sh - main file; configure, then, execute on target

## usage
1. Configure attackBox, attackPort, and cron in linper.sh appropiately (the only one that needs any kind of quotation marks is cron)
2. Move linper.sh to target and set the executable bit
3. ./linper.sh

## what it does
The following list of things is dependant on what is installed on the target.

### if ran as a user with the HOME variable set 
- appends to or creates ~/.bashrc
	- netcat reverse shell
	- python reverse shell

### if ran as root
- appends to or creates /etc/rc.local
	- netcat reverse shell
	- python reverse shell
- parses the shadow file

### if crontab is installed
- appends to or creates crontab for user it is ran as
	- netcat reverse shell
	- python reverse shell
