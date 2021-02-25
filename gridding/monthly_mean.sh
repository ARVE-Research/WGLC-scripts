#!/sw/bin/bash -B


ncgen -b timevar_allm.cdl 
# see below

ncecat -O -u time *.nc monthly_AE_2.nc  
#put all 108 months into one nc file and assign "record" as "time"

ncks -A days_since_2010-01-01.nc monthly_AE_2.nc

cdo -O ymonmean monthly_AE_2.nc mean_monthly_AE.nc   



#***** timevar_allm.cdl ******
#netcdf timevar {
#dimensions:
#	time = 108;
#variables:
#	float time(time) ;
#		time:units = "days since 2010-01-01 00:00:00" ;
#		time:calendar = "standard" ;
#data:

 #time = 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334,
#  365, 396, 424, 455, 485, 516, 546, 577, 608, 638, 669, 699, 730,
#   761, 790, 821, 851, 882, 912, 943, 974, 1004, 1035, 1065, 1096,
 #   1127, 1155, 1186, 1216, 1247, 1277, 1308, 1339, 1369, 1400, 1430,
#     1461, 1492, 1520, 1551, 1581, 1612, 1642, 1673, 1704, 1734, 1765,
#      1795, 1826, 1857, 1885, 1916, 1946, 1977, 2007, 2038, 2069, 2099,
#       2130, 2160, 2191, 2222, 2251, 2282, 2312, 2343, 2373, 2404, 2435, 
#       2465, 2496, 2526, 2557, 2588, 2616, 2647, 2677, 2708, 2738, 2769,
#        2800, 2830, 2861, 2891, 2922, 2953, 2981, 3012, 3042, 3073, 3103,
#         3134, 3165, 3195, 3226, 3256,  3256 ;
#}
