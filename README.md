# linper
Automated Linux Persistence Establishment

After configuring a few variables and running the script, it will go through and configure multiple methods of persistance using reverse shells in various locations.

## files
- README.md - or not
- linper.sh - main file; configure, then, execute on target

## basic usage
1. Configure attackBox, attackPort, and cron in linper.sh appropiately (the only one that needs any kind of quotation marks is cron)
2. Move linper.sh to target
3. bash linper.sh

## advanced usage (sudo hijacking)
If you are logged in as a user and do not know their password, it is possible to steal it using this script. Inspired by the [Null Byte article on intercepting a user's invokation of the sudo binary with a function](https://null-byte.wonderhowto.com/how-to/steal-ubuntu-macos-sudo-passwords-without-any-cracking-0194190/), if the current user can sudo, this script will place a sudo function in the current user's bashrc (used to intercept the password) and make a temporary file used to store any intercepted passwords. Anytime sudo is ran by the compromised user, it will do the follwing:
1. puts their password into the temporary password file created by this script
2. deduplicates the temporary password file
3. makes a cURL request to https://{attackBox}/{temporary password file base64 encoded}

You can base64 decode the GET parameter to get the password file. Since cURL makes a request to HTTPS on the attack box, make sure that is set up and you know how to view the access logs. The cURL request does not validate TLS certificates.

## details
Assuming all prerequisites are met, the script does the following:

1. Writes to the current user's crontab
2. Writes to the current user's bashrc
3. Places the "sudo hijack" function in the current user's bashrc (sudo access required)
4. Writes a PHP webshell to www-data's home directory and all subdirectories (root or www-data required)
5. Creates services and enables them to run at startup (root required)
6. Pulls users with a password from the shadow file (root required)