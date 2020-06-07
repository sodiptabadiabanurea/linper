# linper
Automated Linux Persistence Establishment

After configuring a few variables and running the script, it will go through and configure multiple methods of persistance using reverse shells in various locations.

## files
- README.md - or not
- linper.sh - main file; configure, then, execute on target

## usage
1. Configure attackBox, attackPort, and cron in linper.sh appropiately (the only one that needs any kind of quotation marks is cron)
2. Move linper.sh to target
3. bash linper.sh

## details
Assuming all prerequisites are met, the script does the following:

1. Writes to the current users crontab
2. Writes to the current users bashrc
3. Creates services and enables them to run at startup (root required)
4. Writes a PHP webshell to /var/www/html/ (root required)
5. Pulls users with a password from the shadow file (root required)

## warning
Putting the reverse shells in the current users bashrc will cause errors to show up in the users terminal if the connection fails, and since multple are ran, if one connects, the rest will fail. I am working on a workaround to suppress all output but nothing substantial yet. If you need to be extra stealthy and do not want to put anything in the bashrc, comment out the check for the HOME variable.