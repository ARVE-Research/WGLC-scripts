#!/sw/bin/bash -B


# put all output files into one file (monthly)


dir=/Users/klau/Documents/WWLLN/grid_and_correct/AE_DEfiles

for ((yr=2010;yr<=2018;yr++))
do

#yr=2014
  for ((m=1;m<=12;m++))
   do
    mon=`printf "%02i" $m`
    
    echo $yr $mon

    ls $dir/$yr/stroke_dcorr_AE_$yr$mon*.nc | nces -O -y ttl $dir/monthly_AE_files/$yr$mon.nc
    
  done
done



