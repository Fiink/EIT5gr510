#!/usr/bin/env python
import os,sys,io
import time,subprocess
import matlab.engine
engine=matlab.engine.start_matlab()
engine.addpath(r'/home/user/Documents/matlab',nargout=0)
print('Engine started...');

mac =[
    '6c:72:20',
    '90:03:b7',
    '60:60:1f',
    'd4:d9:19',
    'f4:dd:9e',
    'd4:32:60',
    'd4:41:69',
    'd8:96:85']
print("Initiating Tracking Protocol")
os.system("sudo modprobe -r iwldvm iwlwifi mac80211")
print("Initiating Driver")
os.system("sudo modprobe iwlwifi connector_log=0x1")
time.sleep(0.5)
print("Activating WiFi Antennas")
os.system("sudo ifconfig wlan0 up")
time.sleep(1)
print("Connecting to Specified WiFi Object")
result = subprocess.check_output('sudo iw dev wlan0 connect -w riisager',shell=True)
print(result)

time.sleep(2)
print("Initiate logging")
os.system("sudo linux-80211n-csitool-supplementary/netlink/log_to_file csi2.dat")
print("Tracking Protocol Ended")
x=0
kk=result[29:37]
for x in range(int(len(mac))):
    if mac[x] in kk:
        res=kk
        print(res)
        print(engine.direction('/csi2.dat',1))
        exit()
    res=False
    print(res)

print("FAILED")









