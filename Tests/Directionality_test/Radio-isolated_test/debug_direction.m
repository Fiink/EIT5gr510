clear;
clf;

disp('###############################################################');
% Konstanter
d_antenna = 0.06;   % Distance between antennas (|M1-M2|)
f = 2.4E9;          % Signal frequency
c = 299792458;
lf = 299792458/f;   % Wavelength of signal (c/f)
thetaCRP = 0;       % Return value

% Undermapper
folder = fileparts(which(mfilename));
addpath(genpath(folder));

%Hent CSI trace & konvertér
csi_trace = read_bf_file('CSI-filer/AC_0deg_nr1.dat');
[temp,~] = size(csi_trace);
X = ['Vaelg packet - max ',num2str(temp),':   '];
packet = input(X);

csi = get_scaled_csi(csi_trace{packet});
[antalrx,~,~] = size(csi);
if antalrx == 1
    disp('NEJ FUCK DIG!');
    return
end

%Beregn faser
phaseA = unwrap(angle(squeeze(csi(:,1,:)).'));
phaseB = unwrap(angle(squeeze(csi(:,2,:)).'));
phaseC = unwrap(angle(squeeze(csi(:,3,:)).'));

%Bestem antal dimensioner
[~,n] = size(phaseA);
X = ['Antal transmitter-antenner: ',num2str(n)];
disp(X);
disp(' ');

for i = 2:n    % OBS TAGER KUN ANTENNE 2
   X=['Begynder udregning for antenne ',num2str(i)];
   disp(X);
   
   % Faseforskel
   phaseABgraf = phaseB(:,i) - phaseA(:,i);
   phaseAB = mean(phaseABgraf);
   if (phaseAB > pi)
       phaseAB = mean(phaseB(:,i) - phaseA(:,i) - 2*pi);
       phaseABgraf = phaseABgraf-2*pi;
   elseif (phaseAB < -pi)
       phaseAB = mean(phaseB(:,i) - phaseA(:,i) + 2*pi);
       phaseABgraf = phaseABgraf+2*pi;
   end
        X = ['phaseAB (mean, median) = ', num2str(phaseAB),'     ',num2str(median(phaseB(:,i) - phaseA(:,i)))];
        disp(X);
   phaseACgraf = phaseC(:,i) - phaseA(:,i);     
   phaseAC = mean(phaseACgraf);
   if (phaseAC > pi)
       phaseAC = mean(phaseC(:,i) - phaseA(:,i) - 2*pi);
       phaseACgraf = phaseACgraf-2*pi;
   elseif (phaseAC < -pi)
       phaseAC = mean(phaseC(:,i) - phaseA(:,i) + 2*pi);
       phaseACgraf = phaseACgraf+2*pi;
   end
        X = ['phaseAC (mean, median) = ', num2str(phaseAC),'     ', num2str(median(phaseC(:,i) - phaseA(:,i)))];
        disp(X);
   phaseBCgraf = phaseC(:,i) - phaseB(:,i);
   phaseBC = mean(phaseBCgraf);
   if (phaseBC > pi)
       phaseBC = mean(phaseC(:,i) - phaseB(:,i) - 2*pi);
       phaseBCgraf = phaseBCgraf-2*pi;
   elseif (phaseBC < -pi)
       phaseBC = mean(phaseC(:,i) - phaseB(:,i) + 2*pi);
       phaseBCgraf = phaseBCgraf+2*pi;
   end
       X = ['phaseBC (mean, median) = ', num2str(phaseBC),'     ', num2str(median(phaseC(:,i) - phaseB(:,i)))];
       disp(X);
   
   disp(' ');
   % Beregning af d (afstand af boelge)
   procentAB = 1-(pi-abs(phaseAB))/pi;
   dAB = sign(phaseAB)*lf/2*procentAB;
   X = ['-phaseAB procent af boelge: ',num2str(procentAB*100),'%, straekning af boelge: ',num2str(dAB)];
   disp(X);
   
   procentAC = 1-(pi-abs(phaseAC))/pi;
   dAC = sign(phaseAC)*lf/2*procentAC;
   X=['-phaseAC procent af boelge: ',num2str(procentAC*100),'%, straekning af boelge: ',num2str(dAC)];
   disp(X);
   
   procentBC = 1-(pi-abs(phaseBC))/pi;
   dBC = sign(phaseBC)*lf/2*procentBC;
   X = ['-phaseBC procent af boelge: ',num2str(procentBC*100),'%, straekning af boelge: ',num2str(dBC)];
   disp(X);
   
   if procentAB > 1 || procentAC > 1 || procentBC > 1
       disp('---FEJL I PROCENT AF BOELGE (% > 100)!!!');
   end
   if abs(dAB) > (0.125/2) || abs(dAC) > (0.125/2) ||abs(dBC) > (0.125/2)
       disp('---FEJL I WAVELENGTH (d > 0.125)!!!');
   end
   
   disp(' ');
   % Beregning af tidsforskel
   tauAB = dAB/c;
   tauAC = dAC/c;
   tauBC = dBC/c;
   X = ['Tidsforskelle, max~4.16e-10 (AB, AC, BC): ',num2str(tauAB),'   ',num2str(tauAC),'   ',num2str(tauBC)];
   disp(X);
   
   disp(' ');
   % Beregning af vinkel
   fracAB = (tauAB*c)/d_antenna;
   fracAC = (tauAC*c)/d_antenna;
   fracBC = (tauBC*c)/d_antenna;
   X = ['--Hvad der laves asin af (AB, AC, BC): ',num2str(fracAB),'   ',num2str(fracAC),'   ',num2str(fracBC)];
   disp(X);
   if abs(fracAB) > 1 || abs(fracAC) > 1 || abs(fracBC) > 1
       disp('##### RESULTAT FOR ET AF VINKLER ER BLEVET TILNAERMENT!! #####');
   end
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
   X = ['--Vinkler (rad): thetaAB= ',num2str(thetaAB),'   thetaAC= ',num2str(thetaAC),'   thetaBC= ',num2str(thetaBC)];
   %disp(X);
   thetaABdeg = thetaAB*180/pi;
   thetaACdeg = thetaAC*180/pi;
   thetaBCdeg = thetaBC*180/pi;
   X = ['--Vinkler (deg): thetaAB= ',num2str(thetaABdeg),'   thetaAC= ',num2str(thetaACdeg),'   thetaBC= ',num2str(thetaBCdeg)];
   disp(X);
   if abs(thetaAB) > pi || abs(thetaAC) > pi || abs(thetaBC) > pi
       disp('----FEJL I VINKELUDREGNING, THETA MERE END PI');
   end
%    
%    disp(' ');
%    %Beregning af thetaCRP
%    thetaCRP = thetaCRP + (thetaABdeg + thetaACdeg-60 + thetaBCdeg+60)/3;
%    X = ['ThetaCRP for antenne ',num2str(i),' = ',num2str((thetaABdeg + thetaACdeg-60 + thetaBCdeg+60)/3)];
%    disp(X)
    disp(' ');
    disp(' ');
end

%thetaCRP = thetaCRP / n;
%X = ['Endelig vaerdi af thetaCRP: ',num2str(thetaCRP)];
% disp(X);



% Plots
%subplot(2,1,1);


plot(phaseABgraf);
hold on;
plot(phaseACgraf);
plot(phaseBCgraf);
x=0:30;
y=0.96*pi;
plot(x,y*ones(size(x)))
y=-0.96*pi;
plot(x,y*ones(size(x)))
legend('AB','AC','BC','Location','NorthEast');
xlabel('Subcarrier index');
ylabel('Phase-difference (rad)');
hold off;




% vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

% plot(phaseB(:,2)-phaseA(:,2));
% hold on;
% plot(phaseC(:,2)-phaseA(:,2));
% plot(phaseC(:,2)-phaseB(:,2));
% x=0:30;
% y=pi;
% plot(x,y*ones(size(x)))
% y=-pi;
% plot(x,y*ones(size(x)))
% legend('AB','AC','BC','Location','NorthEast');
% xlabel('Subcarrier index');
% ylabel('Phase-difference (rad)');
% hold off;
  
% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




% subplot(2,1,2);
% plot(db(abs(squeeze(csi(temp,:,:)).')))
% hold on;
% legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
% xlabel('Subcarrier index');
% ylabel('SNR [dB]');
% hold off;

%{
% Plot faseforskelle for antenne1
plot(phaseB(:,1)-phaseA(:,1));
hold on;
plot(phaseC(:,1)-phaseA(:,1));
plot(phaseC(:,1)-phaseB(:,1));
hold off;
legend('AB','AC','BC','Location','NorthEast');

% Plot faseforskelle for antenne2
plot(phaseB(:,2)-phaseA(:,2));
hold on;
plot(phaseC(:,2)-phaseA(:,2));
plot(phaseC(:,2)-phaseB(:,2));
hold off;
legend('AB','AC','BC','Location','NorthEast');

% Plot faser for antenne2
plot(phaseA(:,2));
hold on;
plot(phaseB(:,2));
plot(phaseC(:,2));
hold off;
legend('A','B','C','Location','NorthEast');
%}