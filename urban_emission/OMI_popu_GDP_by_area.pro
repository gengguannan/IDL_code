pro OMI_popu_GDP_by_area

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;input files
filename1 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_seasonal_average_2006_JJA_05x0666.bpch'
filename2 = '/home/gengguannan/indir/parameter/totalpopu_05x0666.bpch'
filename3 = '/home/gengguannan/indir/mask/China_mask.geos5.v3.05x0666'

ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=802
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
mask=*(datainfo_3[0].data)


;choose whether to remove pow dominated grids
usefilter = 0

if (usefilter) then begin

  gdp_temp = fltarr(InGrid.IMX,InGrid.JMX)
  data18 = fltarr(InGrid.IMX,InGrid.JMX)
  sum = fltarr(InGrid.IMX,InGrid.JMX)
  pow = fltarr(InGrid.IMX,InGrid.JMX)
  pp = fltarr(InGrid.IMX,InGrid.JMX)

  for Year = 2006,2006 do begin
    Yr4 = string( Year, format = '(i4.4)')

    ;GDP data
    filename4 = '/home/gengguannan/indir/parameter/GDP_'+Yr4+'_05x0666.bpch'

    ctm_get_data,datainfo_4,filename = filename4,tracer=802
    data3=*(datainfo_4[0].data)

    print,total(data3)
    gdp_temp += data3

    ;remove grids (pp>60%)
    ;filename5 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
    ;filename6 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
    ;filename7 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/dom-'+Yr4+'-05x0666.bpch'
    ;filename8 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/ind-'+Yr4+'-05x0666.bpch'
    ;filename9 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/tra-'+Yr4+'-05x0666.bpch'
    filename5 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_pow_'+Yr4+'.05x0666'
    filename7 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_res_'+Yr4+'.05x0666'
    filename8 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_ind_'+Yr4+'.05x0666'
    filename9 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_tra_'+Yr4+'.05x0666'

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

      ctm_get_data,datainfo_7,filename = filename7,tau0=Tau0,tracer=1
      dom=*(datainfo_7[0].data)

      ctm_get_data,datainfo_8,filename = filename8,tau0=Tau0,tracer=1
      ind=*(datainfo_8[0].data)

      ctm_get_data,datainfo_9,filename = filename9,tau0=Tau0,tracer=1
      tra=*(datainfo_9[0].data)

      print,total(dom),total(ind),total(tra),total(pow1),total(pow2)

      pow_temp = pow1+pow2
      sum_temp = pow1+pow2+dom+ind+tra
      print,total(pow_temp),total(sum_temp)

      sum += sum_temp
      pow += pow_temp

      CTM_Cleanup

    endfor
  endfor

  gdp_temp = gdp_temp
  print,total(gdp_temp)

  for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
      if (sum[I,J] gt 0)               $
      then pp[I,J] = pow[I,J]/sum[I,J] $
      else pp[I,J] = 0
    endfor
  endfor

  for I = 0,InGrid.IMX-1 do begin
    for J = 0,InGrid.JMX-1 do begin
      if pp[I,J] gt 0.6     $
      then data18[I,J] = 0  $
      else data18[I,J] = data1[I,J]
    endfor
  endfor

endif else begin

  gdp_temp = fltarr(InGrid.IMX,InGrid.JMX)
  data18 = fltarr(InGrid.IMX,InGrid.JMX)

  for Year = 2006,2006 do begin
    Yr4 = string( Year, format = '(i4.4)')

    ;GDP data
    filename4 = '/home/gengguannan/indir/parameter/GDP_'+Yr4+'_05x0666.bpch'

    ctm_get_data,datainfo_4,filename = filename4,tracer=802
    data3=*(datainfo_4[0].data)

    print,total(data3)
    gdp_temp += data3

  endfor

  gdp_temp = gdp_temp
  print,total(gdp_temp)

  data18 = data1

endelse


OMI = make_array(1)
popu = make_array(1)
GDP = make_array(1)


;area = [35,104,41,114]
;area = [30,114,45,122]
;area = [40,120,50,135]
;area = [25,97,33,110]
area = [20,110,30,123]

i1_index = where(xmid ge area[1] and xmid le area[3])
j1_index = where(ymid ge area[0] and ymid le area[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


;for I = 0,InGrid.IMX-1 do begin
;  for J = 0,InGrid.JMX-1 do begin
;for I = I1,I2 do begin
;  for J = J1,J2 do begin
;    if (mask[I,J] gt 0) and (data18[I,J] gt 0) and (data2[I,J] gt 0) and (gdp_temp[I,J] gt 0) then begin
;      OMI = [OMI,alog(data18[I,J])]
;      popu =[popu,alog(data2[I,J])]
;      GDP = [GDP,alog(gdp_temp[I,J])]
;    endif
;  endfor
;endfor

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (mask[I,J] gt 0) and (data18[I,J] gt 0) then begin
      OMI = [OMI,data18[I,J]]
      popu =[popu,data2[I,J]]
      GDP = [GDP,gdp_temp[I,J]]
    endif
  endfor
endfor



outfile = '/home/gengguannan/work/ur_emiss/result/OMI_GDP_popu.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, OMI, 'OMI',          $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, popu, 'popu',  $
           Longname='popu',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, GDP, 'GDP',  $
           Longname='GDP',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID

end
