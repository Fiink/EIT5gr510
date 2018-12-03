#!/usr/bin/env python
import os,sys,io
import time,subprocess

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
result = subprocess.check_output('sudo iw dev wlan0 connect -w accesspoint',shell=True)
print(result)
time.sleep(2)
x=0
kk=result[29:37] # MAC-address is located at this index
for x in range(int(len(mac))):
    if mac[x] in kk:
        print("Initiate logging")
        os.system("sudo linux-80211n-csitool-supplementary/netlink/log_to_file csi.dat")
        print("Tracking Protocol Ended")
        exit()








