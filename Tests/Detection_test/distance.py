#!/usr/bin/env python
import os,sys,io
import time,subprocess

print("Initiating Tracking Protocol")
os.system("sudo modprobe -r iwldvm iwlwifi mac80211")
print("Initiating Driver")
os.system("sudo modprobe iwlwifi connector_log=0x1")
time.sleep(0.5)
print("Activating WiFi Antennas")
os.system("sudo ifconfig wlan0 up")
time.sleep(1)
print("Connecting to Specified WiFi Object")
result = subprocess.check_output('sudo iw dev wlan0 connect -w AccessPoint',shell=True)
print(result)
exit()








