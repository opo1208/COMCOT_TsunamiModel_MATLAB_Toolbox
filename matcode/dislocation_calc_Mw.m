% a function calculating Magnitude of earthquake 
% based on length, width and dislocation of a rectangular fault plane
% Length: length of fault plane (in km)
% width: width of fault plane (in km)
% dislocation between fault blocks (in meter)
% M0: scalor moment of an earthquake (in dyn-cm, which equals to 10^-7*Nm)
% Mw: moment magnitude of an earthquake

% function dislocation_calc(length,width,Mw)
function dislocation_calc_Mw(length,width,Mw)

mu=3.5*10^10; %rigidity, ranging from 1.0 to 6.0 *10^10 N/m2;


M0 = 10^(1.5*(Mw+10.7)) % calcuate M0 in dyn-cm

% Mw=2/3*log10(M0)-10.7  % in dyn-cm; (Nm = 10^7 dyn-cm)

dislocation = M0/10^7/(mu*(length*1000)*(width*1000))