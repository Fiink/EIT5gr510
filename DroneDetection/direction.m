%DIRECTION Determines direction from given MEX-file
function thetaCRP = direction(mexfile, packet)
    d_antenna = 0.06;   % Distance between antennas (|M1-M2|)
    f = 2.4E9;          % Signal frequency
    c = 299792458;
    lf = c/f;  % Wavelength of signal (c/f)
    thetaCRP = 0;       % Return value

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
    [~,n] = size(phaseA);
    
    %Determine angle for each transmitter-signal
    for i = 1:n
       % Phase difference
       phaseAB = mean(phaseB(:,i) - phaseA(:,i));
       phaseBC = mean(phaseC(:,i) - phaseB(:,i));
       phaseAC = mean(phaseC(:,i) - phaseA(:,i));
       
       % Change phase direction - If phase difference is more than pi, 
       % 2*pi is either added or substracted.
       if (phaseAB > pi)
           phaseAB = mean(phaseB(:,i) - phaseA(:,i) - 2*pi);
       elseif (phaseAB < -pi)
           phaseAB = mean(phaseB(:,i) - phaseA(:,i) + 2*pi);
       end
       if (phaseAC > pi)
           phaseAC = mean(phaseC(:,i) - phaseA(:,i) - 2*pi);
       elseif (phaseAC < -pi)
           phaseAC = mean(phaseC(:,i) - phaseA(:,i) + 2*pi);
       end
       if (phaseBC > pi)
           phaseBC = mean(phaseC(:,i) - phaseB(:,i) - 2*pi);
       elseif (phaseBC < -pi)
           phaseBC = mean(phaseC(:,i) - phaseB(:,i) + 2*pi);
       end

       % Time difference calculation
       tauAB = sign(phaseAB)*lf/2*(1-(pi-abs(phaseAB))/pi)/c;
       tauAC = sign(phaseAC)*lf/2*(1-(pi-abs(phaseAC))/pi)/c;
       tauBC = sign(phaseBC)*lf/2*(1-(pi-abs(phaseBC))/pi)/c;

       % Angle calculation and conversion to degrees
       thetaAB = asin((tauAB*c)/d_antenna)*180/pi;
       thetaAC = asin((tauAC*c)/d_antenna)*180/pi;
       thetaBC = asin((tauBC*c)/d_antenna)*180/pi;
       
       % Remove imaginary parts (if present)
       % These should only occur if an error during logging has occured
       if imag(thetaAB) ~= 0
           thetaAB = real(thetaAB);
       end
       if imag(thetaAC) ~= 0
           thetaAC = real(thetaAC);
       end
       if imag(thetaBC) ~= 0
           thetaBC = real(thetaBC);
       end
       
       %Calculate the CRP
       thetaCRP = thetaCRP+(thetaAB+thetaAC-pi/3+thetaBC+pi/3)/3;
    end
    
    % Take the average value of theteCRP for each transmitter-antenna
    thetaCRP = thetaCRP/n;
end
