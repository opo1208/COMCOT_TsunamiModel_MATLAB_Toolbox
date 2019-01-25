%--------------------------------------------------------------------------
      function [X,Y] = sph_to_utm (LONIN,LATIN,LON0,LAT0)
%..........................................................................
%DESCRIPTION:
%     #. MAPPING A POINT ON THE ELLIPSOID SURFACE ONTO A PLANE;
%	  #. USE TRANSVERSE MERCATOR PROJECTION
%     #. CONVERT LATITUDE/LONGITUDE TO UTM (NO FALSE NORTHING/EASTING);
%     #. UTM COORDINATES RELATIVE TO USER-DEFINED NATURAL ORIGIN
%INPUT:
%     LATIN: LATITUDE IN DEGREES
%     LONIN: LONGITUDE IN DEGREES
%     LAT0: LATITUDE OF NATURAL ORIGIN IN DEGREES (USER-DEFINED)
%     LON0: LONGITUDE OF NATURAL ORIGIN IN DEGREES (USER-DEFINED)
%OUTPUT:
%     X: X COORDINATE/EASTING IN METERS RELATIVE TO NATURAL ORIGIN
%     Y: Y COORDINATE/NORTHING IN METERS RELATIVE TO NATURAL ORIGIN
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
%.....CONSTANTS BASED ON WGS84 DATUM
	  A = 6378137.0
%       A = 6377563.396
	  B = 6356752.3142
	  K0 = 0.9996013
      F = (A-B)/A
%       F = 1/299.32496
      E = sqrt(2*F-F^2)
      ES = E^2/(1-E^2)
% 	  e = 0.081819190928906        %   ! eccentricity of ellipsoid, e = sqrt(1-b**2/a**2)
% 	  es = 0.006739496756587        %  ! second eccentricity, es = e**2/(1-e**2)
% 	  k0 = 0.9999079				 % ! scale factor
	  	  
% 	  f2 = 0.006694380004261        %! f2=e**2
      F2 = E^2
      F4 = E^4
      F6 = E^6
% 	  E = 0.081819190928906           % E = sqrt(1-B**2/A**2)
% 	  ES = 0.006739496756587          % ES = E**2/(1-E**2)
	  N = (A-B)/(A+B)           % N = (A-B)/(A+B)
	  	  
% 	  F2 = 0.006694380004261		% F2=E**2
% 	  F4 = 0.00004481472364144701   % F4=E**4
% 	  F6 = 0.0000003000067898417773 % F6=E**6

%.....FALSE EASTING AND NORTHING
	  XF = 0.0
	  YF = 0.0
% 	  XF = 400000
% 	  YF = -100000
      
%*	  XF = 500000.0
%*	  IF (LATIN .LT. 0.0) YF = 10000000.0     % FOR SOUTH HEMISPHERE; 0.0 FOR NORTH HEMISPHERE
%.....CONVERT DEGREES TO RADIAN
	  LAT = LATIN*RAD_DEG
	  LON = LONIN*RAD_DEG
	  LT0 = LAT0*RAD_DEG
	  LN0 = LON0*RAD_DEG

	  if (LAT > POLE) 
          LAT = POLE
      end
	  if (LAT < -POLE) 
          LAT = -POLE
      end
	  if (LT0 > POLE) 
          LT0 = POLE
      end
	  if (LT0 < -POLE) 
          LT0 = -POLE
      end

	  CS = cos(LAT)
	  SN = sin(LAT)
	  TN = SN/CS

	  CS0 = cos(LT0)
	  SN0 = sin(LT0)
	  TN0 = SN0/CS0

	  TMP = sqrt(1.0-F2*SN^2)
	  NU = A/TMP

	  T = TN^2
	  C = ES*CS^2
	  P = (LON-LN0)*CS

	  S = A*((1.0-F2/4.0-3.0*F4/64.0-5.0*F6/256.0)*LAT - ...
	         (3.0*F2/8.0+3.0*F4/32.0+45.0*F6/1024.0)*sin(2.0*LAT) + ...
			 (15.0*F4/256.0+45.0*F6/1024.0)*sin(4.0*LAT) - ...
			 (35.0*F6/3072.0)*sin(6.0*LAT))

	  S0 = A*((1.0-F2/4.0-3.0*F4/64.0-5.0*F6/256.)*LT0 - ...
	         (3.*F2/8.0+3.0*F4/32.0+45.0*F6/1024.0)*sin(2.0*LT0) + ...
			 (15.0*F4/256.0+45.0*F6/1024.0)*sin(4.0*LT0) - ...
			 (35.0*F6/3072.0)*sin(6.0*LT0))

	  X = XF + K0*NU*(P+(1.0-T+C)*P^3/6.0 + ...
	           (5.0-18.0*T+T^2+72.0*C-58.0*ES)*P^5/120.0)

	  Y = YF + K0*(S-S0+NU*TN*(P^2/2.0+(5.0-T+9.0*C+4.0*C^2)*P^4/24.0 + ...
	           (61.0-58.0*T+T^2+600.0*C-330.0*ES)*P^6/720.0))

%	  write(*,*) X,Y