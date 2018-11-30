% MAINFILE Main MATLAB script, detects drone and computes AoA
clear;
done = 0;
LUT = ['90:03:B7:';'60:60:1F:';'D4:D9:19:';'F4:DD:9E:';'D4:32:60:';'04:41:69:';'D8:96:85:'];
% Lookup Table indexeres på følgende måde:
% Plads 1: LUT(1,;);    Plads 2: LUT(2,;); 
% osv. Man får følgende tilbage:   ans = 'D4:32:60:'
% Så kan der bare laves et for loop for de 7 elementer.

start = '/sys/kernel/debug/ieee80211/phy0/netdev:wlan0/stations/';
folder = dir(start);
[folderCount,~] = size(folder);
folderCount = folderCount-2;
id=0;

% Loop checking if folder with a drone MAC-address is created by the
% CSI-tool
while done == 0
    for i = 1:folderCount
%        if(isempty(strfind(folder(2+c).name, '60:60:1F:'))==0)
        if(isempty(strfind(folder(2+i).name, '6C:72:20:'))==0)
            id=i;
            break;
        end
    end
    if(id>0) 
        done = 1;
        break;
    else
        disp('Error - no file found');
    end
end
%check = dir(strcat(start,'\',folder(2+id).name));
%[numb,z] = size(check);
%numb=numb-2
%path=strcat(start,'\',folder(2+id).name)

if(done==1)
    %her køres funktionen med path
    angleCRP = direction('/csi.dat',1)
end




