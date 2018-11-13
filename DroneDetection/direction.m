%DIRECTION Determines direction from given MEX-file
function ret = direction(mexfile, packet)
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
    phaseAB = median(phaseA - phaseB)+pi;
    phaseAC = median(phaseA - phaseC)+pi;
    phaseBC = median(phaseB - phaseC)+pi;

    % Angle calculation
    theta1 = 0.125/2*sin((0.125*(2*pi-phaseAB)/(2*pi)));
    theta2 = 0.125/2*sin((0.125*(2*pi-phaseAC)/(2*pi)));
    theta3 = 0.125/2*sin((0.125*(2*pi-phaseBC)/(2*pi)));
    thetaCRP = (theta1+(theta2-pi/3)+(theta3+pi/3))/3;
    
    ret = thetaCRP;
end
