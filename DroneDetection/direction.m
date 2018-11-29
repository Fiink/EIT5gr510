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
    
    %Determine size of array. phaseA is a 30xn array, where n
    %corresponds to the amount of transmitter-antennas.
    [~,n] = size(phaseA);
    
    %Determine angle for each transmitter-signal
    for i = 2:n    % OBS TAGER KUN ANTENNE 2
       % Faseforskel
       phaseAB = mean(phaseB(:,i) - phaseA(:,i));
       if (phaseAB > pi)
           phaseAB = mean(phaseB(:,i) - phaseA(:,i) - 2*pi);
       elseif (phaseAB < -pi)
           phaseAB = mean(phaseB(:,i) - phaseA(:,i) + 2*pi);
       end
       phaseAC = mean(phaseC(:,i) - phaseA(:,i));   
       if (phaseAC > pi)
           phaseAC = mean(phaseC(:,i) - phaseA(:,i) - 2*pi);
       elseif (phaseAC < -pi)
           phaseAC = mean(phaseC(:,i) - phaseA(:,i) + 2*pi);
       end
       phaseBC = mean(phaseC(:,i) - phaseB(:,i));
       if (phaseBC > pi)
           phaseBC = mean(phaseC(:,i) - phaseB(:,i) - 2*pi);
       elseif (phaseBC < -pi)
           phaseBC = mean(phaseC(:,i) - phaseB(:,i) + 2*pi);
       end

       % Beregning af d (afstand af boelge)
       dAB = sign(phaseAB)*lf/2*(1-(pi-abs(phaseAB))/pi);
       dAC = sign(phaseAC)*lf/2*(1-(pi-abs(phaseAC))/pi);
       dBC = sign(phaseBC)*lf/2*(1-(pi-abs(phaseBC))/pi);

       % Beregning af tidsforskel
       tauAB = dAB/c;
       tauAC = dAC/c;
       tauBC = dBC/c;

       % Beregning af vinkel
       fracAB = (tauAB*c)/d_antenna;
       fracAC = (tauAC*c)/d_antenna;
       fracBC = (tauBC*c)/d_antenna;
       if fracAB > 1
           fracAB = 1;
       elseif fracAB < -1
           fracAB = -1;
       elseif fracAC > 1
           fracAC = 1;
       elseif fracAC < -1
           fracAC = -1;
       elseif fracBC > 1
           fracBC = 1;
       elseif fracBC < -1
           fracBC = -1;
       end

       thetaAB = asin(fracAB);
       thetaAC = asin(fracAC);
       thetaBC = asin(fracBC);
        
       %Converts rads to degrees
       thetaABdeg = thetaAB*180/pi;
       thetaACdeg = thetaAC*180/pi;
       thetaBCdeg = thetaBC*180/pi;
       
       %calculate the CRP
       thetaCRP = thetaCRP + (thetaABdeg + thetaACdeg-60 + thetaBCdeg+60)/3;
    end
    
    % Take the average value of thetaCRP-calculations
    thetaCRP = thetaCRP/n;
end
