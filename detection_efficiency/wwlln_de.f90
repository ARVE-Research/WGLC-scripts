program wwlln_de

! execute this line to compile the program - must have netcdf and udunits installed at /usr/local
! gfortran -o wwlln_de calctimemod.f90 wwlln_de.f90 -I/usr/local/include -L/usr/local/lib -lnetcdff -ludunits

use iso_fortran_env, only : real64
use netcdf
use calctimemod

implicit none

character(200) :: infile                     !character= strings: are fixed length
character(200) :: outfile

real, allocatable, dimension(:,:,:) :: de     !real=variables; allocatable= an array that will be dynamically allocated; 3 dimension? 

real, dimension(180) :: line = -9999.        !dimension: declare shape of array (array can have 7 dimensions); here vector length 180

character(8) :: datestring             !! specify datestring as 8 characters 

character(6) :: ct  ! character string for position argument

integer :: nrows                        !variable 
integer :: ncols
integer :: nhrs

integer :: h,i

integer :: status
integer :: ofid
integer :: varid

integer :: t                           !time

real :: tvect                          !(variable) real converts an integer value into real value 

integer :: year
integer :: month
integer :: day
integer :: hour
integer :: min
real    :: sec

integer :: yearout
integer :: monout

real(dp), dimension(24) :: timereal     ! dp = kind of real(), means double?; floating point = length of faction; ration numbers(?)

character(40) :: timeref

integer :: pos

!--------------------------------------------

call udunitsinit()        ! function refer to program - ud unit line 27-38 

!------------------------------

call getarg(1,infile)      ! input file 

open(10,file=infile,status='old')

read(10,*)line                    ! read the first line  + 10 variables

nrows = count(line /= -9999.)     ! count the rows, ignore missing data? 

ncols = 2 * nrows                 ! ncols 
nhrs = 24                         ! 24 hrs 

if (nrows /= 180) then            ! /= is not equals
  write(*,'(a,i5,a)')'ERROR input array has',nrows,', I need 180 rows'    !!write=display variables contents; use, to separate; (*,*)=destination and format for output 
  stop 
end if

rewind(10)

allocate(de(ncols,nrows,nhrs))     !allocate array, determine the size 

call getarg(3,datestring)          ! datestring to get date as filename; use to use scan() but can't work 

! write(0,*)datestring

read(datestring(1:4),*)year
read(datestring(5:6),*)month
read(datestring(7:8),*)day

! write(0,*)year,month,day

!------------------------------

call getarg(2,outfile)

status = nf90_open(outfile,nf90_write,ofid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_varid(ofid,'time',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_get_att(ofid,varid,'units',timeref)
if (status /= nf90_noerr) call handle_err(status)

! write(*,*)timeref

call udsettime(timeref)

!------------------------------

! write(*,*)'reading'

min = 0
sec = 0.0

do h = 1,nhrs
  do i = 1,ncols
    read(10,*,end=99)de(i,:,h)
  end do
  read(10,*) ! blank separator line

  hour = h - 1
  
  call calctime(year,month,day,hour,min,sec,timereal(h))

!   write(0,*)year,month,day,hour,min,sec,timereal(h)
  
end do

99 close(10)

!------------------------------

call getarg(4,ct)

read(ct,*)t

!write(*,*)'writing at position ',ct,t

status = nf90_inq_varid(ofid,'time',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_put_var(ofid,varid,timereal,start=[t],count=[nhrs])
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_varid(ofid,'de',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_put_var(ofid,varid,de,start=[1,1,t],count=[ncols,nrows,nhrs])
if (status /= nf90_noerr) call handle_err(status)

status = nf90_close(ofid)
if (status /= nf90_noerr) call handle_err(status)

call udunitsend()

contains

!--------------------------------------------------------------------------------

subroutine handle_err(status)

implicit none

! Internal subroutine - checks error status after each netcdf call,
! prints out text message each time an error code is returned. 

integer, intent (in) :: status

if(status /= nf90_noerr) then 
  write(0,*)trim(nf90_strerror(status))
  stop
end if

end subroutine handle_err

!--------------------------------------------------------------------------------

end program wwlln_de