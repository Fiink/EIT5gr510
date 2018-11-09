clear;
clf;

% Load csi trace
% NOTE: .csi file is a MEX-file, compiled from read_bfee.c
csi_trace = read_bf_file('sample_data/log.all_csi.6.7.6');

%Convert CSI in absolute units, rather than Intel's internal reference
%level. This command is run a specific packet.
%NOTE: Units are linear (NOT dB)  [Unit: 'Voltage space']
csi = get_scaled_csi(csi_trace{1});

phaseA = unwrap(angle(squeeze(csi(:,1,:)).')); 
phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));
phaseAB = median(phaseA - phaseB)+pi;
phaseAC = median(phaseA - phaseC)+pi;
phaseBC = median(phaseB - phaseC)+pi;%Mads

disp('Phase difference (in rad):');
temp = [phaseAB, phaseAC, phaseBC];
disp('       AB       AC        BC');
disp(temp);
disp(' ');

% Angle calculation
tauAB = (0.125*(2*pi-phaseAB)/(2*pi))/(300*10^6);
tauAC = (0.125*(2*pi-phaseAC)/(2*pi))/(300*10^6);
tauBC = (0.125*(2*pi-phaseBC)/(2*pi))/(300*10^6);

angleAB = (0.125/2)*sin(tauAB*300*10^6);
angleAC = (0.125/2)*sin(tauAC*300*10^6);
angleBC = (0.125/2)*sin(tauBC*300*10^6);

disp('Angle (rad then deg)');
temp = [angleAB, angleAC, angleBC];
disp('       AB       AC        BC');
disp(temp);
temp = [angleAB*180/pi, angleAC*180/pi, angleBC*180/pi];
disp('       AB       AC        BC');
disp(temp);
disp(' ');

angleCRP = (angleAB+(angleAC-pi/3)+(angleBC+pi/3))/3;

disp('AngleCRP (rad then deg)');
disp(angleCRP);
disp(angleCRP*180/pi);

