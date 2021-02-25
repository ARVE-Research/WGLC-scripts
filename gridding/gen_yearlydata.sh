#!/sw/bin/bash -B


# put all output files into one file (monthly)


dir=/Users/klau/Documents/WWLLN/grid_and_correct/uncorr_data_AE/$yr

for ((yr=2010;yr<=2018;yr++))
do
    echo $yr 

    ls $dir/$yr/stroke_uncorr_AE_$yr*.nc | nces -O -H -y ttl $dir/yearly_files_AE_un/$yr.nc

done
