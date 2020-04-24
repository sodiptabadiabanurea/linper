# linper
Automated Linux Persistence Establishment

After configuring a few variables and running the script, it will go through and configure multiple methods of persistance using reverse shells in various location.

## files
- README.md - or not
- linper.sh - main file; configure, then, execute on target

## usage
1. Configure attackBox, attackPort, and cron in linper.sh appropiately (the only one that needs any kind of quotation marks is cron)
2. Move linper.sh to target
3. bash linper.sh
