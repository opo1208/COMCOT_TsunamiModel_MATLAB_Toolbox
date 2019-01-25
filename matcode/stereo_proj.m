%test algorithm  of oblique stereographic mapping
% input in degrees
function stereo_proj(latin,lonin,lat0,lon0)

      eps = 1.0e-10
      rad_deg = pi/180
	  lat = latin*rad_deg
	  lon = lonin*rad_deg
	  lt0 = lat0*rad_deg
	  ln0 = lon0*rad_deg
	  if lat >= (pi/2.0-eps) 
          lat = pi/2.0-eps
      end
	  if (lat <= -(pi/2.0-eps)) 
          lat = -(pi/2.0-eps)
      end
      

	  cs = cos(lat)
	  sn = sin(lat)
	  cs0 = cos(lt0)
	  sn0 = sin(lt0)

% 	  xf = 155000.0     % false northing
% 	  yf = 463000.00     % false easting
      xf = 0.0
      yf = 0.0

	  a = 6377397.155          %! ellipsoidal semi-major axis
	  b = 6356752.3142			%! ellipsoidal semi-minor axis
      f = (a-b)/a
%       f = 1/299.15281
      e = sqrt(2*f-f^2)
      es = e^2/(1-e^2)
% 	  e = 0.081819190928906        %   ! eccentricity of ellipsoid, e = sqrt(1-b**2/a**2)
% 	  es = 0.006739496756587        %  ! second eccentricity, es = e**2/(1-e**2)
	  k0 = 0.9999079				 % ! scale factor
	  	  
% 	  f2 = 0.006694380004261        %! f2=e**2
      f2 = e^2
      f4 = e^4
% 	  f4 = 0.00004481472364144701   %! f4=e**4
% 	  f6 = 0.0000003000067898417773 %! f6=e**6

	  tmp = sqrt(1.0-f2*sn^2)
	  tmp0 = sqrt(1.0-f2*sn0^2)
	  rho0 = a*(1.0-f2)/tmp0^3
	  nu0 = a/tmp0
	  r = sqrt(rho0*nu0)
	  n = sqrt(1.0+f2*cs0^4/(1.0-f2))

	  s1 = (1.0+sn0)/(1.0-sn0)
	  s2 = (1.0-e*sn0)/(1.0+e*sn0)
	  w1 = (s1*s2^e)^n
	  sn_xi0 = (w1-1.0)/(w1+1.0)
	  c = (n+sn0)*(1.0-sn_xi0)/(n-sn0)/(1.0+sn_xi0)
	
	  w2 = c*w1
	  sa = (1.0+sn)/(1.0-sn)
	  sb = (1.0-e*sn)/(1.0+e*sn)
	  w = c*(sa*sb^e)^n

	  xi0 = asin((w2-1.0)/(w2+1.0))
	  lm0 = ln0

	  lm = n*(lon-lm0)+lm0
	  xi = asin((w-1.0)/(w+1.0))

	  beta = 1.0 + sin(xi)*sin(xi0) + cos(xi)*cos(xi0)*cos(lm-lm0)

	  y = yf + 2.0*r*k0*(sin(xi)*cos(xi0)-cos(xi)*sin(xi0)*cos(lm-lm0))/beta
	  x = xf + 2.0*r*k0*cos(xi)*sin(lm-lm0)/beta

%	  write(*,*) lm0,xi0,lm,xi,x,y