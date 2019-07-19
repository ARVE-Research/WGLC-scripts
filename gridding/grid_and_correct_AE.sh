#!/bin/bash

# variable declarations


dedir=/Users/klau/Documents/WWLLN/wwlln_de

for ((yr=2010;yr<=2018;yr++))
do

datadir=/Volumes/arve/shared/datasets/climate/lightning/WWLLN/rawdata_AEfiles/$yr

	#--------------------------------------------------------------------------------
	# month loop

	for ((m=1;m<=12;m++))
	do

	  echo month $m

	  nd=`cal $m $yr | awk 'NF {DAYS = $NF}; END {print DAYS}'`              
		#--------------------------------------------------------------------------------
		# Day loop: loop over all days of the month

		mon=`printf "%02i" $m`

		t=1

		for ((d=1;d<="$nd";d++))                         
		do
		  day=`printf "%02i" $d`                          
  
		  date=$yr$mon$day         
					  
		#--------------------------------------------------------------------------------
		  output=AE_DEfiles/$yr/stroke_dcorr_AE_$date.nc         

		  echo working on $output

		  # create an empty file for this day with zero values

		

		  grdmath -Rd -fg -I30m -r 0 = $output"?stroke_density"                

		  # set the input file and unzip

		  input=$datadir/AE$date.loc                           
  
		  #gunzip -k -c $input > tmp.loc                            

		  #------------------------------------
		  # loop over all of every hours of a day

		  for ((i=0;i<=23;i++))
		  do

			#--------------------------------------------------------------------------------
			# read in one hour of lightning data and grid the counts at 30 minute resolution

			

			echo working on hour $i

			
	
			awk -v i="$i" 'BEGIN{FS=",";hs=sprintf("%02i:00:00",i);he=sprintf("%02i:00:00",i+1)}{if ($2>=hs && $2<he) print $4,$3}' $input | \
			xyz2grd -Rd -fg -I30m -r -An -di0 -Gstroke_count.nc

			#--------------------------------------------------------------------------------
			# reduce noise
		
			grdmath stroke_count.nc 2 GE stroke_count.nc MUL = stroke_count_filtered.nc  # set all counts less than 2 to zero (assume they are spurious noise)

			#--------------------------------------------------------------------------------
			# calculate density by dividing by cell area

			

			grdmath stroke_count_filtered.nc gridarea30m_km2.nc DIV = stroke_d.nc?stroke_density

			#--------------------------------------------------------------------------------
			# ===== correction of observed stroke density by detection efficiency ======

			# extract 1 hour of data from the DE grid (1 frame) at 1 degree resolution
			

			ncks -O -F -d time,$t $dedir/wwlln_de_$yr.nc DE.nc
	
			let t++

			#--------------------------------------------------------------------------------

			# interpolate 1 degree grid to 30 minutes

			cdo -s remapbil,stroke_d.nc DE.nc DE30m.nc

			#--------------------------------------------------------------------------------
			# divide uncorrected stroke density by detection efficiency for this hour

			grdmath stroke_d.nc  DE30m.nc  DIV = stroke_dcorr.nc?stroke_dcorr

			#--------------------------------------------------------------------------------
			# add current hour to current day cumulative total

			grdmath stroke_dcorr.nc $output ADD = $output"?stroke_density"
  
			# clean up all temporary file
  
			rm stroke_count.nc stroke_count_filtered.nc stroke_d.nc stroke_dcorr.nc DE.nc DE30m.nc
  
		  done  # hour loop
  
		  #rm tmp.loc
  
		done    # day loop

	done    #month loop 

done   #year loop



