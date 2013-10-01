pro annual_average_no2_column_05x05

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

year = 2006
Yr4  = String( Year, format = '(i4.4)' )

no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

for m = 0,12-1 do begin
for d = 0,31-1 do begin

mon2 = string(m+1, format='(i2.2)')
day2 = string(d+1, format='(i2.2)')

nymd = year*10000L+(m+1)*100L+(d+1)*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20050229) then continue
if (nymd eq 20050230) then continue
if (nymd eq 20050231) then continue
if (nymd eq 20050431) then continue
if (nymd eq 20050631) then continue
if (nymd eq 20050931) then continue
if (nymd eq 20051131) then continue
if (nymd eq 20060228) then continue
if (nymd eq 20060229) then continue
if (nymd eq 20060230) then continue
if (nymd eq 20060231) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20060302) then continue
if (nymd eq 20060431) then continue
if (nymd eq 20060631) then continue
if (nymd eq 20060931) then continue
if (nymd eq 20061131) then continue
if (nymd eq 20070229) then continue
if (nymd eq 20070230) then continue
if (nymd eq 20070231) then continue
if (nymd eq 20070431) then continue
if (nymd eq 20070631) then continue
if (nymd eq 20070931) then continue
if (nymd eq 20071131) then continue
if (nymd eq 20071213) then continue
if (nymd eq 20080230) then continue
if (nymd eq 20080231) then continue
if (nymd eq 20080431) then continue
if (nymd eq 20080631) then continue
if (nymd eq 20080928) then continue
if (nymd eq 20080929) then continue
if (nymd eq 20080931) then continue
if (nymd eq 20081131) then continue
if (nymd eq 20090229) then continue
if (nymd eq 20090230) then continue
if (nymd eq 20090231) then continue
if (nymd eq 20090431) then continue
if (nymd eq 20090631) then continue
if (nymd eq 20090931) then continue
if (nymd eq 20091131) then continue
if (nymd eq 20100229) then continue
if (nymd eq 20100230) then continue
if (nymd eq 20100231) then continue
if (nymd eq 20100431) then continue
if (nymd eq 20100631) then continue
if (nymd eq 20100931) then continue
if (nymd eq 20101131) then continue


infile = '/z3/gengguannan/satellite/no2/bishe/CF_0.1/'+ Mon2 +'/omi_no2_'+ Yr4 + Mon2 + Day2 +'_v003_tropCS010_05x0666.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    x = where( (inxmid[I] gt (outxmid - 0.25)) and (inxmid[I] le (outxmid + 0.25)))
    y = where( (inymid[J] gt (outymid - 0.25)) and (inymid[J] le (outymid + 0.25))) 
    if (data18[I,J] gt 0) then begin
       no2[x,y] += data18[I,J] 
       nod[x,y] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = -999.0
  endfor
endfor

outfile = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_annual_average_'+ Yr4 +'_tropCS010_05x0666.bpch'

   success = CTM_Make_DataInfo( no2,                    $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0= tau0,             $
                                Unit='E+15molec/cm2',   $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   success = CTM_Make_DataInfo( nod,       $
                                ThisDataInfo2,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=88,              $
                                Tau0= tau0,             $
                                Unit='unitless',              $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   NewDataInfo = [ThisDataInfo, ThisDataInfo2]

   CTM_WriteBpch, NewDataInfo, FileName = OutFile

end
