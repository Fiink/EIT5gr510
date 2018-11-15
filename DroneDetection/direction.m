%DIRECTION Determines direction from given MEX-file
function ret = direction(mexfile, packet)
    d_antenna = 0.06;   % distance between antennas (|M1-M2|)

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
    phaseAB = mean(phaseB - phaseA);
    phaseAC = mean(phaseC - phaseA);
    phaseBC = mean(phaseC - phaseB);

    % Angle calculation
    theta1 = asin((sign(phaseAB)*0.125/2*((pi-abs(phaseAB))/pi))/d_antenna);
    theta2 = asin((sign(phaseAC)*0.125/2*((pi-abs(phaseAC))/pi))/d_antenna);
    theta3 = asin((sign(phaseBC)*0.125/2*((pi-abs(phaseBC))/pi))/d_antenna);
    thetaCRP = (theta1+(theta2-pi/3)+(theta3+pi/3))/3;
    
    ret = thetaCRP;
end
