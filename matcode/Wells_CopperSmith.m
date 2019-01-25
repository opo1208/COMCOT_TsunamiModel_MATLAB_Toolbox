%calculate rupture length and width based on Wells and Coppersmith's
%empirical equation
%for earthquake magnitude range 4.8-8.1

function Wells_CopperSmith(Mw)

% %surface rupture length
disp('Rupture length (meters)')
L = 10^(-3.55+0.74*Mw)
% %subsurface rupture length
% L = 10^(-2.57+0.62*Mw)
% %rupture width
% W = 10^(-0.76+0.27*Mw)

%rupture area
disp('Rupture Area')
A = 10^(-3.42+0.90*Mw)
disp('Rupture Width (meters)')
W = A/L