#!/bin/bash

# model running for wwlln_de.f90 (detection efficiency)

#for ((year=2010;year<=2018;year++))
#do

    year=2014
   
	datadir=~/Documents/WWLLN/datafiles/wwlln.net/deMaps/$year

	# generate the netCDF output file from the template .cdl file

	outfile=wwlln_de_$year.nc                 

	ncgen -o  $outfile wwlln_de_grid1deg.cdl    
	  
#--------------------------------------------------------------------------------
	# loop over all the daily files appending the dat data to the netCDF
    # here to get date as file name (coz missing days in 2018)

	i=1
	t=1
	
	for ((m=1;m<=12;m++))
	do
	
	  mon=`printf "%02i" $m`

	  nd=`cal $mon $year | awk 'NF {DAYS = $NF}; END {print DAYS}'`
	  
	  for ((d=1;d<=$nd;d++))
	  do
	    
	    day=`printf "%02i" $d`

	    date=$year$mon$day

        zipfile=$datadir/DE$date.dat.gz

#--------------------------------------------------------------------------------
	  # gunzip the dat file
	  
	  if [ -e "$zipfile" ]
	  then

		  gunzip -f -k $zipfile  
  
		  infile=${zipfile%%.gz}    # %%. = get files without .dat.gz 
  
		  # extract the ymd string (always preceeded by "DE")
 
		  # ymd=`echo $infile | grep -Eo "[[:digit:]]{8}"`   #grep: get 8 characters as outputfile name

#--------------------------------------------------------------------------------
     	  echo working on $date $t
  
		  ./wwlln_de $infile $outfile $date $t              # run model 
  
          #rm $infile

      else
      
        echo data for $date not found, skipping

	  fi	   
  
  
	  #let i++
	  let t+=24

	done   # day loop
  done   # month loop
done   # year loop
  