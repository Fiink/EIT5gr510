file = 'CSI-filer/60nr2.dat';


dPhaseAvg = 0;





dAntenna = 0.06;    % Distance between antennas (|M1-M2|)
f = 2.4E9;          % Signal frequency
c = 299792458;      % Speed of light
lf = c/f;           % Wavelength of signal
ret = 0;            % Return value
error = 0;          % Used for invalid angle-calculations

%Add subfolder containing provided MATLAB-scripts from CSI-tool
folder = fileparts(which(mfilename));
addpath(genpath(folder));

%Load CSI trace packet and convert to absolute units
csi_trace = read_bf_file(file);

[temp,~] = size(csi_trace);
X = ['Vaelg pakke - max ',num2str(temp),':  '];
packet = input(X);

csi = get_scaled_csi(csi_trace{packet});


%Compute phase for antennas
phaseA = unwrap(angle(squeeze(csi(:,1,:)).')); 
phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
%phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));

%Determine size of arrays. phaseA is a 30xn array, where n
%corresponds to the amount of transmitter-antennas.
[~,TXAntennas] = size(phaseA);
if TXAntennas == 30
    TXAntennas = 1;
end

%Determine which antenna is closest to signal source from permutation
%1 = antenna A, 2 = antenna B, 3 = antenna C
% sourceAntenna = csi_trace{packet,1}.perm(1);
% X = ['Indikatorantenne: ',num2str(sourceAntenna)];
% disp(X);
% disp(' ');
%Determine angle for each transmitter-signal
for i = 1:TXAntennas
        X = ['-----For loop iteration ',num2str(i),'-----'];
        disp(X);
    %Phase difference
%     if sourceAntenna == 3   %Compute angle from antenna pair AB
        dPhase = phaseB(:,i) - phaseA(:,i);
%     elseif sourceAntenna == 2 %Compute angle from antenna pair AC
%         dPhase = phaseC(:,i) - phaseA(:,i);
%     elseif sourceAntenna == 1 %Compute angle from antenna pair BC
%         dPhase = phaseC(:,i) - phaseB(:,i);
%     else
%         disp('Error: invalid perm');
%         ret = -1; %Indicates an error (-1 is not a valid angle)
%         return
%     end

    %Change phase direction if phase difference is more than pi
%         if mean(dPhase) > pi  
%             dPhase = mean(mod(dPhase - pi, 2*pi));
%             % Will always be the same as '= mean(dPhase - pi)', as we 
%             % never have a difference higher than 2*pi
%         elseif mean(dPhase) < -pi
%             %dPhase = mean(mod(dPhase + pi, 2*pi)-pi);
%             dPhase = mean(mod(dPhase,2*pi));
%             
%             % dPhase = mean(mod(dPhase + pi, 2*pi));
%             % Would always equal some value around +pi to +2pi, because the
%             % following happens when we do this calculation:
%             %
%             % The value of dPhase in this case must be in the area -pi to
%             % -2pi.
%             % First, we add pi to it, moving dPhase to the area 0 to -pi.
%             % Then, we take mod_(2*pi). This will always result in a phase
%             % difference in the area +pi to +2pi, which is still invalid to
%             % us. 
%         else
%             dPhase = mean(dPhase);
%         end
    if mean(dPhase) > pi
            disp('#### FASE OVER PI');
        dPhase = mean(dPhase - 2*pi);
    elseif mean(dPhase) < -pi
            disp('#### FASE UNDER PI');
        dPhase = mean(dPhase + 2*pi);
    else
        dPhase = mean(dPhase);
    end
    
    X = ['Faseforskel: ',num2str(dPhase)];
    disp(X);
    dPhaseAvg = dPhaseAvg + dPhase;
    
    %Angle calculation and conversion to degrees
    tau = sign(dPhase)*(lf/2)*(1-((pi-abs(dPhase))/pi))/c;
    theta = asin((tau*c)/dAntenna)*180/pi;

    %Check for imaginary parts, indiciating an error during logging
    %, else add to ret
    if imag(theta) ~= 0
        error = error + 1;
        disp('FANDT FEJL!!!!!!!!!!!!!!!');
    else
        ret = ret + theta;
        X = ['theta for iteration ',num2str(i),': ',num2str(theta)];
        disp(X)
    end
end

%Take average value of ret across the transmitter antennas:
if TXAntennas ~= error
    ret = ret/(TXAntennas-error);
    dPhaseAvg = dPhaseAvg/(TXAntennas-error);
else
    disp('Error: No valid angles for this transmission')
    ret = -1; %Indicates an error (-1 is not a valid angle)
    return
end

% if sourceAntenna == 3       % Antenna C closest
%     ret = mod(ret, 360);        % Take mod_360, as ret may be -90 to 0
% elseif sourceAntenna == 2   % Antenna B closest
%     ret = ret + 120;            % Shift by 120 degrees
% elseif sourceAntenna == 1   % Antenna A closest
%     ret = ret + 240;            % Shift by 240 degrees
% end

disp(' ');
X = ['Endelig faseforskeL: ',num2str(dPhaseAvg)];
disp(X);
X = ['Endelig vinkel: ',num2str(ret)];
disp(X);





