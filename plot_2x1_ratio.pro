pro plot_2x1_ratio,year

CTM_CLEANUP

limit=[14.5,72,52.5,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05]

;portrait
xmax = 8 
ymax = 12

xsize= 6
ysize= 6

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Year = year
Month = 1
NYMD0 = Year * 10000L + Month * 100L + 1L


Yr4 = string(Year,format='(i4.4)')
Mon2 = String( Month, Format = '(i2.2)' )

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/result/ratio_between_DJF_JJA_1997_to_2002.ps', $

             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 


;if Year le 2002 then begin
;  filename1 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_DJF.0125x0125.bpch'
;  filename2 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch'
;endif

;if Year eq 2003 then begin
;  filename1 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v1-0_'+ Yr4 +'_DJF.0125x0125.bpch'
;  filename2 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_'+ Yr4 +'_JJA.0125x0125.bpch'
;endif

;if Year ge 2004 then begin
;  filename1 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_'+ Yr4 +'_DJF.0125x0125.bpch'
;  filename2 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_'+ Yr4 +'_JJA.0125x0125.bpch'
;endif

filename1 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_1997_to_2002_DJF.0125x0125.bpch'
filename2 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_1997_to_2002_JJA.0125x0125.bpch'

;filename1 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_2003_to_2005_DJF.0125x0125.bpch'
;filename2 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_2003_to_2005_JJA.0125x0125.bpch'

filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.0125x0125'


ctm_get_data,datainfo_1,filename = filename1,tau0=nymd2tau(NYMD0),tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=nymd2tau(NYMD0),tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=nymd2tau(19850101),tracer=802
mask=*(datainfo_3[0].data)



;InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.125d0, 0.125d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0
maxdata = 5

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = fltarr(InGrid.IMX,InGrid.JMX)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (mask[I,J] eq 1) and (data18[I,J] gt 0) and (data28[I,J] gt 1)         $
        then data818[I,J] = data18[I,J] / data28[I,J]   $
        else data818[I,J] = -999.0
  endfor
endfor

data828 = data818[I1:I2,J1:J2]
print,max(data828),min(data828)
;print,max(data18[I1:I2,J1:J2]),min(data18[I1:I2,J1:J2])


Myct,22

tvmap,data828,                                          $   
limit=limit,					        $     
/cbar,         				                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax =maxdata,                        $
divisions = 11,                                         $
cbposition=[0, 0.05, 1, 0.08 ],                         $
cbformat='(f5.1)',                                      $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='Ratio between DJF and JJA 1997-2002',               $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor


   ;Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), $
      ;c_colors=c_colors,C_levels=C_levels,			 $
      ;Min=0, Max=20, Unit='',format = '(f3.1)',charsize=1.2
                   ;
   TopTitle = ' '
                   
      XYOutS, 0.85, 0.035, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.0,                                                $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = ' '

      XYOutS, 0.5, 1.05,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.4,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

close_device

end
