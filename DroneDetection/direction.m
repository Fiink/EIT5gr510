%DIRECTION Determines direction from given MEX-file
%{
% FJERN SENERE
%   'sample_data/csi.dat',1
   mexfile = 'sample_data/csi.dat';
   packet = 1;
    mexfile = '/csi.dat'
%}
function ret = direction(mexfile, packet)
%     dAntenna = 0.06;    % Distance between antennas (|M1-M2|)
%     f = 2.4E9;          % Signal frequency
%     c = 299792458;      % Speed of light
%     lf = c/f;           % Wavelength of signal
    ret = 0;            % Return value
%     error = 0;          % Used for invalid angle-calculations

    %Add subfolder containing provided MATLAB-scripts from CSI-tool
    folder = fileparts(which(mfilename));
    addpath(genpath(folder));

    %Load CSI trace packet and convert to absolute units
    csi_trace = read_bf_file(mexfile);
    csi = get_scaled_csi(csi_trace{packet});
    
    %Compute phase for antennas
    phaseA = unwrap(angle(squeeze(csi(:,1,:)).')); 
    phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
    phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));
    
    %Determine size of arrays. phaseA is a 30xn array, where n
    %corresponds to the amount of transmitter-antennas.
    [~,TXAntennas] = size(phaseA);
    
    %Determine which antenna is closest to signal source from permutation
    %1 = antenna A, 2 = antenna B, 3 = antenna C
    sourceAntenna = csi_trace{packet,1}.perm(1);
    
    %Determine angle for each transmitter-signal
    for i = 1:TXAntennas
        %Phase difference
        if sourceAntenna == 3   %Compute angle from antenna pair AB
            dPhase = phaseB(:,i) - phaseA(:,i);
        elseif sourceAntenna == 2 %Compute angle from antenna pair AC
            dPhase = phaseC(:,i) - phaseA(:,i);
        elseif sourceAntenna == 1 %Compute angle from antenna pair BC
            dPhase = phaseC(:,i) - phaseB(:,i);
        else
            disp('Error: invalid perm');
            ret = -1; %Indicates an error (-1 is not a valid angle)
            return
        end
        
        %Change phase direction if phase difference is more than pi
        if mean(dPhase) > 0.96*pi
            dPhase = mean(dPhase - 2*pi);
        elseif mean(dPhase) < -0.96*pi
            dPhase = mean(dPhase + 2*pi);
        else
            dPhase = mean(dPhase);
        end

        %Angle calculation (and conversion from radians to degrees)
        theta = 29.64*dPhase;
        
        ret = ret + theta;
    end
    
    %Calculate average value of ret across all iterations:
    ret = ret/TXAntennas;
        
    if sourceAntenna == 3       % Antenna C closest
        ret = mod(ret, 360);        % Take mod_360, as ret may be -90 to 0
    elseif sourceAntenna == 2   % Antenna B closest
        ret = ret + 120;            % Shift by 120 degrees
    elseif sourceAntenna == 1   % Antenna A closest
        ret = ret + 240;            % Shift by 240 degrees
    end
end
