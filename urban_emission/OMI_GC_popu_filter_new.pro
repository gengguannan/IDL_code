pro OMI_GC_popu_filter_new

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;input data
;filename1 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.new.05x0666.bpch'
filename1 = '/home/gengguannan/work/ur_emiss/gc/scaled_intexb/ctm.vc_seasonal_2006_JJA_NO2.scaled.intexb.05x0666.bpch'

;filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
filename2 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_seasonal_average_2006_JJA_05x0666.bpch'

filename3 = '/home/gengguannan/indir/parameter/totalpopu_05x0666.bpch'
filename4 = '/home/gengguannan/indir/mask/China_mask.geos5.v3.05x0666'


ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
data3=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
mask=*(datainfo_4[0].data)


sum = fltarr(InGrid.IMX,InGrid.JMX)
pow = fltarr(InGrid.IMX,InGrid.JMX)
pp = fltarr(InGrid.IMX,InGrid.JMX)
data18 = fltarr(InGrid.IMX,InGrid.JMX)
data28 = fltarr(InGrid.IMX,InGrid.JMX)
rat = fltarr(InGrid.IMX,InGrid.JMX)


;remove grids (pp>60%)
for Year = 2006,2006 do begin
Yr4 = string( Year, format = '(i4.4)')

;filename5 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
;filename6 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/final_dom_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/final_ind_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/final_tra_05x0666.bpch'

filename5 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_pow_'+Yr4+'.05x0666'
filename7 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_res_2006.05x0666'
filename8 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_ind_2006.05x0666'
filename9 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_tra_2006.05x0666'


for Month = 6,8 do begin
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
pow1=*(datainfo_5[0].data)

;ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
;pow2=*(datainfo_6[0].data)
pow2=0

print,total(pow1),total(pow2)

pow_temp = pow1+pow2
pow += pow_temp

CTM_Cleanup

endfor
endfor

print,total(pow)

ctm_get_data,datainfo_7,filename = filename7,tracer=1
dom=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tracer=1
ind=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tracer=1
tra=*(datainfo_9[0].data)

;ind 0.0872+0.0815+0.0844=0.2531
;dom 0.0434+0.0449+0.0449=0.1332
;tra 0.0833+0.0833+0.0833=0.2500
;(1/1.317+1+1*1.200)*0.2531=0.7490
;(1+1+1)*0.1332=0.3996
;(1/1.170+1+1*1.179)*0.2500=0.7584

print,total(0.2531*ind),total(0.1332*dom),total(0.2500*tra)

sum = pow + 0.2531*ind + 0.1332*dom + 0.2500*tra

print,total(sum)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (sum[I,J] gt 0)               $
    then pp[I,J] = pow[I,J]/sum[I,J] $
    else pp[I,J] = 0
  endfor
endfor

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if pp[I,J] ge 0.6 then begin
      data18[I,J] = 0
      data28[I,J] = 0
    endif else begin
      data18[I,J] = data1[I,J]
      data28[I,J] = data2[I,J]
    endelse
  endfor
endfor


;print data
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if data18[I,J] gt 1 and data28[I,J] gt 0  $
      then rat[I,J] = data28[I,J]/data18[I,J] $
      else rat[I,J] = -999
  endfor
endfor


GC = make_array(1)
OMI = make_array(1)
popu = make_array(1)
ratio = make_array(1)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (mask[I,J] gt 0) and (data18[I,J] gt 0) and (data28[I,J] gt 0) then begin
      GC = [GC,data18[I,J]]
      OMI = [OMI,data28[I,J]]
      ratio = [ratio,rat[I,J]]
      popu = [popu,data3[I,J]]
    endif
  endfor
endfor


outfile = '/home/gengguannan/work/ur_emiss/result/GC_OMI_popu_new.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, GC, 'GC',        $
           Longname='model',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, OMI, 'OMI',      $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, popu, 'popu',    $
           Longname='popu',      $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, ratio, 'ratio',  $
           Longname='ratio',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID

end
