%--------------------------------------------------------------------------
      function [LON,LAT] = utm_to_sph (X,Y,LON0,LAT0)
%..........................................................................
%DESCRIPTION:
%     #. MAPPING A POINT ON A PLANE ONTO THE ELLIPSOID SURFACE;
%	  #. USE REVERSE TRANSVERSE MERCATOR PROJECTION;
%     #. CONVERT UTM (NO FALSE NORTHING/EASTING) TO LATITUDE/LONGITUDE;
%     #. UTM COORDINATES RELATIVE TO USER-DEFINED NATURAL ORIGIN
%INPUT:
%     X: X COORDINATE/EASTING IN METERS RELATIVE TO NATURAL ORIGIN
%     Y: Y COORDINATE/NORTHING IN METERS RELATIVE TO NATURAL ORIGIN
%     LAT0: LATITUDE OF NATURAL ORIGIN IN DEGREES (USER-DEFINED)
%     LON0: LONGITUDE OF NATURAL ORIGIN IN DEGREES (USER-DEFINED)
%OUTPUT:
%     LAT: LATITUDE IN DEGREES
%     LON: LONGITUDE IN DEGREES
%REFERENCES:
%	  #. SNYDER, J.P. (1987). MAP PROJECTIONS - A WORKING MANUAL.
%                          USGS PROFESSIONAL PAPER 1395
%	  #. POSC SPECIFICATIONS 2.2
%     #. ELLIPSOIDAL DATUM: WGS84
%NOTES:
%     CREATED ON DEC22 2008 (XIAOMING WANG, GNS)     
%	  UPDATED ON JAN05 2009 (XIOAMING WANG, GNS)     
%--------------------------------------------------------------------------
      EPS = 1.0e-10
      RAD_DEG = pi/180.0
	  POLE = pi/2.0 - EPS	  %AVOID SINGULARITY AT POLES	  
%.....CONStanTS BASED ON WGS84 DATUM
	  A = 6378137.0
%       A = 6377563.396
	  B = 6356752.3142
	  K0 = 0.9996013
      F = (A-B)/A
%       F = 1/299.32496
      E = sqrt(2*F-F^2)
      ES = E^2/(1-E^2)
% 	  e = 0.081819190928906        %   % eccentricity of ellipsoid, e = sqrt(1-b^2/a^2)
% 	  es = 0.006739496756587        %  % second eccentricity, es = e^2/(1-e^2)
% 	  k0 = 0.9999079				 % % scale factor
	  	  
% 	  f2 = 0.006694380004261        %% f2=e^2
      F2 = E^2
      F4 = E^4
      F6 = E^6
% 	  E = 0.081819190928906           % E = sqrt(1-B^2/A^2)
% 	  ES = 0.006739496756587          % ES = E^2/(1-E^2)
	  N = (A-B)/(A+B)           % N = (A-B)/(A+B)
	  	  
% 	  F2 = 0.006694380004261		% F2=E^2
% 	  F4 = 0.00004481472364144701   % F4=E^4
% 	  F6 = 0.0000003000067898417773 % F6=E^6

%.....FALSE EASTING AND NORTHING
	  XF = 0.0
	  YF = 0.0
% 	  XF = 400000
% 	  YF = -100000
      
%*	  XF = 500000.0
%*	  IF (LATIN .LT. 0.0) YF = 10000000.0     % FOR SOUTH HEMISPHERE; 0.0 FOR NORTH HEMISPHERE
%.....CONVERT DEGREES TO RADIAN
	  LT0 = LAT0*RAD_DEG
	  LN0 = LON0*RAD_DEG

	  CS0 = cos(LT0)
	  SN0 = sin(LT0)
	  TN0 = SN0/CS0

	  S0 = A*((1.0-F2/4.0-3.0*F4/64.0-5.0*F6/256.)*LT0 - ...
	         (3.*F2/8.0+3.0*F4/32.0+45.0*F6/1024.0)*sin(2.0*LT0) + ...
			 (15.0*F4/256.0+45.0*F6/1024.0)*sin(4.0*LT0) - ...
			 (35.0*F6/3072.0)*sin(6.0*LT0))


	  S1 = S0 + (Y-YF)/K0
	  MU1 = S1/A/(1.0-F2/4.0-3.0*F4/64.0-5.0*F6/256.0)
	  E1 = (1.0-sqrt(1.0-F2))/(1.0+sqrt(1.0-F2))
	  LT1 = MU1+(3.0*E1/2.0-27.0*E1^3/32.0)*sin(2.0*MU1) + ...
	            (21.0*E1^2/16.0-55.0*E1^4/32.0)*sin(4.0*MU1) + ...
			    (151.0*E1^3/96.0)*sin(6.0*MU1) + ...
			    (1097.0*E1^4/512.0)*sin(8.0*MU1)

% 	  IF (LT1 .GT. POLE) LT1 = POLE
% 	  IF (LT1 .LT. -POLE) LT1 = -POLE

	  TMP1 = sqrt(1.0-F2*sin(LT1)^2)
	  NU1 = A/TMP1
	  RHO1 = A*(1.0-F2)/TMP1^3
	  T1 = tan(LT1)^2
	  C1 = ES*cos(LT1)^2
	  D = (X-XF)/NU1/K0

	  LAT = LT1 - NU1*tan(LT1)/RHO1*(D^2/2.0 - ...
	             (5.0+3.0*T1+10.0*C1-4.0*C1^2-9.0*ES)*D^4/24.0 + ...
				 (61.0+90.0*T1+298.0*C1+45.0*T1^2-252*ES-3.0*C1^2) * ...
				 D^6/720.0)

	  LON = LN0 + 1.0/cos(LT1) * (D-(1.0+2.0*T1+C1)*D^3/6.0 + ...
	              (5.0-2.0*C1+28.0*T1-3.0*C1^2+8.0*ES+24.0*T1^2) * ...
				  D^5/120.0)

%     CONVERT UNITS FROM RADIAN TO DEGREES
	  LAT = LAT*180.0/pi
	  LON = LON*180.0/pi
%	  write(*,*) X,Y%	  write(*,*) X,Y