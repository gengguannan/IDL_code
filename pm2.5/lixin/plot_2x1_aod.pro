pro plot_2x1_aod

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;limit=[-11,70,55,150]
limit=[15,70,55,136]


!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 2, row = 1

xmax = 8 
ymax = 12

xsize= 8
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0


Open_Device,                        $
  /PS, /Color, Bits=8,              $
  Filename='/home/gengguannan/work/pm2.5/result/test.ps', $
  /portrait, /Inches,               $
  XSize=XSize, YSize=YSize,         $
  XOffset=XOffset, YOffset=YOffset 


aod_temp = fltarr(InGrid.IMX,InGrid.JMX,2)
avg_gc_AOD = fltarr(InGrid.IMX,InGrid.JMX)

; Infile
;filename1 = '/home/gengguannan/work/pm2.5/pm2.5/gc/model_aod_components_yearly.2004'
;filename2 = '/home/gengguannan/work/pm2.5/pm2.5/gc/model_aod_components_yearly.2005'
;filename1 = '/home/gengguannan/satellite/aod/MISR/MISR_0.66x0.50_yearly.2004'
;filename2 = '/home/gengguannan/satellite/aod/MISR/MISR_0.66x0.50_yearly.2005'
filename1 = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/model_aod.200601.hdf'
filename2 = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/model_aod.200607.hdf'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(filename1,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

AOD = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

avg_gc_AOD[375:495,158:290] = AOD
aod_temp[*,*,0] = avg_gc_aod


FID = HDF_SD_START(filename2,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

AOD = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

avg_gc_AOD[375:495,158:290] = AOD
aod_temp[*,*,1] = avg_gc_aod


i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = aod_temp[I1:I2,J1:J2,0]
data828 = aod_temp[I1:I2,J1:J2,1]
print,max(data818),max(data828)


; plot
Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 1.8

Myct,22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,            			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 7,                                         $
format = '(f6.1)',                                       $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='200601',  	                        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/cbar,                                                  $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 7,                                         $
format = '(f6.1)',                                       $
cbposition=[0 , 0.03, 1.0, 0.06 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='200607',                              $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


;Colorbar,					         $
  ;Position=[ 0.10, 0.20, 0.90, 0.22],                   $
;  Position=[ 0.15, 0.10, 0.85, 0.12],			 $
  ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
;  divisions = 11,                                        $
;  c_colors=c_colors,C_levels=C_levels,			 $
;  Min=0, Max=10, Unit='',format = '(f6.1)',charsize=0.8

                   ;
TopTitle = ''
  XYOutS, 0.53, 0.07, TopTitle,            $
  /Normal,                                 $ ; Use normal coordinates
  Color=!MYCT.BLACK,                       $ ; Set text color to black
  CharSize=0.8,                            $ ; Set text size to twice normal size
  Align= 0.5                                 ; Center text


TopTitle = ''
  XYOutS, 0.5, 1.05,TopTitle,		   $
  /Normal,                 		   $ ; Use normal coordinates
  Color=!MYCT.BLACK, 			   $ ; Set text color to black
  CharSize=1.4,  			   $ ; Set text size to twice normal size
  Align=0.5    				     ; Center text

close_device

end
