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
It writes bind shells and reverse shells in the current users bashrc and crontab files and reports when one was successfully written

The backdoors are executed in the background of a sleep command so, either success or fail, nothing will be printed to screen

Bashrc files are executed whenenver the user invokes a bash terminal, typically when they open terminal or ssh into the box

Cron files are used to create cron jobs that execute according to the interval specified in the *cron* variable of linper.sh
