%DIRECTION Determines direction from given MEX-file
%{
% FJERN SENERE
%   'sample_data/csi.dat',1
   mexfile = 'sample_data/csi.dat';
   packet = 1;
%}
function thetaCRP = direction(mexfile, packet)
    dAntenna = 0.06;    % Distance between antennas (|M1-M2|)
    f = 2.4E9;          % Signal frequency
    c = 299792458;
    lf = c/f;           % Wavelength of signal (c/f)
    thetaCRP = 0;       % Return value
    dPhase = -1;
    error = 0;          % Used for invalid angle-calculations

    %Add subfolder containing provided MATLAB-scripts from CSI-tool
    folder = fileparts(which(mfilename));
    addpath(genpath(folder));

    %Load CSI trace packet and convert to absolute unit
    csi_trace = read_bf_file(mexfile);
    csi = get_scaled_csi(csi_trace{packet});
    
    %Compute median phase for antenna-pairs
    phaseA = unwrap(angle(squeeze(csi(:,1,:)).')); 
    phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
    phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));
    
    %Determine size of arrays. phaseA is a 30xn array, where n
    %corresponds to the amount of transmitter-antennas.
    [~,TXAntennas] = size(phaseA);
    
    %Determine which antenna is closest to signal source from permutation
    %1 = antenna A, 2 = antenna B, 3 = antenna C
    sourceAntenna = csi_trace{packet,1}.perm(1);
    disp('Hit the following antenna first:')
    disp(int2str(sourceAntenna));
    
    %Determine angle for each transmitter-signal
    for i = 1:TXAntennas
        if sourceAntenna == 3   %Compute angle from antenna pair BC
            %Phase difference
            dPhase = phaseC(:,i) - phaseA(:,i);
        elseif sourceAntenna == 2 %Compute angle from antenna pair AC
            %Phase difference
            dPhase = phaseC(:,i) - phaseA(:,i);
        elseif sourceAntenna == 1 %Compute angle from antenna pair AB
            %Phase difference
            dPhase = phaseC(:,i) - phaseB(:,i);
        else
            disp('Error: invalid perm');
            thetaCRP = -1; %Indicates an error (-1 is not a valid angle)
            return
        end
        %Change phase direction if phase difference is more than pi
        if mean(dPhase) > pi
            dPhase = mean(mod(dPhase - pi, 2*pi));
        elseif mean(dPhase) < pi
            dPhase = mean(mod(dPhase + pi, 2*pi));
        end
        
        %Angle calculation and conversion to degrees
        tau = sign(dPhase)*lf/2*(1-(pi-abs(dPhase))/pi)/c;
        theta = asin((tau*c)/dAntenna)*180/pi;
        
        %Check for imaginary parts, indiciating an error during logging
        %, else add to thetaCRP
        if imag(theta) ~= 0
            error = error + 1;
        else
            thetaCRP = thetaCRP + theta;
        end
    end
    
    %Take average value of thetaCRP across the transmitter antennas:
    if (TXAntennas-error) > 0
        thetaCRP = thetaCRP/(TXAntennas-error);
    else
        disp('Error: No valid angles for this transmission')
        thetaCRP = -1; %Indicates an error (-1 is not a valid angle)
    end
    
    %Add 120 or 240 degrees depending on which antenna is closest to source
    if sourceAntenna == 2
        thetaCRP = thetaCRP + 120;
    elseif sourceAntenna == 1
        thetaCRP = thetaCRP + 240;
    end
    
    %Take modulos_360 of thetaCRP, as it may still be negative degrees
    thetaCRP = mod(thetaCRP,360);
end
