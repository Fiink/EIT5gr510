% TEST_FILE Test the direction command
clear;
done=0;
start='/sys/kernel/debug/ieee80211/phy0/netdev:wlan0/stations/';
folder = dir(start);
[large,z]=size(folder);
large=large-2;
id=0;

while 1
    for c = 1:large
%        if(isempty(strfind(folder(2+c).name, '60:60:1F:'))==0)
        if(isempty(strfind(folder(2+c).name, '6C:72:20:'))==0)
            id=c;
            break;
        end
    end
    if(id>0) 
        done = 1;
        break;
    end
end
%check = dir(strcat(start,'\',folder(2+id).name));
%[numb,z] = size(check);
%numb=numb-2
%path=strcat(start,'\',folder(2+id).name)

if(done==1)
    %her køres funktionen med path
    angleCRP = direction(/csi.dat,1)
end




