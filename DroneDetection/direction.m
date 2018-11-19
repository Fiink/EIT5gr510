%DIRECTION Determines direction from given MEX-file
function thetaCRP = direction(mexfile, packet)
    d_antenna = 0.06;   % Distance between antennas (|M1-M2|)
    f = 2.4E9;          % Signal frequency
    l_f = 299792458/f;  % Wavelength of signal (c/f)
    thetaCRP = 0;       % Return value

    %Add subfolder containing provided MATLAB-scripts from CSI-tool
    folder = fileparts(which(mfilename)); 
    addpath(genpath(folder));

    %Load CSI trace packet
    csi_trace = read_bf_file(mexfile);

    %Convert CSI values to absolute units
    csi = get_scaled_csi(csi_trace{packet});

    %Compute median phase for antenna-pairs
    phaseA = unwrap(angle(squeeze(csi(:,1,:)).')); 
    phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
    phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));
    
    %Determine size of array. phaseA is a 30xn array, where n
    %corresponds to the amount of transmitter-antennas.
    [~,n] = size(phaseA);
    
    %Determine angle for each transmitter-signal
    for i = 1:n
       phaseAB = mean(phaseB(:,i) - phaseA(:,i));
       phaseAC = mean(phaseC(:,i) - phaseA(:,i));
       phaseBC = mean(phaseC(:,i) - phaseB(:,i));
       
       theta1 = asin((sign(phaseAB)*l_f/2*((pi-abs(phaseAB))/pi))/d_antenna);
       theta2 = asin((sign(phaseAC)*l_f/2*((pi-abs(phaseAC))/pi))/d_antenna);
       theta3 = asin((sign(phaseBC)*l_f/2*((pi-abs(phaseBC))/pi))/d_antenna);
       thetaCRP = thetaCRP + (theta1+(theta2-pi/3)+(theta3+pi/3))/3;
    end
    
    % Take the average value of thetaCRP-calculations
    thetaCRP = thetaCRP/n;
end
