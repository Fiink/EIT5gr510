%DIRECTION Determines direction from given MEX-file
%{
% FJERN SENERE
%   'sample_data/csi.dat',1
   mexfile = 'sample_data/csi.dat';
   packet = 1;
    mexfile = '/csi.dat'
%}
function ret = direction(mexfile, packet)
    dAntenna = 0.06;    % Distance between antennas (|M1-M2|)
    f = 2.4E9;          % Signal frequency
    c = 299792458;      % Speed of light
    lf = c/f;           % Wavelength of signal
    ret = 0;            % Return value
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
            dPhase = mean(dPhase - 2*pi);
        elseif mean(dPhase) < -pi
            dPhase = mean(dPhase + 2*pi);
        else
            dPhase = mean(dPhase);
        end

        %Angle calculation and conversion to degrees
        tau = sign(dPhase)*(lf/2)*(1-((pi-abs(dPhase))/pi))/c;
        theta = asin((tau*c)/dAntenna)*180/pi;
        
        %Check for imaginary parts, indiciating an error during logging
        %, else add to thetaCRP
        if imag(theta) ~= 0
            error = error + 1;
        else
            ret = ret + theta;
        end
    end
    
    %Take average value of thetaCRP across the transmitter antennas:
    if TXAntennas ~= error
        ret = ret/(TXAntennas-error);
    else
        disp('Error: No valid angles for this transmission')
        ret = -1; %Indicates an error (-1 is not a valid angle)
        return
    end
    
    %Add 120 or 240 degrees depending on which antenna is closest to source
    if sourceAntenna == 2       % Antenna B closest
        ret = ret + 120;
    elseif sourceAntenna == 1   % Antenna A closest
        ret = ret + 240;
    end
    
    %Take modulos_360 of thetaCRP, as it may still be negative degrees
    ret = mod(ret,360);
end
