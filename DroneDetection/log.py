#!/usr/bin/env python
import os,sys,io
import time,subprocess
import matlab.engine
engine=matlab.engine.start_matlab("-Desktop")

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
time.sleep(0.2)
print("Connecting to Specified WiFi Object")
result = subprocess.check_output('sudo iw dev wlan0 connect -w accesspoint',shell=True)
x=0
if len(result)>10:
    kk=result[29:37]
for x in range(int(len(mac))):
    if mac[x] in kk:
        res=kk
        if x==0:
            print("D-link")
			break
        if x==1:
            print("Parot")
			break
        if x==2:
            print("DJI-technology")
			break
        if x>2:
            print("Go-Pro")
			break
    else:
		print("MAC not part of list")
		exit(10)

time.sleep(0.2)
print(result)
if "failed" in result:
    os.execv('/log.py',[''])
    exit(1)
time.sleep(0.5)
os.system("echo 0x1c113 | sudo tee /sys/kernel/debug/ieee80211/phy0/iwlwifi/iwldvm/debug/bcast_tx_rate")
time.sleep(0.5)
os.system("echo 0x1c113 | sudo tee /sys/kernel/debug/ieee80211/phy0/iwlwifi/iwldvm/debug/monitor_tx_rate")
time.sleep(0.5)
os.system("echo 0x1c113 | sudo tee /sys/kernel/debug/ieee80211/phy0/netdev:wlan0/stations/6c:72:20:da:5f:27/rate_scale_table")
time.sleep(1)
print("Initiate logging")
os.system("sudo linux-80211n-csitool-supplementary/netlink/log_to_file csi.dat")
print("Tracking Protocol Ended")
time.sleep(0.5)


angle = engine.direction('/csi.dat',1)
if angle < 0:		# Check if an error occured in the MATLAB-script
	print("Error during MATLAB-script")
	exit(1)
print(angle)
