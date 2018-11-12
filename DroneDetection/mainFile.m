% TEST_FILE Test the direction command
clear;

start='C:\Users\lukas\Desktop\matlab_tester\read_from_here';
folder = dir(start);
[large,z]=size(folder);
large=large-2;
id=0;

while 1
    for c = 1:large
        if(isempty(strfind(folder(2+c).name, 'FF-D9-D3'))==0)
            id=c;
            break;
        end
    end
    if(id>0) 
        break;
    end
end
check = dir(strcat(start,'\',folder(2+id).name));
[numb,z] = size(check);
numb=numb-2
path=strcat(start,'\',folder(2+id).name)

if(numb>0)
    %her køres funktionen med path
    %angleCRP = direction(insert_path_to_file_csi,1)
end




